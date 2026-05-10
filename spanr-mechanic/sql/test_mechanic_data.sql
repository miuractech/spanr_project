-- =====================================================
-- SPANR Platform - Test Mechanic Data
-- Additional mechanic for user app testing
-- =====================================================

-- New mechanic company
INSERT INTO mechanic_companies (
  id,
  company_name,
  address_line_1,
  address_line_2,
  landmark,
  city,
  state,
  phone_number,
  pincode,
  phone,
  email,
  logo,
  latitude,
  longitude
) VALUES 
(
  '660e8400-e29b-41d4-a716-446655440010',
  'AutoFix Pro Garage',
  '42 Industrial Area',
  'Phase 2, Sector 18',
  'Near DLF Mall',
  'Delhi',
  'Delhi NCR',
  '+919876543220',
  '110001',
  '+919876543220',
  'contact@autofixpro.com',
  'https://example.com/logos/autofix-pro.png',
  28.6139,
  77.2090
);

-- Company ratings
INSERT INTO company_ratings (company_id, count, professionalism, timeliness, quality, rating)
VALUES 
('660e8400-e29b-41d4-a716-446655440010', 342, 4.7, 4.6, 4.8, 4.7);

-- Company certifications
INSERT INTO company_certifications (company_id, certification_name)
VALUES 
('660e8400-e29b-41d4-a716-446655440010', 'ISO 9001:2015'),
('660e8400-e29b-41d4-a716-446655440010', 'Authorized Service Center - Hyundai'),
('660e8400-e29b-41d4-a716-446655440010', 'Authorized Service Center - Toyota'),
('660e8400-e29b-41d4-a716-446655440010', 'ASE Certified Technicians');

-- Company specializations
INSERT INTO company_specializations (company_id, specialization_name)
VALUES 
('660e8400-e29b-41d4-a716-446655440010', 'Engine Diagnostics'),
('660e8400-e29b-41d4-a716-446655440010', 'Transmission Repair'),
('660e8400-e29b-41d4-a716-446655440010', 'AC Service & Repair'),
('660e8400-e29b-41d4-a716-446655440010', 'Brake Service'),
('660e8400-e29b-41d4-a716-446655440010', 'Suspension Work'),
('660e8400-e29b-41d4-a716-446655440010', 'Car Detailing');

-- Staff
INSERT INTO staff (id, company_id, email, name, enabled)
VALUES 
('770e8400-e29b-41d4-a716-446655440010', '660e8400-e29b-41d4-a716-446655440010', 'admin@autofixpro.com', 'Rahul Sharma', true);

-- Staff access permissions
INSERT INTO staff_access (staff_id, access_permission)
VALUES 
('770e8400-e29b-41d4-a716-446655440010', 'orders.read'),
('770e8400-e29b-41d4-a716-446655440010', 'orders.write'),
('770e8400-e29b-41d4-a716-446655440010', 'staff.manage'),
('770e8400-e29b-41d4-a716-446655440010', 'services.manage'),
('770e8400-e29b-41d4-a716-446655440010', 'company.manage');

-- Services
INSERT INTO services (id, company_id, name, category)
VALUES 
('880e8400-e29b-41d4-a716-446655440010', '660e8400-e29b-41d4-a716-446655440010', 'Regular Car Service', 'car'),
('880e8400-e29b-41d4-a716-446655440011', '660e8400-e29b-41d4-a716-446655440010', 'Premium Car Service', 'car'),
('880e8400-e29b-41d4-a716-446655440012', '660e8400-e29b-41d4-a716-446655440010', 'AC Service & Repair', 'car'),
('880e8400-e29b-41d4-a716-446655440013', '660e8400-e29b-41d4-a716-446655440010', 'Bike Service', 'bike'),
('880e8400-e29b-41d4-a716-446655440014', '660e8400-e29b-41d4-a716-446655440010', 'Denting & Painting', 'car');

-- Plans
INSERT INTO plans (
  id,
  service_id,
  company_id,
  name,
  vehicle_type,
  location_type,
  duration,
  base_price,
  tax,
  warranty,
  guarantee,
  badge
) VALUES 
-- Regular Car Service plans
(
  '990e8400-e29b-41d4-a716-446655440010',
  '880e8400-e29b-41d4-a716-446655440010',
  '660e8400-e29b-41d4-a716-446655440010',
  'Basic Service',
  'car',
  'in_premise',
  60,
  999.00,
  18.00,
  '1 month',
  'Satisfaction guaranteed',
  'Most Popular'
),
(
  '990e8400-e29b-41d4-a716-446655440011',
  '880e8400-e29b-41d4-a716-446655440010',
  '660e8400-e29b-41d4-a716-446655440010',
  'Standard Service',
  'car',
  'shed',
  120,
  1999.00,
  18.00,
  '3 months',
  '100% satisfaction or free re-service',
  'Best Value'
),
(
  '990e8400-e29b-41d4-a716-446655440012',
  '880e8400-e29b-41d4-a716-446655440010',
  '660e8400-e29b-41d4-a716-446655440010',
  'Comprehensive Service',
  'car',
  'shed',
  180,
  3499.00,
  18.00,
  '6 months',
  'Premium quality guarantee',
  'Premium'
),
-- Premium Car Service plans
(
  '990e8400-e29b-41d4-a716-446655440013',
  '880e8400-e29b-41d4-a716-446655440011',
  '660e8400-e29b-41d4-a716-446655440010',
  'Elite Service Package',
  'car',
  'shed',
  240,
  5999.00,
  18.00,
  '12 months',
  'Complete satisfaction guarantee',
  'Elite'
),
-- AC Service plans
(
  '990e8400-e29b-41d4-a716-446655440014',
  '880e8400-e29b-41d4-a716-446655440012',
  '660e8400-e29b-41d4-a716-446655440010',
  'AC Check & Gas Refill',
  'car',
  'in_premise',
  45,
  1499.00,
  18.00,
  '3 months',
  'Cooling guaranteed',
  NULL
),
(
  '990e8400-e29b-41d4-a716-446655440015',
  '880e8400-e29b-41d4-a716-446655440012',
  '660e8400-e29b-41d4-a716-446655440010',
  'Complete AC Overhaul',
  'car',
  'shed',
  180,
  4499.00,
  18.00,
  '6 months',
  'Optimal performance guaranteed',
  'Recommended'
),
-- Bike Service plans
(
  '990e8400-e29b-41d4-a716-446655440016',
  '880e8400-e29b-41d4-a716-446655440013',
  '660e8400-e29b-41d4-a716-446655440010',
  'Basic Bike Service',
  'bike',
  'in_premise',
  45,
  499.00,
  18.00,
  '1 month',
  'Smooth ride guaranteed',
  'Most Popular'
),
(
  '990e8400-e29b-41d4-a716-446655440017',
  '880e8400-e29b-41d4-a716-446655440013',
  '660e8400-e29b-41d4-a716-446655440010',
  'Premium Bike Service',
  'bike',
  'shed',
  90,
  999.00,
  18.00,
  '3 months',
  'Complete bike care',
  NULL
);

-- Plan fuel types
INSERT INTO plan_fuel_types (plan_id, fuel_type)
VALUES 
('990e8400-e29b-41d4-a716-446655440010', 'petrol'),
('990e8400-e29b-41d4-a716-446655440010', 'diesel'),
('990e8400-e29b-41d4-a716-446655440011', 'petrol'),
('990e8400-e29b-41d4-a716-446655440011', 'diesel'),
('990e8400-e29b-41d4-a716-446655440012', 'petrol'),
('990e8400-e29b-41d4-a716-446655440012', 'diesel'),
('990e8400-e29b-41d4-a716-446655440013', 'petrol'),
('990e8400-e29b-41d4-a716-446655440013', 'diesel'),
('990e8400-e29b-41d4-a716-446655440014', 'petrol'),
('990e8400-e29b-41d4-a716-446655440014', 'diesel'),
('990e8400-e29b-41d4-a716-446655440015', 'petrol'),
('990e8400-e29b-41d4-a716-446655440015', 'diesel');

-- Plan features for Basic Service
INSERT INTO plan_features (plan_id, feature, display_order)
VALUES 
('990e8400-e29b-41d4-a716-446655440010', 'Engine Oil Replacement', 1),
('990e8400-e29b-41d4-a716-446655440010', 'Oil Filter Replacement', 2),
('990e8400-e29b-41d4-a716-446655440010', 'Air Filter Cleaning', 3),
('990e8400-e29b-41d4-a716-446655440010', 'Brake Inspection', 4),
('990e8400-e29b-41d4-a716-446655440010', 'Coolant Top-up', 5);

-- Plan features for Standard Service
INSERT INTO plan_features (plan_id, feature, display_order)
VALUES 
('990e8400-e29b-41d4-a716-446655440011', 'Engine Oil Replacement', 1),
('990e8400-e29b-41d4-a716-446655440011', 'Oil Filter & Air Filter Replacement', 2),
('990e8400-e29b-41d4-a716-446655440011', 'Brake Pad Inspection & Cleaning', 3),
('990e8400-e29b-41d4-a716-446655440011', 'AC Filter Cleaning', 4),
('990e8400-e29b-41d4-a716-446655440011', 'Battery Check & Terminal Cleaning', 5),
('990e8400-e29b-41d4-a716-446655440011', '25 Point Check-up', 6);

-- Plan features for Comprehensive Service
INSERT INTO plan_features (plan_id, feature, display_order)
VALUES 
('990e8400-e29b-41d4-a716-446655440012', 'Complete Engine Diagnostics', 1),
('990e8400-e29b-41d4-a716-446655440012', 'Premium Synthetic Oil Change', 2),
('990e8400-e29b-41d4-a716-446655440012', 'All Filter Replacements', 3),
('990e8400-e29b-41d4-a716-446655440012', 'Brake System Overhaul', 4),
('990e8400-e29b-41d4-a716-446655440012', 'AC Performance Check', 5),
('990e8400-e29b-41d4-a716-446655440012', 'Wheel Alignment & Balancing', 6),
('990e8400-e29b-41d4-a716-446655440012', '40 Point Detailed Inspection', 7);

-- Plan FAQs
INSERT INTO plan_faqs (plan_id, question, answer, display_order)
VALUES 
('990e8400-e29b-41d4-a716-446655440010', 'How long does the service take?', 'The basic service typically takes 60 minutes to complete.', 1),
('990e8400-e29b-41d4-a716-446655440010', 'What oil do you use?', 'We use premium quality engine oil suitable for your vehicle.', 2),
('990e8400-e29b-41d4-a716-446655440011', 'Is pickup and drop available?', 'Yes, we offer free pickup and drop within 10km radius.', 1),
('990e8400-e29b-41d4-a716-446655440012', 'What is covered in comprehensive service?', 'It includes all mechanical and electrical checks, oil change, filter replacements, and detailed diagnostics.', 1);

-- Plan steps
INSERT INTO plan_steps (plan_id, step_description, display_order)
VALUES 
('990e8400-e29b-41d4-a716-446655440010', 'Initial vehicle inspection and condition assessment', 1),
('990e8400-e29b-41d4-a716-446655440010', 'Drain old engine oil and replace with new oil', 2),
('990e8400-e29b-41d4-a716-446655440010', 'Replace oil filter and clean air filter', 3),
('990e8400-e29b-41d4-a716-446655440010', 'Inspect brakes and top-up fluids', 4),
('990e8400-e29b-41d4-a716-446655440010', 'Final quality check and test drive', 5);

-- Additional services
INSERT INTO plan_additional_services (plan_id, service_name, display_order)
VALUES 
('990e8400-e29b-41d4-a716-446655440010', 'Wiper Blade Replacement', 1),
('990e8400-e29b-41d4-a716-446655440010', 'Headlight Restoration', 2),
('990e8400-e29b-41d4-a716-446655440011', 'Interior Deep Cleaning', 1),
('990e8400-e29b-41d4-a716-446655440011', 'Engine Bay Cleaning', 2),
('990e8400-e29b-41d4-a716-446655440012', 'Paint Protection Treatment', 1),
('990e8400-e29b-41d4-a716-446655440012', 'Ceramic Coating', 2);

SELECT 'Test mechanic data inserted successfully!' as message;
