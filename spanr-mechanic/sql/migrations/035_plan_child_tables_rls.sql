-- RLS for plan child tables (fuel types, features, FAQs, etc.)

CREATE OR REPLACE FUNCTION plan_belongs_to_user_company(p_plan_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM plans p
    WHERE p.id = p_plan_id
      AND p.company_id = user_company_id()
  );
$$;

GRANT EXECUTE ON FUNCTION plan_belongs_to_user_company(UUID) TO authenticated;

-- plan_fuel_types
DROP POLICY IF EXISTS "Authenticated users can manage plan fuel types" ON plan_fuel_types;
DROP POLICY IF EXISTS "Company staff can manage plan fuel types" ON plan_fuel_types;
CREATE POLICY "Company staff can manage plan fuel types"
  ON plan_fuel_types FOR ALL
  TO authenticated
  USING (plan_belongs_to_user_company(plan_id))
  WITH CHECK (plan_belongs_to_user_company(plan_id));

-- plan_features
DROP POLICY IF EXISTS "Authenticated users can manage plan features" ON plan_features;
DROP POLICY IF EXISTS "Company staff can manage plan features" ON plan_features;
CREATE POLICY "Company staff can manage plan features"
  ON plan_features FOR ALL
  TO authenticated
  USING (plan_belongs_to_user_company(plan_id))
  WITH CHECK (plan_belongs_to_user_company(plan_id));

-- plan_faqs
DROP POLICY IF EXISTS "Authenticated users can manage plan FAQs" ON plan_faqs;
DROP POLICY IF EXISTS "Company staff can manage plan FAQs" ON plan_faqs;
CREATE POLICY "Company staff can manage plan FAQs"
  ON plan_faqs FOR ALL
  TO authenticated
  USING (plan_belongs_to_user_company(plan_id))
  WITH CHECK (plan_belongs_to_user_company(plan_id));

-- plan_service_outcomes
DROP POLICY IF EXISTS "Authenticated users can manage plan service outcomes" ON plan_service_outcomes;
DROP POLICY IF EXISTS "Company staff can manage plan service outcomes" ON plan_service_outcomes;
CREATE POLICY "Company staff can manage plan service outcomes"
  ON plan_service_outcomes FOR ALL
  TO authenticated
  USING (plan_belongs_to_user_company(plan_id))
  WITH CHECK (plan_belongs_to_user_company(plan_id));

-- plan_additional_services
DROP POLICY IF EXISTS "Authenticated users can manage plan additional services" ON plan_additional_services;
DROP POLICY IF EXISTS "Company staff can manage plan additional services" ON plan_additional_services;
CREATE POLICY "Company staff can manage plan additional services"
  ON plan_additional_services FOR ALL
  TO authenticated
  USING (plan_belongs_to_user_company(plan_id))
  WITH CHECK (plan_belongs_to_user_company(plan_id));

-- plan_steps
DROP POLICY IF EXISTS "Authenticated users can manage plan steps" ON plan_steps;
DROP POLICY IF EXISTS "Company staff can manage plan steps" ON plan_steps;
CREATE POLICY "Company staff can manage plan steps"
  ON plan_steps FOR ALL
  TO authenticated
  USING (plan_belongs_to_user_company(plan_id))
  WITH CHECK (plan_belongs_to_user_company(plan_id));
