-- Existing shops were knocked to pending/rejected when the KYC pack shipped
-- (document trigger + "cannot verify until 7 docs"). Restore operating shops
-- and stop verified shops from being unlisted on a file upload.

CREATE OR REPLACE FUNCTION public.shop_is_pre_kyc_operating(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM mechanic_companies c
    WHERE c.id = p_company_id
      AND (
        c.created_at < TIMESTAMPTZ '2026-09-27 00:00:00+00'
        OR EXISTS (SELECT 1 FROM orders o WHERE o.company_id = c.id)
        OR EXISTS (SELECT 1 FROM plans p WHERE p.company_id = c.id)
        OR EXISTS (SELECT 1 FROM services s WHERE s.company_id = c.id)
      )
  );
$$;

GRANT EXECUTE ON FUNCTION public.shop_is_pre_kyc_operating(UUID) TO authenticated;

UPDATE mechanic_companies c
SET
  verification_status = 'verified',
  verification_notes = NULL,
  verified_at = COALESCE(c.verified_at, NOW()),
  verified_by = COALESCE(c.verified_by, 'system:053-restore-operating-shop')
WHERE c.verification_status IN ('pending', 'rejected')
  AND public.shop_is_pre_kyc_operating(c.id);

CREATE OR REPLACE FUNCTION public.on_kyc_document_file_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT'
     OR NEW.file_url IS DISTINCT FROM OLD.file_url
     OR NEW.file_name IS DISTINCT FROM OLD.file_name THEN
    NEW.verified := 'pending';
    NEW.rejection_reason := NULL;

    UPDATE mechanic_companies
    SET verification_status = 'pending',
        verified_at = NULL,
        verified_by = NULL,
        verification_notes = NULL
    WHERE id = NEW.company_id
      AND verification_status = 'rejected';
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_set_company_verification(
  p_company_id UUID,
  p_status verification_status,
  p_notes TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_from verification_status;
BEGIN
  IF NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only admins can update verification status' USING ERRCODE = '42501';
  END IF;

  SELECT verification_status INTO v_from
  FROM mechanic_companies
  WHERE id = p_company_id;

  IF v_from IS NULL THEN
    RAISE EXCEPTION 'Company % not found', p_company_id;
  END IF;

  IF p_status = 'verified'
     AND NOT kyc_mandatory_docs_verified(p_company_id)
     AND NOT shop_is_pre_kyc_operating(p_company_id) THEN
    RAISE EXCEPTION 'Cannot verify shop until all mandatory KYC documents are approved';
  END IF;

  IF p_status = 'rejected' AND (p_notes IS NULL OR length(trim(p_notes)) = 0) THEN
    RAISE EXCEPTION 'A rejection reason is required';
  END IF;

  UPDATE mechanic_companies
  SET verification_status = p_status,
      verification_notes = p_notes,
      verified_at = NOW(),
      verified_by = auth.jwt()->>'email'
  WHERE id = p_company_id;

  INSERT INTO admin_audit_log (actor_id, actor_email, company_id, action, from_status, to_status, notes)
  VALUES (
    auth.uid(),
    auth.jwt()->>'email',
    p_company_id,
    'company_verification',
    v_from::TEXT,
    p_status::TEXT,
    p_notes
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_set_company_verification(UUID, verification_status, TEXT) TO authenticated;
