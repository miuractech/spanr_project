-- =====================================================
-- Super Admin approval desk
--
-- 1. Helper so catalog tables only leak verified shops
-- 2. Audit log for approve/reject
-- 3. Re-upload of a KYC file resets that doc (and a
--    rejected/verified shop) back to pending
-- 4. Company Verify RPC requires all mandatory docs approved
-- =====================================================

CREATE OR REPLACE FUNCTION public.company_is_verified(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM mechanic_companies
    WHERE id = p_company_id
      AND verification_status = 'verified'
  );
$$;

GRANT EXECUTE ON FUNCTION public.company_is_verified(UUID) TO anon, authenticated;

-- ---------------------------------------------------------
-- Public catalog: verified shops only
-- (staff FOR ALL policies are unchanged and still apply)
-- ---------------------------------------------------------

DROP POLICY IF EXISTS "Anyone can view services" ON services;
DROP POLICY IF EXISTS "Public can view verified shop services" ON services;
CREATE POLICY "Public can view verified shop services"
  ON services FOR SELECT
  TO public
  USING (company_is_verified(company_id));

DROP POLICY IF EXISTS "Anyone can view plans" ON plans;
DROP POLICY IF EXISTS "Public can view verified shop plans" ON plans;
CREATE POLICY "Public can view verified shop plans"
  ON plans FOR SELECT
  TO public
  USING (company_is_verified(company_id));

DROP POLICY IF EXISTS "Anyone can view plan fuel types" ON plan_fuel_types;
DROP POLICY IF EXISTS "Public can view verified shop plan fuel types" ON plan_fuel_types;
CREATE POLICY "Public can view verified shop plan fuel types"
  ON plan_fuel_types FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_fuel_types.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Anyone can view plan features" ON plan_features;
DROP POLICY IF EXISTS "Public can view verified shop plan features" ON plan_features;
CREATE POLICY "Public can view verified shop plan features"
  ON plan_features FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_features.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Anyone can view plan FAQs" ON plan_faqs;
DROP POLICY IF EXISTS "Public can view verified shop plan faqs" ON plan_faqs;
CREATE POLICY "Public can view verified shop plan faqs"
  ON plan_faqs FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_faqs.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Anyone can view plan service outcomes" ON plan_service_outcomes;
DROP POLICY IF EXISTS "Public can view verified shop plan outcomes" ON plan_service_outcomes;
CREATE POLICY "Public can view verified shop plan outcomes"
  ON plan_service_outcomes FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_service_outcomes.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Anyone can view plan additional services" ON plan_additional_services;
DROP POLICY IF EXISTS "Public can view verified shop plan extras" ON plan_additional_services;
CREATE POLICY "Public can view verified shop plan extras"
  ON plan_additional_services FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_additional_services.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Anyone can view plan steps" ON plan_steps;
DROP POLICY IF EXISTS "Public can view verified shop plan steps" ON plan_steps;
CREATE POLICY "Public can view verified shop plan steps"
  ON plan_steps FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_steps.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Customers can read job sections" ON job_sections;
DROP POLICY IF EXISTS "Public can view verified shop job sections" ON job_sections;
CREATE POLICY "Public can view verified shop job sections"
  ON job_sections FOR SELECT
  TO public
  USING (company_is_verified(company_id));

DROP POLICY IF EXISTS "Customers can read job catalog" ON job_catalog;
DROP POLICY IF EXISTS "Public can view verified shop job catalog" ON job_catalog;
CREATE POLICY "Public can view verified shop job catalog"
  ON job_catalog FOR SELECT
  TO public
  USING (company_is_verified(company_id));

DROP POLICY IF EXISTS "Customers can read plan included jobs" ON plan_included_jobs;
DROP POLICY IF EXISTS "Public can view verified shop plan jobs" ON plan_included_jobs;
CREATE POLICY "Public can view verified shop plan jobs"
  ON plan_included_jobs FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM plans p
      WHERE p.id = plan_included_jobs.plan_id
        AND company_is_verified(p.company_id)
    )
  );

DROP POLICY IF EXISTS "Anyone can view company ratings" ON company_ratings;
DROP POLICY IF EXISTS "Public can view verified shop ratings" ON company_ratings;
CREATE POLICY "Public can view verified shop ratings"
  ON company_ratings FOR SELECT
  TO public
  USING (company_is_verified(company_id));

DROP POLICY IF EXISTS "Anyone can view company certifications" ON company_certifications;
DROP POLICY IF EXISTS "Public can view verified shop certifications" ON company_certifications;
CREATE POLICY "Public can view verified shop certifications"
  ON company_certifications FOR SELECT
  TO public
  USING (company_is_verified(company_id));

DROP POLICY IF EXISTS "Anyone can view company specializations" ON company_specializations;
DROP POLICY IF EXISTS "Public can view verified shop specializations" ON company_specializations;
CREATE POLICY "Public can view verified shop specializations"
  ON company_specializations FOR SELECT
  TO public
  USING (company_is_verified(company_id));

-- ---------------------------------------------------------
-- Audit log
-- ---------------------------------------------------------

CREATE TABLE IF NOT EXISTS admin_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID,
  actor_email TEXT,
  company_id UUID REFERENCES mechanic_companies(id) ON DELETE SET NULL,
  document_id UUID,
  action TEXT NOT NULL,
  from_status TEXT,
  to_status TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_audit_log_company ON admin_audit_log(company_id, created_at DESC);

ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view audit log" ON admin_audit_log;
CREATE POLICY "Admins can view audit log"
  ON admin_audit_log FOR SELECT
  TO authenticated
  USING (is_super_admin());

-- ---------------------------------------------------------
-- Re-upload resets document + shop (file change only)
-- ---------------------------------------------------------

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
        verified_by = NULL
    WHERE id = NEW.company_id
      AND verification_status IN ('rejected', 'verified');
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_kyc_document_file_change ON company_documents;
CREATE TRIGGER trg_kyc_document_file_change
  BEFORE INSERT OR UPDATE ON company_documents
  FOR EACH ROW
  EXECUTE FUNCTION public.on_kyc_document_file_change();

-- ---------------------------------------------------------
-- RPCs: mandatory docs + audit
-- ---------------------------------------------------------

CREATE OR REPLACE FUNCTION public.kyc_mandatory_docs_verified(p_company_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT NOT EXISTS (
    SELECT 1
    FROM unnest(ARRAY[
      'aadhaar_front',
      'aadhaar_back',
      'personal_pan',
      'bank_passbook',
      'home_address_proof',
      'home_utility_bill',
      'shop_utility_bill'
    ]::document_type[]) AS required(doc_type)
    WHERE NOT EXISTS (
      SELECT 1
      FROM company_documents d
      WHERE d.company_id = p_company_id
        AND d.document_type = required.doc_type
        AND d.verified = 'verified'
    )
  );
$$;

GRANT EXECUTE ON FUNCTION public.kyc_mandatory_docs_verified(UUID) TO authenticated;

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

  IF p_status = 'verified' AND NOT kyc_mandatory_docs_verified(p_company_id) THEN
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

CREATE OR REPLACE FUNCTION public.admin_set_document_verification(
  p_document_id UUID,
  p_status verification_status,
  p_reason TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_from verification_status;
  v_company UUID;
BEGIN
  IF NOT is_super_admin() THEN
    RAISE EXCEPTION 'Only admins can update document verification' USING ERRCODE = '42501';
  END IF;

  SELECT verified, company_id INTO v_from, v_company
  FROM company_documents
  WHERE id = p_document_id;

  IF v_company IS NULL THEN
    RAISE EXCEPTION 'Document % not found', p_document_id;
  END IF;

  IF p_status = 'rejected' AND (p_reason IS NULL OR length(trim(p_reason)) = 0) THEN
    RAISE EXCEPTION 'A rejection reason is required for this document';
  END IF;

  UPDATE company_documents
  SET verified = p_status,
      rejection_reason = CASE WHEN p_status = 'rejected' THEN p_reason ELSE NULL END
  WHERE id = p_document_id;

  INSERT INTO admin_audit_log (
    actor_id, actor_email, company_id, document_id, action, from_status, to_status, notes
  )
  VALUES (
    auth.uid(),
    auth.jwt()->>'email',
    v_company,
    p_document_id,
    'document_verification',
    v_from::TEXT,
    p_status::TEXT,
    p_reason
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_set_document_verification(UUID, verification_status, TEXT) TO authenticated;
