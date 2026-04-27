-- =====================================================
-- SPANR Platform - Common Queries
-- Frequently used queries for the application
-- =====================================================

-- =====================================================
-- COMPANY QUERIES
-- =====================================================

-- Get all companies with ratings and counts
SELECT 
  mc.*,
  cr.rating,
  cr.count as review_count,
  COUNT(DISTINCT o.id) as total_orders,
  COUNT(DISTINCT s.id) as services_count
FROM mechanic_companies mc
LEFT JOIN company_ratings cr ON mc.id = cr.company_id
LEFT JOIN orders o ON mc.id = o.company_id
LEFT JOIN services s ON mc.id = s.company_id
GROUP BY mc.id, cr.rating, cr.count
ORDER BY cr.rating DESC;

-- Get company by ID with all related data
SELECT * FROM company_profiles WHERE id = 'company-uuid-here';

-- Search companies by city
SELECT * FROM company_profiles 
WHERE city ILIKE '%Mumbai%'
ORDER BY rating DESC;

-- Get top rated companies
SELECT * FROM company_profiles 
WHERE ratings_count > 0
ORDER BY rating DESC, ratings_count DESC
LIMIT 10;

-- =====================================================
-- SERVICE & PLAN QUERIES
-- =====================================================

-- Get all services by company
SELECT 
  s.*,
  COUNT(p.id) as plans_count
FROM services s
LEFT JOIN plans p ON s.id = p.service_id
WHERE s.company_id = 'company-uuid-here'
GROUP BY s.id;

-- Get plan with all details
SELECT 
  p.*,
  s.name as service_name,
  s.category,
  mc.company_name,
  json_agg(DISTINCT pft.fuel_type) as fuel_types,
  json_agg(DISTINCT jsonb_build_object(
    'feature', pf.feature,
    'order', pf.display_order
  )) FILTER (WHERE pf.feature IS NOT NULL) as features
FROM plans p
JOIN services s ON p.service_id = s.id
JOIN mechanic_companies mc ON p.company_id = mc.id
LEFT JOIN plan_fuel_types pft ON p.id = pft.plan_id
LEFT JOIN plan_features pf ON p.id = pf.plan_id
WHERE p.id = 'plan-uuid-here'
GROUP BY p.id, s.name, s.category, mc.company_name;

-- Get all plans for a service category
SELECT 
  p.*,
  mc.company_name,
  mc.city,
  cr.rating
FROM plans p
JOIN services s ON p.service_id = s.id
JOIN mechanic_companies mc ON p.company_id = mc.id
LEFT JOIN company_ratings cr ON mc.id = cr.company_id
WHERE s.category = 'car'
AND p.vehicle_type = 'car'
ORDER BY p.base_price ASC;

-- Search plans by vehicle type and location
SELECT 
  p.*,
  s.name as service_name,
  mc.company_name,
  mc.city,
  cr.rating
FROM plans p
JOIN services s ON p.service_id = s.id
JOIN mechanic_companies mc ON p.company_id = mc.id
LEFT JOIN company_ratings cr ON mc.id = cr.company_id
WHERE p.vehicle_type = 'car'
AND p.location_type = 'in_premise'
AND mc.city = 'Mumbai'
ORDER BY cr.rating DESC, p.base_price ASC;

-- =====================================================
-- ORDER QUERIES
-- =====================================================

-- Get all orders with full details
SELECT * FROM order_details
ORDER BY order_date DESC;

-- Get user's orders
SELECT * FROM order_details 
WHERE user_id = (SELECT id FROM users WHERE user_id = 'firebase-auth-uid')
ORDER BY order_date DESC;

-- Get company's orders
SELECT * FROM order_details 
WHERE company_id = 'company-uuid-here'
ORDER BY scheduled_service_date DESC;

-- Get pending orders for a company
SELECT * FROM order_details 
WHERE company_id = 'company-uuid-here'
AND status = 'pending'
ORDER BY scheduled_service_date ASC;

-- Get today's scheduled services for a company
SELECT * FROM order_details 
WHERE company_id = 'company-uuid-here'
AND DATE(scheduled_service_date) = CURRENT_DATE
AND status IN ('confirmed', 'in_progress')
ORDER BY scheduled_service_date ASC;

-- Get order by ID with all details
SELECT * FROM order_details 
WHERE id = 'order-uuid-here';

-- Get orders by status
SELECT 
  o.*,
  u.name as customer_name,
  u.phone as customer_phone,
  v.make,
  v.model,
  p.name as plan_name
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN vehicles v ON o.vehicle_id = v.id
JOIN plans p ON o.plan_id = p.id
WHERE o.company_id = 'company-uuid-here'
AND o.status = 'confirmed'
ORDER BY o.scheduled_service_date ASC;

-- =====================================================
-- USER & VEHICLE QUERIES
-- =====================================================

-- Get user with all vehicles
SELECT 
  u.*,
  json_agg(v.*) as vehicles
FROM users u
LEFT JOIN vehicles v ON u.id = v.user_id
WHERE u.user_id = 'firebase-auth-uid'
GROUP BY u.id;

-- Get user's order history
SELECT 
  o.*,
  p.name as plan_name,
  s.name as service_name,
  mc.company_name,
  v.make,
  v.model,
  pay.status as payment_status,
  pay.amount as payment_amount
FROM orders o
JOIN plans p ON o.plan_id = p.id
JOIN services s ON p.service_id = s.id
JOIN mechanic_companies mc ON o.company_id = mc.id
JOIN vehicles v ON o.vehicle_id = v.id
LEFT JOIN payments pay ON o.id = pay.order_id
WHERE o.user_id = (SELECT id FROM users WHERE user_id = 'firebase-auth-uid')
ORDER BY o.order_date DESC;

-- =====================================================
-- PAYMENT QUERIES
-- =====================================================

-- Get payment details for an order
SELECT 
  p.*,
  o.order_date,
  o.status as order_status,
  pl.name as plan_name,
  mc.company_name
FROM payments p
JOIN orders o ON p.order_id = o.id
JOIN plans pl ON o.plan_id = pl.id
JOIN mechanic_companies mc ON o.company_id = mc.id
WHERE p.order_id = 'order-uuid-here';

-- Get company's revenue summary
SELECT 
  mc.company_name,
  COUNT(DISTINCT o.id) as total_orders,
  SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END) as total_revenue,
  SUM(CASE WHEN o.status = 'completed' THEN p.amount ELSE 0 END) as completed_revenue,
  COUNT(CASE WHEN p.status = 'unpaid' THEN 1 END) as pending_payments
FROM mechanic_companies mc
LEFT JOIN orders o ON mc.id = o.company_id
LEFT JOIN payments p ON o.id = p.order_id
WHERE mc.id = 'company-uuid-here'
GROUP BY mc.id, mc.company_name;

-- Get monthly revenue for a company
SELECT 
  DATE_TRUNC('month', p.paid_at) as month,
  COUNT(DISTINCT o.id) as orders_count,
  SUM(p.amount) as revenue
FROM payments p
JOIN orders o ON p.order_id = o.id
WHERE o.company_id = 'company-uuid-here'
AND p.status = 'paid'
AND p.paid_at >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', p.paid_at)
ORDER BY month DESC;

-- =====================================================
-- ANALYTICS QUERIES
-- =====================================================

-- Most popular plans by company
SELECT 
  p.name,
  p.base_price,
  COUNT(o.id) as order_count,
  AVG(p.base_price) as avg_price
FROM plans p
LEFT JOIN orders o ON p.id = o.plan_id
WHERE p.company_id = 'company-uuid-here'
GROUP BY p.id, p.name, p.base_price
ORDER BY order_count DESC;

-- Customer acquisition by month
SELECT 
  DATE_TRUNC('month', created_at) as month,
  COUNT(*) as new_customers
FROM users
WHERE created_at >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- Order status distribution for a company
SELECT 
  status,
  COUNT(*) as count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM orders
WHERE company_id = 'company-uuid-here'
GROUP BY status
ORDER BY count DESC;

-- Vehicle type distribution
SELECT 
  vehicle_type,
  COUNT(*) as order_count
FROM orders o
JOIN plans p ON o.plan_id = p.id
WHERE o.company_id = 'company-uuid-here'
GROUP BY vehicle_type;

-- =====================================================
-- STAFF QUERIES
-- =====================================================

-- Get company staff with permissions
SELECT 
  s.*,
  json_agg(sa.access_permission) as permissions
FROM staff s
LEFT JOIN staff_access sa ON s.id = sa.staff_id
WHERE s.company_id = 'company-uuid-here'
GROUP BY s.id
ORDER BY s.enabled DESC, s.name ASC;

-- Check if staff has specific permission
SELECT EXISTS (
  SELECT 1 FROM staff s
  JOIN staff_access sa ON s.id = sa.staff_id
  WHERE s.email = 'staff-email@example.com'
  AND s.company_id = 'company-uuid-here'
  AND s.enabled = true
  AND sa.access_permission = 'orders.write'
) as has_permission;

-- =====================================================
-- SEARCH QUERIES
-- =====================================================

-- Full text search for companies
SELECT 
  mc.*,
  cr.rating,
  ts_rank(
    to_tsvector('english', mc.company_name || ' ' || mc.city || ' ' || COALESCE(mc.landmark, '')),
    to_tsquery('english', 'search-term-here')
  ) as rank
FROM mechanic_companies mc
LEFT JOIN company_ratings cr ON mc.id = cr.company_id
WHERE to_tsvector('english', mc.company_name || ' ' || mc.city || ' ' || COALESCE(mc.landmark, '')) 
  @@ to_tsquery('english', 'search-term-here')
ORDER BY rank DESC, cr.rating DESC;

-- Search plans by keywords
SELECT DISTINCT
  p.*,
  s.name as service_name,
  mc.company_name,
  mc.city
FROM plans p
JOIN services s ON p.service_id = s.id
JOIN mechanic_companies mc ON p.company_id = mc.id
LEFT JOIN plan_features pf ON p.id = pf.plan_id
WHERE 
  p.name ILIKE '%oil%'
  OR s.name ILIKE '%oil%'
  OR pf.feature ILIKE '%oil%'
ORDER BY p.base_price ASC;

-- =====================================================
-- DASHBOARD QUERIES
-- =====================================================

-- Company dashboard statistics
SELECT 
  COUNT(DISTINCT o.id) as total_orders,
  COUNT(DISTINCT CASE WHEN o.status = 'pending' THEN o.id END) as pending_orders,
  COUNT(DISTINCT CASE WHEN o.status = 'in_progress' THEN o.id END) as active_orders,
  COUNT(DISTINCT CASE WHEN o.status = 'completed' THEN o.id END) as completed_orders,
  COUNT(DISTINCT o.user_id) as total_customers,
  SUM(CASE WHEN p.status = 'paid' THEN p.amount ELSE 0 END) as total_revenue,
  AVG(CASE WHEN o.status = 'completed' THEN p.amount END) as avg_order_value
FROM orders o
LEFT JOIN payments p ON o.id = p.order_id
WHERE o.company_id = 'company-uuid-here';

-- Today's summary for a company
SELECT 
  COUNT(*) as today_services,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_today,
  COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress,
  COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as upcoming_today
FROM orders
WHERE company_id = 'company-uuid-here'
AND DATE(scheduled_service_date) = CURRENT_DATE;

