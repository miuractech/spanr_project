-- =====================================================
-- Order assignments and staff workload view
-- =====================================================

CREATE TYPE assignment_status AS ENUM ('active', 'reassigned', 'completed', 'cancelled');

CREATE TABLE IF NOT EXISTS order_assignments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE RESTRICT,
  assigned_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  status assignment_status NOT NULL DEFAULT 'active',
  notes TEXT,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_order_active_assignment
  ON order_assignments(order_id)
  WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_order_assignments_order_id ON order_assignments(order_id);
CREATE INDEX IF NOT EXISTS idx_order_assignments_staff_id ON order_assignments(staff_id);
CREATE INDEX IF NOT EXISTS idx_order_assignments_status ON order_assignments(status);

CREATE OR REPLACE VIEW staff_workload AS
SELECT
  s.id AS staff_id,
  s.company_id,
  s.name,
  s.email,
  s.enabled,
  COALESCE(sp.availability, 'available'::staff_availability) AS availability,
  COUNT(oa.id) FILTER (WHERE oa.status = 'active')::INTEGER AS active_jobs
FROM staff s
LEFT JOIN staff_profiles sp ON sp.staff_id = s.id
LEFT JOIN order_assignments oa ON oa.staff_id = s.id
GROUP BY s.id, s.company_id, s.name, s.email, s.enabled, sp.availability;

CREATE OR REPLACE FUNCTION auth_staff_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT id
  FROM staff
  WHERE email = auth.jwt()->>'email'
    AND enabled = true
  LIMIT 1
$$;

CREATE OR REPLACE FUNCTION assign_order_to_staff(
  p_order_id UUID,
  p_staff_id UUID,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_company_id UUID;
  v_assignment_id UUID;
  v_assigner_id UUID;
BEGIN
  v_assigner_id := auth_staff_id();

  SELECT company_id INTO v_company_id
  FROM orders
  WHERE id = p_order_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Order not found';
  END IF;

  IF v_company_id <> user_company_id() THEN
    RAISE EXCEPTION 'Not authorized to assign this order';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM staff
    WHERE id = p_staff_id
      AND company_id = v_company_id
      AND enabled = true
  ) THEN
    RAISE EXCEPTION 'Staff member not found in company';
  END IF;

  UPDATE order_assignments
  SET status = 'reassigned',
      ended_at = NOW()
  WHERE order_id = p_order_id
    AND status = 'active';

  INSERT INTO order_assignments (order_id, staff_id, assigned_by, notes, status)
  VALUES (p_order_id, p_staff_id, v_assigner_id, p_notes, 'active')
  RETURNING id INTO v_assignment_id;

  UPDATE orders
  SET status = 'assigned'
  WHERE id = p_order_id
    AND status IN ('accepted', 'assigned');

  RETURN v_assignment_id;
END;
$$;
