-- =====================================================
-- Phone OTP auth support for shop owners
-- Updates user_company_id() and auth_staff_id() to
-- handle both legacy email-auth and new phone-OTP auth.
-- Updates staff RLS INSERT policy to allow auth_user_id-based inserts.
-- =====================================================

-- Update user_company_id() to support both lookup paths
CREATE OR REPLACE FUNCTION user_company_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT company_id
  FROM staff
  WHERE (
    auth_user_id = auth.uid()
    OR (auth.jwt()->>'email' IS NOT NULL AND email = auth.jwt()->>'email')
  )
  AND enabled = true
  ORDER BY
    CASE WHEN auth_user_id = auth.uid() THEN 0 ELSE 1 END
  LIMIT 1
$$;

-- Update auth_staff_id() to support both lookup paths
CREATE OR REPLACE FUNCTION auth_staff_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT id
  FROM staff
  WHERE (
    auth_user_id = auth.uid()
    OR (auth.jwt()->>'email' IS NOT NULL AND email = auth.jwt()->>'email')
  )
  AND enabled = true
  ORDER BY
    CASE WHEN auth_user_id = auth.uid() THEN 0 ELSE 1 END
  LIMIT 1
$$;

-- Update staff INSERT policy to allow auth_user_id-based inserts (phone-OTP owners)
DROP POLICY IF EXISTS "Users can create staff records" ON staff;
CREATE POLICY "Users can create staff records"
  ON staff FOR INSERT
  TO authenticated
  WITH CHECK (
    auth_user_id = auth.uid()
    OR (auth.jwt()->>'email' IS NOT NULL AND email = auth.jwt()->>'email')
    OR company_id = user_company_id()
  );

-- Update staff SELECT policies to support auth_user_id-based lookup
DROP POLICY IF EXISTS "Users can view their own staff record" ON staff;
CREATE POLICY "Users can view their own staff record"
  ON staff FOR SELECT
  TO authenticated
  USING (
    auth_user_id = auth.uid()
    OR (auth.jwt()->>'email' IS NOT NULL AND email = auth.jwt()->>'email')
  );

-- Add contact_email to staff_profiles for owners who optionally supply a real email
ALTER TABLE staff_profiles
  ADD COLUMN IF NOT EXISTS contact_email TEXT;
