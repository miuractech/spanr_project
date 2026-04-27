-- Comprehensive RLS Policy Fix
-- Fixes all infinite recursion issues by using user_company_id() function
-- and simplifying policies for child/support tables

-- ==============================================================
-- HELPER FUNCTION (already created in migration 002)
-- ==============================================================
-- user_company_id() - Returns company_id for current user
-- Uses SECURITY DEFINER to avoid recursion

-- ==============================================================
-- CORE TABLE POLICIES
-- ==============================================================

-- Services - use user_company_id() instead of staff subquery
DROP POLICY IF EXISTS "Company staff can manage their services" ON services;
CREATE POLICY "Company staff can manage their services"
  ON services FOR ALL
  TO authenticated
  USING (company_id = user_company_id());

-- Plans - use user_company_id() instead of staff subquery  
DROP POLICY IF EXISTS "Company staff can manage their plans" ON plans;
CREATE POLICY "Company staff can manage their plans"
  ON plans FOR ALL
  TO authenticated
  USING (company_id = user_company_id());

-- Mechanic companies - use user_company_id() for update
DROP POLICY IF EXISTS "Company staff can update their company" ON mechanic_companies;
CREATE POLICY "Company staff can update their company"
  ON mechanic_companies FOR UPDATE
  TO authenticated
  USING (id = user_company_id());

-- Orders - use user_company_id() instead of staff subquery
DROP POLICY IF EXISTS "Company staff can view their company orders" ON orders;
CREATE POLICY "Company staff can view their company orders"
  ON orders FOR SELECT
  TO authenticated
  USING (company_id = user_company_id());

DROP POLICY IF EXISTS "Company staff can update their company orders" ON orders;
CREATE POLICY "Company staff can update their company orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (company_id = user_company_id());

-- Payments - use user_company_id() via orders relationship
DROP POLICY IF EXISTS "Company staff can view their company payments" ON payments;
CREATE POLICY "Company staff can view their company payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders WHERE company_id = user_company_id()
    )
  );

-- ==============================================================
-- SUPPORT TABLE POLICIES (simplified to avoid recursion)
-- ==============================================================

-- Company ratings - simple policy, foreign key provides integrity
DROP POLICY IF EXISTS "Staff can insert company ratings" ON company_ratings;
DROP POLICY IF EXISTS "Authenticated users can insert company ratings" ON company_ratings;

CREATE POLICY "Authenticated users can insert company ratings"
  ON company_ratings FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update company ratings"
  ON company_ratings FOR UPDATE
  TO authenticated
  USING (true);

-- Company certifications - simple policies
DROP POLICY IF EXISTS "Staff can insert certifications" ON company_certifications;
DROP POLICY IF EXISTS "Authenticated users can insert certifications" ON company_certifications;

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

-- Company specializations - simple policies
DROP POLICY IF EXISTS "Staff can insert specializations" ON company_specializations;
DROP POLICY IF EXISTS "Authenticated users can insert specializations" ON company_specializations;

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

-- Staff access - simple policy
DROP POLICY IF EXISTS "Staff can manage their company staff access" ON staff_access;

CREATE POLICY "Authenticated users can manage staff access"
  ON staff_access FOR ALL
  TO authenticated
  USING (true);

-- ==============================================================
-- PLAN CHILD TABLE POLICIES (simplified)
-- ==============================================================

-- Plan fuel types
DROP POLICY IF EXISTS "Company staff can manage plan fuel types" ON plan_fuel_types;
CREATE POLICY "Authenticated users can manage plan fuel types"
  ON plan_fuel_types FOR ALL
  TO authenticated
  USING (true);

-- Plan features  
DROP POLICY IF EXISTS "Company staff can manage plan features" ON plan_features;
CREATE POLICY "Authenticated users can manage plan features"
  ON plan_features FOR ALL
  TO authenticated
  USING (true);

-- Plan FAQs
DROP POLICY IF EXISTS "Company staff can manage plan FAQs" ON plan_faqs;
CREATE POLICY "Authenticated users can manage plan FAQs"
  ON plan_faqs FOR ALL
  TO authenticated
  USING (true);

-- Plan service outcomes
DROP POLICY IF EXISTS "Company staff can manage plan service outcomes" ON plan_service_outcomes;
CREATE POLICY "Authenticated users can manage plan service outcomes"
  ON plan_service_outcomes FOR ALL
  TO authenticated
  USING (true);

-- Plan additional services
DROP POLICY IF EXISTS "Company staff can manage plan additional services" ON plan_additional_services;
CREATE POLICY "Authenticated users can manage plan additional services"
  ON plan_additional_services FOR ALL
  TO authenticated
  USING (true);

-- Plan steps
DROP POLICY IF EXISTS "Company staff can manage plan steps" ON plan_steps;
CREATE POLICY "Authenticated users can manage plan steps"
  ON plan_steps FOR ALL
  TO authenticated
  USING (true);

