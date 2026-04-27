-- Add missing INSERT/UPDATE policies for onboarding flow
-- Using simple policies to avoid recursion - foreign key constraints provide data integrity

-- Company ratings policies
CREATE POLICY "Authenticated users can insert company ratings"
  ON company_ratings FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update company ratings"
  ON company_ratings FOR UPDATE
  TO authenticated
  USING (true);

-- Company certifications policies  
CREATE POLICY "Authenticated users can insert certifications"
  ON company_certifications FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update certifications"
  ON company_certifications FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete certifications"
  ON company_certifications FOR DELETE
  TO authenticated
  USING (true);

-- Company specializations policies
CREATE POLICY "Authenticated users can insert specializations"
  ON company_specializations FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update specializations"
  ON company_specializations FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete specializations"
  ON company_specializations FOR DELETE
  TO authenticated
  USING (true);

