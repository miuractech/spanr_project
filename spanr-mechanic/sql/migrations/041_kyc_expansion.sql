-- =====================================================
-- KYC document type expansion
-- Mandatory: aadhaar_front, aadhaar_back, personal_pan,
--            bank_passbook, home_address_proof,
--            home_utility_bill, shop_utility_bill
-- Optional:  gst_certificate (already exists), firm_pan,
--            firm_registration
-- Legacy (kept): pan_card, utility_bill
-- =====================================================

-- Add new enum values (IF NOT EXISTS requires Postgres 9.6+; use DO block)
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
