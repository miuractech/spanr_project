-- Helper queries for company management

-- Get complete company profile
SELECT 
  mc.*,
  cr.count as ratings_count,
  cr.professionalism,
  cr.timeliness,
  cr.quality,
  cr.rating,
  COALESCE(
    json_agg(DISTINCT cc.certification_name) FILTER (WHERE cc.certification_name IS NOT NULL), 
    '[]'
  ) as certifications,
  COALESCE(
    json_agg(DISTINCT cs.specialization_name) FILTER (WHERE cs.specialization_name IS NOT NULL), 
    '[]'
  ) as specializations
FROM mechanic_companies mc
LEFT JOIN company_ratings cr ON mc.id = cr.company_id
LEFT JOIN company_certifications cc ON mc.id = cc.company_id
LEFT JOIN company_specializations cs ON mc.id = cs.company_id
WHERE mc.id = 'company-uuid-here'
GROUP BY mc.id, cr.count, cr.professionalism, cr.timeliness, cr.quality, cr.rating;

-- Get company by staff email
SELECT mc.*
FROM mechanic_companies mc
JOIN staff s ON mc.id = s.company_id
WHERE s.email = 'staff@email.com' AND s.enabled = true;

