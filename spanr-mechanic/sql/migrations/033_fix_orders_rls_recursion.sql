-- Break orders <-> order_assignments RLS recursion via SECURITY DEFINER helpers

CREATE OR REPLACE FUNCTION order_belongs_to_user_company(p_order_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.id = p_order_id
      AND o.company_id = user_company_id()
  );
$$;

CREATE OR REPLACE FUNCTION order_belongs_to_user(p_order_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM orders o
    WHERE o.id = p_order_id
      AND o.user_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION staff_assigned_to_order(
  p_order_id UUID,
  p_statuses assignment_status[] DEFAULT ARRAY['active']::assignment_status[]
)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM order_assignments oa
    WHERE oa.order_id = p_order_id
      AND oa.staff_id = auth_staff_id()
      AND oa.status = ANY(p_statuses)
  );
$$;

GRANT EXECUTE ON FUNCTION order_belongs_to_user_company(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION order_belongs_to_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION staff_assigned_to_order(UUID, assignment_status[]) TO authenticated;

-- order_assignments: stop querying orders under RLS
DROP POLICY IF EXISTS "Company staff can view assignments" ON order_assignments;
CREATE POLICY "Company staff can view assignments"
  ON order_assignments FOR SELECT
  TO authenticated
  USING (
    order_belongs_to_user_company(order_id)
    OR staff_id = auth_staff_id()
  );

DROP POLICY IF EXISTS "Company staff can manage assignments" ON order_assignments;
CREATE POLICY "Company staff can manage assignments"
  ON order_assignments FOR ALL
  TO authenticated
  USING (
    order_belongs_to_user_company(order_id)
    OR staff_id = auth_staff_id()
  )
  WITH CHECK (
    order_belongs_to_user_company(order_id)
    OR staff_id = auth_staff_id()
  );

-- orders: stop querying order_assignments under RLS
DROP POLICY IF EXISTS "Assigned staff can view their orders" ON orders;
CREATE POLICY "Assigned staff can view their orders"
  ON orders FOR SELECT
  TO authenticated
  USING (
    staff_assigned_to_order(id, ARRAY['active', 'completed']::assignment_status[])
  );

DROP POLICY IF EXISTS "Assigned staff can update their orders" ON orders;
CREATE POLICY "Assigned staff can update their orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (
    staff_assigned_to_order(id, ARRAY['active']::assignment_status[])
  );

-- child tables that subquery orders
DROP POLICY IF EXISTS "Users can view parts for their orders" ON parts_replaced;
CREATE POLICY "Users can view parts for their orders"
  ON parts_replaced FOR SELECT
  TO authenticated
  USING (
    order_belongs_to_user(order_id)
    OR order_belongs_to_user_company(order_id)
    OR created_by = auth_staff_id()
  );

DROP POLICY IF EXISTS "Staff can manage parts on assigned orders" ON parts_replaced;
CREATE POLICY "Staff can manage parts on assigned orders"
  ON parts_replaced FOR ALL
  TO authenticated
  USING (
    order_belongs_to_user_company(order_id)
    OR staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[])
  )
  WITH CHECK (
    order_belongs_to_user_company(order_id)
    OR staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[])
  );

DROP POLICY IF EXISTS "Users can view inspection images for their orders" ON inspection_images;
CREATE POLICY "Users can view inspection images for their orders"
  ON inspection_images FOR SELECT
  TO authenticated
  USING (
    order_belongs_to_user(order_id)
    OR order_belongs_to_user_company(order_id)
    OR uploaded_by = auth_staff_id()
  );

DROP POLICY IF EXISTS "Staff can manage inspection images on assigned orders" ON inspection_images;
CREATE POLICY "Staff can manage inspection images on assigned orders"
  ON inspection_images FOR ALL
  TO authenticated
  USING (
    order_belongs_to_user_company(order_id)
    OR staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[])
  )
  WITH CHECK (
    order_belongs_to_user_company(order_id)
    OR staff_assigned_to_order(order_id, ARRAY['active']::assignment_status[])
  );

-- payments policy from migration 004
DROP POLICY IF EXISTS "Company staff can view their company payments" ON payments;
CREATE POLICY "Company staff can view their company payments"
  ON payments FOR SELECT
  TO authenticated
  USING (order_belongs_to_user_company(order_id));
