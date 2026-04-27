-- Fix Users Table RLS Policies
-- Add missing SELECT and UPDATE policies for users to view/update their own data

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view their own data" ON users;
DROP POLICY IF EXISTS "Users can update their own data" ON users;
DROP POLICY IF EXISTS "Users can insert their own data" ON users;

-- Create SELECT policy - allows users to view their own data
CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Create UPDATE policy - allows users to update their own data
CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  TO authenticated
  USING (id = auth.uid());

-- Recreate INSERT policy - allows users to insert their own data
CREATE POLICY "Users can insert their own data"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

