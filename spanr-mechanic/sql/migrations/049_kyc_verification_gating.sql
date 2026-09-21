-- =====================================================
-- KYC verification gating + super-admin approval
--
-- Problem: mechanic_companies has no verification concept.
-- Any company row is publicly visible to customers ("Anyone can
-- view mechanic companies" USING (true)) the moment it is created,
-- regardless of whether KYC documents were ever uploaded or checked.
--
-- This migration:
--   1. Adds a verification_status (+ notes/audit columns) to
--      mechanic_companies, defaulting new signups to 'pending'.
--   2. Restricts the public/customer-facing SELECT policy to
--      verification_status = 'verified' only. Staff of a company can
--      still see (and edit) their own company regardless of status,
--      so onboarding/profile screens keep working while pending.
--   3. Introduces a minimal super-admin concept (admin_users table +
--      is_super_admin() helper) with SECURITY DEFINER RPCs so only
--      admins can move a company/document through verification.
-- =====================================================

-- ---------------------------------------------------------
-- 1. Verification status on mechanic_companies
-- ---------------------------------------------------------

ALTER TABLE mechanic_companies
  ADD COLUMN IF NOT EXISTS verification_status verification_status NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS verification_notes TEXT,
  ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS verified_by TEXT;

CREATE INDEX IF NOT EXISTS idx_mechanic_companies_verification_status
  ON mechanic_companies(verification_status);

-- Grandfather every company that already existed before this migration as
-- 'verified', so live/demo shops don't vanish from the customer app the
-- moment this ships. Only companies created AFTER this point default to
-- 'pending' and go through the new admin review flow.
UPDATE mechanic_companies
SET verification_status = 'verified',
    verified_at = NOW(),
    verified_by = 'system:migration-049-grandfather'
WHERE verification_status = 'pending';

-- ---------------------------------------------------------
-- 2. Super-admin table + helper
-- ---------------------------------------------------------

CREATE TABLE IF NOT EXISTS admin_users (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid())
$$;

GRANT EXECUTE ON FUNCTION is_super_admin() TO authenticated;

DROP POLICY IF EXISTS "Admins can view admin_users" ON admin_users;
CREATE POLICY "Admins can view admin_users"
  ON admin_users FOR SELECT
  TO authenticated
  USING (is_super_admin());

-- Bootstrap-aware: lets the very first admin claim access (table empty),
-- afterwards only existing admins can add more. The target must already
-- have a Supabase Auth account (sign up normally, then claim/be added).
CREATE OR REPLACE FUNCTION admin_add_admin(target_email TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_target_id UUID;
  v_admin_count INT;
BEGIN
  SELECT COUNT(*) INTO v_admin_count FROM admin_users;

  IF v_admin_count > 0 AND NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only existing admins can add new admins' USING ERRCODE = '42501';
  END IF;

  SELECT id INTO v_target_id FROM auth.users WHERE email = target_email LIMIT 1;
  IF v_target_id IS NULL THEN
    RAISE EXCEPTION 'No Supabase Auth account found for %. Ask them to sign up first, then retry.', target_email;
  END IF;

  INSERT INTO admin_users (user_id, email)
  VALUES (v_target_id, target_email)
  ON CONFLICT (user_id) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_add_admin(TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION am_i_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT is_super_admin()
$$;

GRANT EXECUTE ON FUNCTION am_i_super_admin() TO authenticated;

-- ---------------------------------------------------------
-- 3. Gate customer-facing visibility on verification_status
-- ---------------------------------------------------------

DROP POLICY IF EXISTS "Anyone can view mechanic companies" ON mechanic_companies;

CREATE POLICY "Public can view verified mechanic companies"
  ON mechanic_companies FOR SELECT
  TO public
  USING (verification_status = 'verified');

CREATE POLICY "Staff can view own company regardless of status"
  ON mechanic_companies FOR SELECT
  TO authenticated
  USING (id = user_company_id());

CREATE POLICY "Admins can view all mechanic companies"
  ON mechanic_companies FOR SELECT
  TO authenticated
  USING (is_super_admin());

-- ---------------------------------------------------------
-- 4. Admin visibility into KYC documents
-- ---------------------------------------------------------

DROP POLICY IF EXISTS "Admins can view all company documents" ON company_documents;
CREATE POLICY "Admins can view all company documents"
  ON company_documents FOR SELECT
  TO authenticated
  USING (is_super_admin());

-- ---------------------------------------------------------
-- 5. Admin-only verification RPCs (writes gated inside the
--    function body, not via a direct table policy, so a company's
--    verification_status can only change through a reviewed action).
-- ---------------------------------------------------------

CREATE OR REPLACE FUNCTION admin_set_company_verification(
  p_company_id UUID,
  p_status verification_status,
  p_notes TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only admins can update verification status' USING ERRCODE = '42501';
  END IF;

  UPDATE mechanic_companies
  SET verification_status = p_status,
      verification_notes = p_notes,
      verified_at = NOW(),
      verified_by = auth.jwt()->>'email'
  WHERE id = p_company_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Company % not found', p_company_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_set_company_verification(UUID, verification_status, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION admin_set_document_verification(
  p_document_id UUID,
  p_status verification_status,
  p_reason TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only admins can update document verification' USING ERRCODE = '42501';
  END IF;

  UPDATE company_documents
  SET verified = p_status,
      rejection_reason = CASE WHEN p_status = 'rejected' THEN p_reason ELSE NULL END
  WHERE id = p_document_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Document % not found', p_document_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_set_document_verification(UUID, verification_status, TEXT) TO authenticated;
