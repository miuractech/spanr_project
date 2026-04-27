-- =====================================================
-- Fix Orders Table Relationships and Indexes
-- =====================================================

-- Ensure users table exists with correct structure (should already exist from users.sql)
-- This is just a safety check
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    CREATE TABLE users (
      id UUID PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      phone TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
  END IF;
END $$;

-- Drop incorrect index if it exists (from initial schema)
DROP INDEX IF EXISTS idx_users_user_id;

-- Ensure correct indexes exist
CREATE INDEX IF NOT EXISTS idx_users_id ON users(id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Verify and add foreign key constraint if missing
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'orders_user_id_fkey' 
    AND table_name = 'orders'
  ) THEN
    ALTER TABLE orders 
      ADD CONSTRAINT orders_user_id_fkey 
      FOREIGN KEY (user_id) 
      REFERENCES users(id) 
      ON DELETE RESTRICT;
  END IF;
END $$;

-- Add index for faster order queries by contact fields (for search)
CREATE INDEX IF NOT EXISTS idx_orders_contact_email ON orders(contact_email);
CREATE INDEX IF NOT EXISTS idx_orders_contact_phone ON orders(contact_phone);
CREATE INDEX IF NOT EXISTS idx_orders_contact_name ON orders(contact_name);

-- Create composite index for common query patterns
CREATE INDEX IF NOT EXISTS idx_orders_company_status_date 
  ON orders(company_id, status, scheduled_service_date DESC);

-- Update RLS policies to ensure they work correctly
-- Drop old policies that might reference incorrect columns
DROP POLICY IF EXISTS "Users can view their own data" ON users;
DROP POLICY IF EXISTS "Users can update their own data" ON users;

-- Create correct RLS policies for users table
CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can insert their own data"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

-- Update orders policies to use correct user reference
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;

CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Add update policy for users on their own orders (e.g., cancellation)
CREATE POLICY "Users can update their own orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

