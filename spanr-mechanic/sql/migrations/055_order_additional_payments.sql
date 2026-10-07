-- Extra repairs / parts were stored on the order but never billed.
-- Allow a second unpaid payment row (kind = additional) and keep it
-- in sync with approved extra work + parts_replaced costs.

ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS kind TEXT NOT NULL DEFAULT 'booking';

ALTER TABLE payments
  DROP CONSTRAINT IF EXISTS payments_kind_check;

ALTER TABLE payments
  ADD CONSTRAINT payments_kind_check
  CHECK (kind IN ('booking', 'additional'));

ALTER TABLE payments
  DROP CONSTRAINT IF EXISTS payments_order_id_key;

CREATE UNIQUE INDEX IF NOT EXISTS payments_one_booking_per_order
  ON payments (order_id)
  WHERE kind = 'booking';

CREATE UNIQUE INDEX IF NOT EXISTS payments_one_open_additional_per_order
  ON payments (order_id)
  WHERE kind = 'additional' AND status IN ('unpaid', 'processing');

CREATE OR REPLACE FUNCTION public.refresh_order_additional_payment(p_order_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_parts NUMERIC(10, 2);
  v_extra NUMERIC(10, 2);
  v_due NUMERIC(10, 2);
  v_paid_extra NUMERIC(10, 2);
  v_remaining NUMERIC(10, 2);
  v_open_id UUID;
BEGIN
  SELECT COALESCE(SUM(cost), 0) INTO v_parts
  FROM parts_replaced
  WHERE order_id = p_order_id;

  SELECT COALESCE(SUM(estimated_cost), 0) INTO v_extra
  FROM extra_work_requests
  WHERE order_id = p_order_id
    AND status = 'approved';

  v_due := COALESCE(v_parts, 0) + COALESCE(v_extra, 0);

  SELECT COALESCE(SUM(amount), 0) INTO v_paid_extra
  FROM payments
  WHERE order_id = p_order_id
    AND kind = 'additional'
    AND status = 'paid';

  v_remaining := ROUND(v_due - v_paid_extra, 2);

  SELECT id INTO v_open_id
  FROM payments
  WHERE order_id = p_order_id
    AND kind = 'additional'
    AND status IN ('unpaid', 'processing')
  LIMIT 1;

  IF v_remaining <= 0 THEN
    DELETE FROM payments
    WHERE order_id = p_order_id
      AND kind = 'additional'
      AND status IN ('unpaid', 'processing');
    RETURN;
  END IF;

  IF v_open_id IS NOT NULL THEN
    UPDATE payments
    SET amount = v_remaining,
        updated_at = NOW()
    WHERE id = v_open_id;
  ELSE
    INSERT INTO payments (order_id, method, status, amount, kind)
    VALUES (p_order_id, 'upi', 'unpaid', v_remaining, 'additional');
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.refresh_order_additional_payment(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.trg_refresh_order_additional_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order_id UUID;
BEGIN
  v_order_id := COALESCE(NEW.order_id, OLD.order_id);
  PERFORM public.refresh_order_additional_payment(v_order_id);
  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS trg_parts_refresh_additional_payment ON parts_replaced;
CREATE TRIGGER trg_parts_refresh_additional_payment
  AFTER INSERT OR UPDATE OR DELETE ON parts_replaced
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_refresh_order_additional_payment();

DROP TRIGGER IF EXISTS trg_extra_work_refresh_additional_payment ON extra_work_requests;
CREATE TRIGGER trg_extra_work_refresh_additional_payment
  AFTER INSERT OR UPDATE OR DELETE ON extra_work_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_refresh_order_additional_payment();

-- Backfill open additional charges for existing orders
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT DISTINCT order_id
    FROM (
      SELECT order_id FROM parts_replaced
      UNION
      SELECT order_id FROM extra_work_requests WHERE status = 'approved'
    ) x
  LOOP
    PERFORM public.refresh_order_additional_payment(r.order_id);
  END LOOP;
END $$;
