-- 059: Put an on-hold order back to in_progress when extra work is answered.
--
-- 057 missed the request row that was just approved or rejected, so the
-- "any still pending?" check stayed true and the order never left on_hold.
-- The customer app only updates extra_work_requests; it cannot change the
-- order itself (orders_guard). This trigger is what resumes the job.

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
          AND e.id <> NEW.id
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

-- Customer or shop owner answers a pending request and resumes the order
-- in the same call. Installed app builds still use the trigger above.
CREATE OR REPLACE FUNCTION public.respond_to_extra_work(
  p_request_id uuid,
  p_decision text,
  p_reason text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order_id uuid;
  v_user_id uuid;
  v_company_id uuid;
BEGIN
  IF p_decision NOT IN ('approved', 'rejected') THEN
    RAISE EXCEPTION 'Invalid decision' USING ERRCODE = '22023';
  END IF;

  SELECT e.order_id, o.user_id, o.company_id
  INTO v_order_id, v_user_id, v_company_id
  FROM extra_work_requests e
  JOIN orders o ON o.id = e.order_id
  WHERE e.id = p_request_id
    AND e.status = 'pending';

  IF v_order_id IS NULL THEN
    RAISE EXCEPTION 'Extra work request is not pending' USING ERRCODE = '42501';
  END IF;

  IF v_user_id IS DISTINCT FROM auth.uid()
     AND v_company_id IS DISTINCT FROM public.user_company_id() THEN
    RAISE EXCEPTION 'Not allowed to respond to this request' USING ERRCODE = '42501';
  END IF;

  UPDATE extra_work_requests
  SET status = p_decision,
      rejection_reason = CASE WHEN p_decision = 'rejected' THEN NULLIF(btrim(p_reason), '') ELSE NULL END,
      customer_response_at = now()
  WHERE id = p_request_id
    AND status = 'pending';

  UPDATE orders o
  SET status = 'in_progress'
  WHERE o.id = v_order_id
    AND o.status = 'on_hold'
    AND NOT EXISTS (
      SELECT 1 FROM extra_work_requests e
      WHERE e.order_id = v_order_id
        AND e.status = 'pending'
    );
END;
$$;

REVOKE ALL ON FUNCTION public.respond_to_extra_work(uuid, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.respond_to_extra_work(uuid, text, text) TO authenticated;

-- Orders already stuck: on hold, and every extra-work request has an answer.
UPDATE orders o
SET status = 'in_progress'
WHERE o.status = 'on_hold'
  AND EXISTS (SELECT 1 FROM extra_work_requests e WHERE e.order_id = o.id)
  AND NOT EXISTS (
    SELECT 1 FROM extra_work_requests e
    WHERE e.order_id = o.id
      AND e.status = 'pending'
  );
