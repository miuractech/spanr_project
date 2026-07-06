-- =====================================================
-- Fix all RLS policies broken for phone-OTP owners
-- Old policies checked staff.email = auth.jwt()->>'email'
-- which is NULL for phone auth users.
-- user_company_id() already handles both auth paths
-- (updated in 040), so we simply replace all inline
-- email checks with user_company_id() calls.
-- =====================================================

-- mechanic_companies: staff update
DROP POLICY IF EXISTS "Company staff can update their company" ON mechanic_companies;
CREATE POLICY "Company staff can update their company"
  ON mechanic_companies FOR UPDATE
  TO authenticated
  USING (id = user_company_id());

-- services: staff manage
DROP POLICY IF EXISTS "Company staff can manage their services" ON services;
CREATE POLICY "Company staff can manage their services"
  ON services FOR ALL
  TO authenticated
  USING (company_id = user_company_id())
  WITH CHECK (company_id = user_company_id());

-- plans: staff manage
DROP POLICY IF EXISTS "Company staff can manage their plans" ON plans;
CREATE POLICY "Company staff can manage their plans"
  ON plans FOR ALL
  TO authenticated
  USING (company_id = user_company_id())
  WITH CHECK (company_id = user_company_id());

-- plan sub-tables: staff manage
DROP POLICY IF EXISTS "Company staff can manage plan fuel types" ON plan_fuel_types;
CREATE POLICY "Company staff can manage plan fuel types"
  ON plan_fuel_types FOR ALL
  TO authenticated
  USING (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()));

DROP POLICY IF EXISTS "Company staff can manage plan features" ON plan_features;
CREATE POLICY "Company staff can manage plan features"
  ON plan_features FOR ALL
  TO authenticated
  USING (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()));

DROP POLICY IF EXISTS "Company staff can manage plan faqs" ON plan_faqs;
CREATE POLICY "Company staff can manage plan faqs"
  ON plan_faqs FOR ALL
  TO authenticated
  USING (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()));

DROP POLICY IF EXISTS "Company staff can manage plan service outcomes" ON plan_service_outcomes;
CREATE POLICY "Company staff can manage plan service outcomes"
  ON plan_service_outcomes FOR ALL
  TO authenticated
  USING (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()));

DROP POLICY IF EXISTS "Company staff can manage plan additional services" ON plan_additional_services;
CREATE POLICY "Company staff can manage plan additional services"
  ON plan_additional_services FOR ALL
  TO authenticated
  USING (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()));

DROP POLICY IF EXISTS "Company staff can manage plan steps" ON plan_steps;
CREATE POLICY "Company staff can manage plan steps"
  ON plan_steps FOR ALL
  TO authenticated
  USING (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()))
  WITH CHECK (plan_id IN (SELECT id FROM plans WHERE company_id = user_company_id()));

-- orders: staff view + update
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

-- payments: staff view
DROP POLICY IF EXISTS "Company staff can view their company payments" ON payments;
CREATE POLICY "Company staff can view their company payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

-- order_before_images: staff view
DROP POLICY IF EXISTS "Company staff can view their company order before images" ON order_before_images;
CREATE POLICY "Company staff can view their company order before images"
  ON order_before_images FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

-- order_after_images: staff view + insert
DROP POLICY IF EXISTS "Company staff can view their company order after images" ON order_after_images;
CREATE POLICY "Company staff can view their company order after images"
  ON order_after_images FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

DROP POLICY IF EXISTS "Company staff can insert after images" ON order_after_images;
CREATE POLICY "Company staff can insert after images"
  ON order_after_images FOR INSERT
  TO authenticated
  WITH CHECK (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

-- order_history: staff view
DROP POLICY IF EXISTS "Company staff can view their company order history" ON order_history;
CREATE POLICY "Company staff can view their company order history"
  ON order_history FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

-- company_documents: all 4 operations
DROP POLICY IF EXISTS "Staff can view own company documents" ON company_documents;
CREATE POLICY "Staff can view own company documents"
  ON company_documents FOR SELECT
  TO authenticated
  USING (company_id = user_company_id());

DROP POLICY IF EXISTS "Staff can insert own company documents" ON company_documents;
CREATE POLICY "Staff can insert own company documents"
  ON company_documents FOR INSERT
  TO authenticated
  WITH CHECK (company_id = user_company_id());

DROP POLICY IF EXISTS "Staff can update own company documents" ON company_documents;
CREATE POLICY "Staff can update own company documents"
  ON company_documents FOR UPDATE
  TO authenticated
  USING (company_id = user_company_id());

DROP POLICY IF EXISTS "Staff can delete own company documents" ON company_documents;
CREATE POLICY "Staff can delete own company documents"
  ON company_documents FOR DELETE
  TO authenticated
  USING (company_id = user_company_id());

-- order_assignments: staff view + manage
DROP POLICY IF EXISTS "Company staff can view order assignments" ON order_assignments;
CREATE POLICY "Company staff can view order assignments"
  ON order_assignments FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );

DROP POLICY IF EXISTS "Company staff can manage order assignments" ON order_assignments;
CREATE POLICY "Company staff can manage order assignments"
  ON order_assignments FOR ALL
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  )
  WITH CHECK (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
  );
