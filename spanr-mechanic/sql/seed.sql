-- =====================================================
-- SPANR Platform - Seed Data
-- Sample data for development and testing
-- =====================================================

-- Note: Run this after 001_initial_schema.sql

-- =====================================================
-- SAMPLE MECHANIC COMPANIES
-- =====================================================

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
  logo
) VALUES 
(
  '550e8400-e29b-41d4-a716-446655440001',
  'Elite Auto Care',
  '123 Main Street',
  'Near Central Mall',
  'Opposite HDFC Bank',
  'Mumbai',
  'Maharashtra',
  '+919876543210',
  '400001',
  '+919876543210',
  'contact@eliteautocare.com',
  'https://example.com/logos/elite-auto.png'
),
(
  '550e8400-e29b-41d4-a716-446655440002',
  'Rapid Repairs',
  '456 Service Road',
  'MG Road Area',
  'Near Indiranagar Metro',
  'Bangalore',
  'Karnataka',
  '+919876543211',
  '560001',
  '+919876543211',
  'info@rapidrepairs.com',
  'https://example.com/logos/rapid-repairs.png'
),
(
  '550e8400-e29b-41d4-a716-446655440003',
  'Speed Masters',
  '789 Highway Junction',
  'Sector 42',
  'Near Cyber Hub',
  'Gurgaon',
  'Haryana',
  '+919876543212',
  '122001',
  '+919876543212',
  'hello@speedmasters.com',
  'https://example.com/logos/speed-masters.png'
);

-- =====================================================
-- COMPANY RATINGS
-- =====================================================

INSERT INTO company_ratings (company_id, count, professionalism, timeliness, quality, rating)
VALUES 
('550e8400-e29b-41d4-a716-446655440001', 150, 4.8, 4.7, 4.9, 4.8),
('550e8400-e29b-41d4-a716-446655440002', 89, 4.5, 4.3, 4.6, 4.5),
('550e8400-e29b-41d4-a716-446655440003', 210, 4.9, 4.8, 4.9, 4.9);

-- =====================================================
-- COMPANY CERTIFICATIONS
-- =====================================================

INSERT INTO company_certifications (company_id, certification_name)
VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'ISO 9001:2015'),
('550e8400-e29b-41d4-a716-446655440001', 'Authorized Service Center - Maruti'),
('550e8400-e29b-41d4-a716-446655440001', 'ASE Certified'),
('550e8400-e29b-41d4-a716-446655440002', 'ISO 9001:2015'),
('550e8400-e29b-41d4-a716-446655440002', 'Authorized Service Center - Honda'),
('550e8400-e29b-41d4-a716-446655440003', 'ISO 9001:2015'),
('550e8400-e29b-41d4-a716-446655440003', 'ASE Master Technician'),
('550e8400-e29b-41d4-a716-446655440003', 'Authorized Service Center - BMW');

-- =====================================================
-- COMPANY SPECIALIZATIONS
-- =====================================================

INSERT INTO company_specializations (company_id, specialization_name)
VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'Engine Diagnostics'),
('550e8400-e29b-41d4-a716-446655440001', 'AC Service'),
('550e8400-e29b-41d4-a716-446655440001', 'Brake Service'),
('550e8400-e29b-41d4-a716-446655440001', 'Oil Change'),
('550e8400-e29b-41d4-a716-446655440002', 'Bike Maintenance'),
('550e8400-e29b-41d4-a716-446655440002', 'Car Detailing'),
('550e8400-e29b-41d4-a716-446655440002', 'Denting & Painting'),
('550e8400-e29b-41d4-a716-446655440003', 'Luxury Car Service'),
('550e8400-e29b-41d4-a716-446655440003', 'Performance Tuning'),
('550e8400-e29b-41d4-a716-446655440003', 'Transmission Repair');

-- =====================================================
-- STAFF/EMPLOYEES
-- =====================================================

INSERT INTO staff (id, company_id, email, name, enabled)
VALUES 
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'admin@eliteautocare.com', 'Rajesh Kumar', true),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'tech@eliteautocare.com', 'Amit Sharma', true),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'admin@rapidrepairs.com', 'Priya Singh', true),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440003', 'admin@speedmasters.com', 'Vikram Patel', true);

-- =====================================================
-- STAFF ACCESS PERMISSIONS
-- =====================================================

INSERT INTO staff_access (staff_id, access_permission)
VALUES 
-- Elite Auto Care admin
('660e8400-e29b-41d4-a716-446655440001', 'orders.read'),
('660e8400-e29b-41d4-a716-446655440001', 'orders.write'),
('660e8400-e29b-41d4-a716-446655440001', 'staff.manage'),
('660e8400-e29b-41d4-a716-446655440001', 'services.manage'),
('660e8400-e29b-41d4-a716-446655440001', 'company.manage'),
-- Elite Auto Care tech
('660e8400-e29b-41d4-a716-446655440002', 'orders.read'),
('660e8400-e29b-41d4-a716-446655440002', 'orders.write'),
-- Rapid Repairs admin
('660e8400-e29b-41d4-a716-446655440003', 'orders.read'),
('660e8400-e29b-41d4-a716-446655440003', 'orders.write'),
('660e8400-e29b-41d4-a716-446655440003', 'staff.manage'),
('660e8400-e29b-41d4-a716-446655440003', 'services.manage'),
('660e8400-e29b-41d4-a716-446655440003', 'company.manage'),
-- Speed Masters admin
('660e8400-e29b-41d4-a716-446655440004', 'orders.read'),
('660e8400-e29b-41d4-a716-446655440004', 'orders.write'),
('660e8400-e29b-41d4-a716-446655440004', 'staff.manage'),
('660e8400-e29b-41d4-a716-446655440004', 'services.manage'),
('660e8400-e29b-41d4-a716-446655440004', 'company.manage');

-- =====================================================
-- SERVICES
-- =====================================================

INSERT INTO services (id, company_id, name, category)
VALUES 
-- Elite Auto Care services
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'Regular Car Service', 'car'),
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'AC Service', 'car'),
('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', 'Bike Service', 'bike'),
-- Rapid Repairs services
('770e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'Full Car Service', 'car'),
('770e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440002', 'Bike Maintenance', 'bike'),
-- Speed Masters services
('770e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', 'Premium Car Service', 'car'),
('770e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440003', 'Performance Bike Service', 'bike');

-- =====================================================
-- PLANS
-- =====================================================

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
-- Elite Auto Care plans
(
  '880e8400-e29b-41d4-a716-446655440001',
  '770e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440001',
  'Basic Car Service',
  'car',
  'in_premise',
  90,
  1499.00,
  18.00,
  '1 month',
  'Satisfaction guaranteed',
  'Most Popular'
),
(
  '880e8400-e29b-41d4-a716-446655440002',
  '770e8400-e29b-41d4-a716-446655440002',
  '550e8400-e29b-41d4-a716-446655440001',
  'Complete AC Service',
  'car',
  'shed',
  120,
  2499.00,
  18.00,
  '3 months',
  '100% satisfaction or money back',
  'Premium'
),
-- Rapid Repairs plans
(
  '880e8400-e29b-41d4-a716-446655440003',
  '770e8400-e29b-41d4-a716-446655440004',
  '550e8400-e29b-41d4-a716-446655440002',
  'Standard Service Package',
  'car',
  'in_premise',
  60,
  1299.00,
  18.00,
  '1 month',
  'Quality assured',
  NULL
),
-- Speed Masters plans
(
  '880e8400-e29b-41d4-a716-446655440004',
  '770e8400-e29b-41d4-a716-446655440006',
  '550e8400-e29b-41d4-a716-446655440003',
  'Elite Car Service',
  'car',
  'shed',
  180,
  4999.00,
  18.00,
  '6 months',
  'Premium quality guarantee',
  'Elite'
);

-- =====================================================
-- PLAN FUEL TYPES
-- =====================================================

INSERT INTO plan_fuel_types (plan_id, fuel_type)
VALUES 
('880e8400-e29b-41d4-a716-446655440001', 'petrol'),
('880e8400-e29b-41d4-a716-446655440001', 'diesel'),
('880e8400-e29b-41d4-a716-446655440002', 'petrol'),
('880e8400-e29b-41d4-a716-446655440002', 'diesel'),
('880e8400-e29b-41d4-a716-446655440003', 'petrol'),
('880e8400-e29b-41d4-a716-446655440003', 'diesel'),
('880e8400-e29b-41d4-a716-446655440004', 'petrol'),
('880e8400-e29b-41d4-a716-446655440004', 'diesel');

-- =====================================================
-- PLAN FEATURES
-- =====================================================

INSERT INTO plan_features (plan_id, feature, display_order)
VALUES 
-- Basic Car Service features
('880e8400-e29b-41d4-a716-446655440001', 'Engine Oil Replacement', 1),
('880e8400-e29b-41d4-a716-446655440001', 'Oil Filter Replacement', 2),
('880e8400-e29b-41d4-a716-446655440001', 'Air Filter Cleaning', 3),
('880e8400-e29b-41d4-a716-446655440001', 'Brake Inspection', 4),
('880e8400-e29b-41d4-a716-446655440001', '15 Point Check-up', 5),
-- AC Service features
('880e8400-e29b-41d4-a716-446655440002', 'AC Gas Refill', 1),
('880e8400-e29b-41d4-a716-446655440002', 'Condenser Cleaning', 2),
('880e8400-e29b-41d4-a716-446655440002', 'Blower Motor Check', 3),
('880e8400-e29b-41d4-a716-446655440002', 'Cooling Coil Cleaning', 4),
('880e8400-e29b-41d4-a716-446655440002', 'Temperature Check', 5);

-- =====================================================
-- PLAN FAQs
-- =====================================================

INSERT INTO plan_faqs (plan_id, question, answer, display_order)
VALUES 
(
  '880e8400-e29b-41d4-a716-446655440001',
  'How long does the service take?',
  'The basic car service typically takes 90 minutes to complete.',
  1
),
(
  '880e8400-e29b-41d4-a716-446655440001',
  'Is pickup and drop available?',
  'Yes, we offer free pickup and drop within 5km radius.',
  2
),
(
  '880e8400-e29b-41d4-a716-446655440001',
  'What type of oil do you use?',
  'We use premium quality engine oil from brands like Castrol, Mobil, and Shell.',
  3
);

-- =====================================================
-- PLAN STEPS
-- =====================================================

INSERT INTO plan_steps (plan_id, step_description, display_order)
VALUES 
('880e8400-e29b-41d4-a716-446655440001', 'Vehicle inspection and checklist preparation', 1),
('880e8400-e29b-41d4-a716-446655440001', 'Engine oil drainage and replacement', 2),
('880e8400-e29b-41d4-a716-446655440001', 'Filter replacements', 3),
('880e8400-e29b-41d4-a716-446655440001', 'Brake and safety checks', 4),
('880e8400-e29b-41d4-a716-446655440001', 'Final quality inspection', 5);

-- =====================================================
-- SAMPLE USERS (CUSTOMERS)
-- =====================================================

INSERT INTO users (id, user_id, email, name, phone)
VALUES 
(
  '990e8400-e29b-41d4-a716-446655440001',
  'firebase-user-id-001',
  'john.doe@example.com',
  'John Doe',
  '+919876000001'
),
(
  '990e8400-e29b-41d4-a716-446655440002',
  'firebase-user-id-002',
  'jane.smith@example.com',
  'Jane Smith',
  '+919876000002'
);

-- =====================================================
-- SAMPLE VEHICLES
-- =====================================================

INSERT INTO vehicles (id, user_id, make, model, year, license_plate)
VALUES 
(
  'aa0e8400-e29b-41d4-a716-446655440001',
  '990e8400-e29b-41d4-a716-446655440001',
  'Maruti Suzuki',
  'Swift',
  2020,
  'MH01AB1234'
),
(
  'aa0e8400-e29b-41d4-a716-446655440002',
  '990e8400-e29b-41d4-a716-446655440002',
  'Honda',
  'City',
  2019,
  'KA01CD5678'
);

-- =====================================================
-- SAMPLE ORDERS
-- =====================================================

INSERT INTO orders (
  id,
  company_id,
  user_id,
  plan_id,
  vehicle_id,
  order_date,
  scheduled_service_date,
  status,
  special_instructions,
  contact_name,
  contact_phone,
  contact_email,
  contact_address,
  service_latitude,
  service_longitude,
  service_address
) VALUES 
(
  'bb0e8400-e29b-41d4-a716-446655440001',
  '550e8400-e29b-41d4-a716-446655440001',
  '990e8400-e29b-41d4-a716-446655440001',
  '880e8400-e29b-41d4-a716-446655440001',
  'aa0e8400-e29b-41d4-a716-446655440001',
  NOW() - INTERVAL '2 days',
  NOW() + INTERVAL '1 day',
  'confirmed',
  'Please check the AC as well',
  'John Doe',
  '+919876000001',
  'john.doe@example.com',
  '456 Home Street, Mumbai',
  19.0760,
  72.8777,
  '456 Home Street, Andheri West, Mumbai, Maharashtra 400058'
),
(
  'bb0e8400-e29b-41d4-a716-446655440002',
  '550e8400-e29b-41d4-a716-446655440002',
  '990e8400-e29b-41d4-a716-446655440002',
  '880e8400-e29b-41d4-a716-446655440003',
  'aa0e8400-e29b-41d4-a716-446655440002',
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '2 days',
  'completed',
  NULL,
  'Jane Smith',
  '+919876000002',
  'jane.smith@example.com',
  '789 Park Avenue, Bangalore',
  12.9716,
  77.5946,
  '789 Park Avenue, Indiranagar, Bangalore, Karnataka 560038'
);

-- =====================================================
-- SAMPLE PAYMENTS
-- =====================================================

INSERT INTO payments (
  id,
  order_id,
  method,
  status,
  amount,
  transaction_id,
  paid_at
) VALUES 
(
  'cc0e8400-e29b-41d4-a716-446655440001',
  'bb0e8400-e29b-41d4-a716-446655440001',
  'upi',
  'paid',
  1768.82,
  'TXN123456789',
  NOW() - INTERVAL '2 days'
),
(
  'cc0e8400-e29b-41d4-a716-446655440002',
  'bb0e8400-e29b-41d4-a716-446655440002',
  'credit_card',
  'paid',
  1532.82,
  'TXN987654321',
  NOW() - INTERVAL '5 days'
);

-- =====================================================
-- DONE
-- =====================================================

SELECT 'Seed data inserted successfully!' as message;

