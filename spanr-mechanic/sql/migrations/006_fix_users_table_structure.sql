-- =====================================================
-- Fix Users Table Structure
-- Make id the primary key that matches auth.uid()
-- Remove separate user_id field
-- =====================================================

-- Drop ALL policies on users table
DROP POLICY IF EXISTS "Users can view their own data" ON users;
DROP POLICY IF EXISTS "Users can update their own data" ON users;
DROP POLICY IF EXISTS "Users can insert their own data" ON users;
DROP POLICY IF EXISTS "Users can view own record" ON users;
DROP POLICY IF EXISTS "Users can update own record" ON users;
DROP POLICY IF EXISTS "Allow insert for authenticated users" ON users;

-- Drop ALL policies on vehicles table
DROP POLICY IF EXISTS "Users can view their own vehicles" ON vehicles;
DROP POLICY IF EXISTS "Users can manage their own vehicles" ON vehicles;
DROP POLICY IF EXISTS "Users can insert their own vehicles" ON vehicles;
DROP POLICY IF EXISTS "Users can update their own vehicles" ON vehicles;
DROP POLICY IF EXISTS "Users can delete their own vehicles" ON vehicles;

-- Drop ALL policies on orders table
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;
DROP POLICY IF EXISTS "Authenticated users can create orders" ON orders;

-- Drop ALL policies on payments table
DROP POLICY IF EXISTS "Users can view their own payments" ON payments;

-- Drop existing indexes
DROP INDEX IF EXISTS idx_users_user_id;

-- Drop the user_id column (CASCADE will drop any remaining dependencies)
ALTER TABLE users DROP COLUMN IF EXISTS user_id CASCADE;

-- Drop the id column default
ALTER TABLE users ALTER COLUMN id DROP DEFAULT;

-- Fix vehicles table: Change user_id from TEXT to UUID to match auth.uid()
ALTER TABLE vehicles ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

-- Fix orders table: Change user_id to match auth.uid() directly (no foreign key to users anymore)
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_user_id_fkey;

-- Recreate users RLS policies to use id directly
CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own data"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Recreate vehicles RLS policies
CREATE POLICY "Users can view their own vehicles"
  ON vehicles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own vehicles"
  ON vehicles FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own vehicles"
  ON vehicles FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own vehicles"
  ON vehicles FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Recreate orders RLS policies
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Recreate payments RLS policies
CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid()
    )
  );

-- Create index on users.id for better performance
CREATE INDEX IF NOT EXISTS idx_users_id ON users(id);


