-- Missing write policies for company_certifications and company_specializations
-- (initial schema only created SELECT policies; migrations 003/004 were not applied remotely)

-- company_certifications
CREATE POLICY "Staff can insert own company certifications"
  ON company_certifications FOR INSERT
  TO authenticated
  WITH CHECK (company_id = user_company_id());

CREATE POLICY "Staff can update own company certifications"
  ON company_certifications FOR UPDATE
  TO authenticated
  USING (company_id = user_company_id());

CREATE POLICY "Staff can delete own company certifications"
  ON company_certifications FOR DELETE
  TO authenticated
  USING (company_id = user_company_id());

-- company_specializations
CREATE POLICY "Staff can insert own company specializations"
  ON company_specializations FOR INSERT
  TO authenticated
  WITH CHECK (company_id = user_company_id());

CREATE POLICY "Staff can update own company specializations"
  ON company_specializations FOR UPDATE
  TO authenticated
  USING (company_id = user_company_id());

CREATE POLICY "Staff can delete own company specializations"
  ON company_specializations FOR DELETE
  TO authenticated
  USING (company_id = user_company_id());
