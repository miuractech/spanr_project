-- Allow company staff and assigned mechanics to read vehicles on their orders

CREATE OR REPLACE FUNCTION vehicle_on_company_order(p_vehicle_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.vehicle_id = p_vehicle_id
      AND o.company_id = user_company_id()
  );
$$;

CREATE OR REPLACE FUNCTION vehicle_on_assigned_order(p_vehicle_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.vehicle_id = p_vehicle_id
      AND staff_assigned_to_order(
        o.id,
        ARRAY['active', 'completed']::assignment_status[]
      )
  );
$$;

GRANT EXECUTE ON FUNCTION vehicle_on_company_order(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION vehicle_on_assigned_order(UUID) TO authenticated;

DROP POLICY IF EXISTS "Staff can view vehicles on company orders" ON vehicles;
CREATE POLICY "Staff can view vehicles on company orders"
  ON vehicles FOR SELECT
  TO authenticated
  USING (
    vehicle_on_company_order(id)
    OR vehicle_on_assigned_order(id)
  );
