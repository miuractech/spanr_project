-- =====================================================
-- SPANR Platform - Helper Functions
-- =====================================================

-- Get complete plan details with all related data
CREATE OR REPLACE FUNCTION get_plan_details(plan_uuid UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'plan', row_to_json(p.*),
    'service', row_to_json(s.*),
    'company', row_to_json(mc.*),
    'fuel_types', COALESCE((
      SELECT json_agg(pft.fuel_type)
      FROM plan_fuel_types pft
      WHERE pft.plan_id = plan_uuid
    ), '[]'),
    'features', COALESCE((
      SELECT json_agg(json_build_object(
        'id', pf.id,
        'feature', pf.feature,
        'display_order', pf.display_order
      ) ORDER BY pf.display_order)
      FROM plan_features pf
      WHERE pf.plan_id = plan_uuid
    ), '[]'),
    'faqs', COALESCE((
      SELECT json_agg(json_build_object(
        'id', pfq.id,
        'question', pfq.question,
        'answer', pfq.answer,
        'display_order', pfq.display_order
      ) ORDER BY pfq.display_order)
      FROM plan_faqs pfq
      WHERE pfq.plan_id = plan_uuid
    ), '[]'),
    'service_outcomes', COALESCE((
      SELECT json_agg(json_build_object(
        'id', pso.id,
        'title', pso.title,
        'image_url', pso.image_url,
        'description', pso.description,
        'display_order', pso.display_order
      ) ORDER BY pso.display_order)
      FROM plan_service_outcomes pso
      WHERE pso.plan_id = plan_uuid
    ), '[]'),
    'additional_services', COALESCE((
      SELECT json_agg(json_build_object(
        'id', pas.id,
        'service_name', pas.service_name,
        'display_order', pas.display_order
      ) ORDER BY pas.display_order)
      FROM plan_additional_services pas
      WHERE pas.plan_id = plan_uuid
    ), '[]'),
    'steps', COALESCE((
      SELECT json_agg(json_build_object(
        'id', ps.id,
        'step_description', ps.step_description,
        'display_order', ps.display_order
      ) ORDER BY ps.display_order)
      FROM plan_steps ps
      WHERE ps.plan_id = plan_uuid
    ), '[]')
  ) INTO result
  FROM plans p
  JOIN services s ON p.service_id = s.id
  JOIN mechanic_companies mc ON p.company_id = mc.id
  WHERE p.id = plan_uuid;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Get staff company ID by email
CREATE OR REPLACE FUNCTION get_staff_company_id(staff_email TEXT)
RETURNS UUID AS $$
DECLARE
  company_uuid UUID;
BEGIN
  SELECT company_id INTO company_uuid
  FROM staff
  WHERE email = staff_email AND enabled = true
  LIMIT 1;
  
  RETURN company_uuid;
END;
$$ LANGUAGE plpgsql;

-- Check if user is staff member of a company
CREATE OR REPLACE FUNCTION is_company_staff(company_uuid UUID, staff_email TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  is_staff BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1 FROM staff
    WHERE company_id = company_uuid 
    AND email = staff_email 
    AND enabled = true
  ) INTO is_staff;
  
  RETURN is_staff;
END;
$$ LANGUAGE plpgsql;

