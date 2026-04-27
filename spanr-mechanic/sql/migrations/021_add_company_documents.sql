-- =====================================================
-- Company Documents for KYC / Verification
-- =====================================================

CREATE TYPE document_type AS ENUM ('gst_certificate', 'pan_card', 'utility_bill');
CREATE TYPE verification_status AS ENUM ('pending', 'verified', 'rejected');

CREATE TABLE company_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  document_type document_type NOT NULL,
  file_url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  verified verification_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, document_type)
);

-- Auto-update updated_at
CREATE TRIGGER update_company_documents_updated_at
  BEFORE UPDATE ON company_documents
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- RLS Policies
-- =====================================================

ALTER TABLE company_documents ENABLE ROW LEVEL SECURITY;

-- Staff can view their own company's documents
CREATE POLICY "Staff can view own company documents"
  ON company_documents FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM staff
      WHERE staff.company_id = company_documents.company_id
        AND staff.email = (auth.jwt() ->> 'email')
        AND staff.enabled = true
    )
  );

-- Staff can insert documents for their own company
CREATE POLICY "Staff can insert own company documents"
  ON company_documents FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM staff
      WHERE staff.company_id = company_documents.company_id
        AND staff.email = (auth.jwt() ->> 'email')
        AND staff.enabled = true
    )
  );

-- Staff can update (replace) their own company's documents
CREATE POLICY "Staff can update own company documents"
  ON company_documents FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM staff
      WHERE staff.company_id = company_documents.company_id
        AND staff.email = (auth.jwt() ->> 'email')
        AND staff.enabled = true
    )
  );

-- Staff can delete their own company's documents
CREATE POLICY "Staff can delete own company documents"
  ON company_documents FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM staff
      WHERE staff.company_id = company_documents.company_id
        AND staff.email = (auth.jwt() ->> 'email')
        AND staff.enabled = true
    )
  );

-- =====================================================
-- Storage Bucket: company-documents (private)
-- =====================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('company-documents', 'company-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Authenticated staff can upload to their company's folder
CREATE POLICY "Staff can upload company documents"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'company-documents'
    AND auth.role() = 'authenticated'
  );

-- Staff can read their own company's documents
CREATE POLICY "Staff can read own company documents"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'company-documents'
    AND auth.role() = 'authenticated'
  );

-- Staff can update (replace) their own uploads
CREATE POLICY "Staff can update company documents"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'company-documents'
    AND auth.role() = 'authenticated'
  );

-- Staff can delete their own uploads
CREATE POLICY "Staff can delete company documents"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'company-documents'
    AND auth.role() = 'authenticated'
  );
