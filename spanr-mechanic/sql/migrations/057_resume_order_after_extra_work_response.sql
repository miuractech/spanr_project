-- 057: Resume an on-hold order once every extra-work request has an answer.
--
-- The mechanic app puts the order on hold when it asks for extra work, and it
-- has no way to resume it. Only the dashboard's Approve button lifted the hold:
-- approving from the customer app (which never lifted it) or rejecting from
-- either side left the order on_hold for good. Doing it here works for every
-- client version, including customer app builds already installed.

CREATE OR REPLACE FUNCTION public.resume_order_after_extra_work_response()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.status = 'pending' AND NEW.status IN ('approved', 'rejected') THEN
    UPDATE orders o
    SET status = 'in_progress'
    WHERE o.id = NEW.order_id
      AND o.status = 'on_hold'
      AND NOT EXISTS (
        SELECT 1 FROM extra_work_requests e
        WHERE e.order_id = NEW.order_id
          AND e.status = 'pending'
      );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_extra_work_resume_order ON extra_work_requests;
CREATE TRIGGER trg_extra_work_resume_order
  AFTER UPDATE OF status ON extra_work_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.resume_order_after_extra_work_response();

-- Orders already stuck: on hold for extra work that has all been answered.
UPDATE orders o
SET status = 'in_progress'
WHERE o.status = 'on_hold'
  AND EXISTS (SELECT 1 FROM extra_work_requests e WHERE e.order_id = o.id)
  AND NOT EXISTS (
    SELECT 1 FROM extra_work_requests e
    WHERE e.order_id = o.id
      AND e.status = 'pending'
  );
