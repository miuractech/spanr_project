-- Owner can resubmit after Super Admin reject. Puts the shop in pending
-- so it appears on the admin desk. Also adds missing document_type values
-- if 041 never ran on this database.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'aadhaar_front' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'aadhaar_front';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'aadhaar_back' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'aadhaar_back';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'personal_pan' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'personal_pan';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'bank_passbook' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'bank_passbook';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'home_address_proof' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'home_address_proof';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'home_utility_bill' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'home_utility_bill';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'shop_utility_bill' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'shop_utility_bill';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'firm_pan' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'firm_pan';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'firm_registration' AND enumtypid = 'document_type'::regtype) THEN
    ALTER TYPE document_type ADD VALUE 'firm_registration';
  END IF;
END $$;

DROP POLICY IF EXISTS "Staff can update own company documents" ON company_documents;
CREATE POLICY "Staff can update own company documents"
  ON company_documents FOR UPDATE
  TO authenticated
  USING (company_id = user_company_id())
  WITH CHECK (company_id = user_company_id());

CREATE OR REPLACE FUNCTION public.owner_submit_kyc_for_review()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_company_id UUID;
BEGIN
  v_company_id := user_company_id();
  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'No shop found for this account';
  END IF;

  UPDATE mechanic_companies
  SET verification_status = 'pending',
      verification_notes = NULL,
      verified_at = NULL,
      verified_by = NULL
  WHERE id = v_company_id
    AND verification_status IN ('rejected', 'pending');
END;
$$;

GRANT EXECUTE ON FUNCTION public.owner_submit_kyc_for_review() TO authenticated;
