-- =====================================================
-- Fix Missing INSERT Policies for Orders and Payments
-- =====================================================

-- Drop old policies that might exist
DROP POLICY IF EXISTS "Authenticated users can create orders" ON orders;
DROP POLICY IF EXISTS "Users can insert orders" ON orders;

-- Recreate INSERT policy for orders
CREATE POLICY "Users can insert orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Drop and recreate payments INSERT policy
DROP POLICY IF EXISTS "Users can insert payments" ON payments;
DROP POLICY IF EXISTS "Authenticated users can insert payments" ON payments;

CREATE POLICY "Users can insert payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (true);

