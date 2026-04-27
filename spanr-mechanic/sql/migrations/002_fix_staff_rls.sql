-- Fix infinite recursion in staff RLS policies

-- Drop all existing staff policies
DROP POLICY IF EXISTS "Staff can view their own company staff" ON staff;
DROP POLICY IF EXISTS "Authenticated users can create staff records" ON staff;
DROP POLICY IF EXISTS "Staff can manage their company staff" ON staff;

-- Create helper function to get user's company ID
-- Uses SECURITY DEFINER to avoid recursion
CREATE OR REPLACE FUNCTION user_company_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT company_id 
  FROM staff 
  WHERE email = auth.jwt()->>'email' 
  AND enabled = true
  LIMIT 1
$$;

-- Policy 1: Allow users to view staff records with their own email (for auth checks)
CREATE POLICY "Users can view their own staff record"
  ON staff FOR SELECT
  TO authenticated
  USING (
    email = auth.jwt()->>'email'
  );

-- Policy 2: Allow users to view other staff in the same company
CREATE POLICY "Staff can view colleagues"
  ON staff FOR SELECT
  TO authenticated
  USING (
    company_id = user_company_id()
  );

-- Policy 3: Allow authenticated users to create staff records (for onboarding)
CREATE POLICY "Users can create staff records"
  ON staff FOR INSERT
  TO authenticated
  WITH CHECK (
    -- User can create staff record for themselves
    email = auth.jwt()->>'email'
    OR
    -- Or if they're already staff in this company
    company_id = user_company_id()
  );

-- Policy 4: Allow staff to update records in their company
CREATE POLICY "Staff can update company staff"
  ON staff FOR UPDATE
  TO authenticated
  USING (
    company_id = user_company_id()
  );

-- Policy 5: Allow staff to delete records in their company
CREATE POLICY "Staff can delete company staff"
  ON staff FOR DELETE
  TO authenticated
  USING (
    company_id = user_company_id()
  );

