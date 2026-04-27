-- =====================================================
-- Allow staff to view user details for their company orders
-- =====================================================

-- Add policy for staff to view users who have orders with their company
CREATE POLICY "Staff can view users with orders in their company"
  ON users FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT DISTINCT o.user_id 
      FROM orders o
      WHERE o.company_id IN (
        SELECT company_id 
        FROM staff 
        WHERE email = auth.jwt()->>'email' 
        AND enabled = true
      )
    )
  );

