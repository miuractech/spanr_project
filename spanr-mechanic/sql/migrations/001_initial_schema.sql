-- =====================================================
-- SPANR Platform - Initial Database Schema
-- Multi-Mechanic Shop Platform
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CUSTOM TYPES (ENUMS)
-- =====================================================

CREATE TYPE vehicle_type AS ENUM ('car', 'bike');
CREATE TYPE fuel_type AS ENUM ('diesel', 'petrol');
CREATE TYPE location_type AS ENUM ('in_premise', 'shed');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled');
CREATE TYPE payment_method AS ENUM ('credit_card', 'debit_card', 'net_banking', 'upi');
CREATE TYPE payment_status AS ENUM ('paid', 'unpaid');
CREATE TYPE entity_type AS ENUM ('company', 'plan', 'service', 'order');

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Mechanic companies table
CREATE TABLE mechanic_companies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name TEXT NOT NULL,
  
  -- Address information
  address_line_1 TEXT NOT NULL,
  address_line_2 TEXT,
  landmark TEXT,
  city TEXT NOT NULL,
  state TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  pincode TEXT NOT NULL,
  
  -- Geo location
  latitude NUMERIC(10, 8),
  longitude NUMERIC(11, 8),
  
  -- Contact information
  phone TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  
  -- Branding
  logo TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Company ratings table
CREATE TABLE company_ratings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  count INTEGER NOT NULL DEFAULT 0,
  professionalism NUMERIC(3, 2) NOT NULL DEFAULT 0.0 CHECK (professionalism >= 0 AND professionalism <= 5),
  timeliness NUMERIC(3, 2) NOT NULL DEFAULT 0.0 CHECK (timeliness >= 0 AND timeliness <= 5),
  quality NUMERIC(3, 2) NOT NULL DEFAULT 0.0 CHECK (quality >= 0 AND quality <= 5),
  rating NUMERIC(3, 2) NOT NULL DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id)
);

-- Company certifications table
CREATE TABLE company_certifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  certification_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, certification_name)
);

-- Company specializations table
CREATE TABLE company_specializations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  specialization_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, specialization_name)
);

-- Staff/employees table
CREATE TABLE staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, email)
);

-- Staff access permissions table
CREATE TABLE staff_access (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  access_permission TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(staff_id, access_permission)
);

-- Services table
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category vehicle_type NOT NULL,
  icon_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id, name, category)
);

-- Plans table
CREATE TABLE plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  vehicle_type vehicle_type NOT NULL,
  location_type location_type NOT NULL,
  duration INTEGER NOT NULL, -- in minutes
  base_price NUMERIC(10, 2) NOT NULL,
  tax NUMERIC(5, 2) NOT NULL DEFAULT 0.0,
  warranty TEXT,
  guarantee TEXT,
  badge TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Plan fuel types table (many-to-many)
CREATE TABLE plan_fuel_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  fuel_type fuel_type NOT NULL,
  UNIQUE(plan_id, fuel_type)
);

-- Plan features table
CREATE TABLE plan_features (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  feature TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Plan FAQs table
CREATE TABLE plan_faqs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Plan service outcomes table
CREATE TABLE plan_service_outcomes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  image_url TEXT NOT NULL,
  description TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Plan additional services table
CREATE TABLE plan_additional_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  service_name TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Plan steps table
CREATE TABLE plan_steps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
  step_description TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Vehicles table
CREATE TABLE vehicles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  license_plate TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(license_plate)
);

-- Orders table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES mechanic_companies(id) ON DELETE RESTRICT,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE RESTRICT,
  vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
  
  order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  scheduled_service_date TIMESTAMPTZ NOT NULL,
  status order_status NOT NULL DEFAULT 'pending',
  special_instructions TEXT,
  
  -- Contact details (can differ from user profile)
  contact_name TEXT NOT NULL,
  contact_phone TEXT NOT NULL,
  contact_email TEXT NOT NULL,
  contact_address TEXT NOT NULL,
  
  -- Service location
  service_latitude NUMERIC(10, 8) NOT NULL,
  service_longitude NUMERIC(11, 8) NOT NULL,
  service_address TEXT NOT NULL,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  method payment_method NOT NULL,
  status payment_status NOT NULL DEFAULT 'unpaid',
  amount NUMERIC(10, 2) NOT NULL,
  transaction_id TEXT,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(order_id)
);

-- Images table (generic for all entities)
CREATE TABLE images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type entity_type NOT NULL,
  entity_id UUID NOT NULL,
  url TEXT NOT NULL,
  file_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_user_id ON users(user_id);
CREATE INDEX idx_users_email ON users(email);

-- Mechanic companies indexes
CREATE INDEX idx_mechanic_companies_email ON mechanic_companies(email);
CREATE INDEX idx_mechanic_companies_city ON mechanic_companies(city);
CREATE INDEX idx_mechanic_companies_state ON mechanic_companies(state);

-- Company ratings indexes
CREATE INDEX idx_company_ratings_company_id ON company_ratings(company_id);

-- Company certifications indexes
CREATE INDEX idx_company_certifications_company_id ON company_certifications(company_id);

-- Company specializations indexes
CREATE INDEX idx_company_specializations_company_id ON company_specializations(company_id);

-- Staff indexes
CREATE INDEX idx_staff_company_id ON staff(company_id);
CREATE INDEX idx_staff_email ON staff(email);
CREATE INDEX idx_staff_enabled ON staff(enabled);

-- Staff access indexes
CREATE INDEX idx_staff_access_staff_id ON staff_access(staff_id);

-- Services indexes
CREATE INDEX idx_services_company_id ON services(company_id);
CREATE INDEX idx_services_category ON services(category);

-- Plans indexes
CREATE INDEX idx_plans_service_id ON plans(service_id);
CREATE INDEX idx_plans_company_id ON plans(company_id);
CREATE INDEX idx_plans_vehicle_type ON plans(vehicle_type);
CREATE INDEX idx_plans_location_type ON plans(location_type);

-- Plan fuel types indexes
CREATE INDEX idx_plan_fuel_types_plan_id ON plan_fuel_types(plan_id);

-- Plan features indexes
CREATE INDEX idx_plan_features_plan_id ON plan_features(plan_id);

-- Plan FAQs indexes
CREATE INDEX idx_plan_faqs_plan_id ON plan_faqs(plan_id);

-- Plan service outcomes indexes
CREATE INDEX idx_plan_service_outcomes_plan_id ON plan_service_outcomes(plan_id);

-- Plan additional services indexes
CREATE INDEX idx_plan_additional_services_plan_id ON plan_additional_services(plan_id);

-- Plan steps indexes
CREATE INDEX idx_plan_steps_plan_id ON plan_steps(plan_id);

-- Vehicles indexes
CREATE INDEX idx_vehicles_user_id ON vehicles(user_id);
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);

-- Orders indexes
CREATE INDEX idx_orders_company_id ON orders(company_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_plan_id ON orders(plan_id);
CREATE INDEX idx_orders_vehicle_id ON orders(vehicle_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_scheduled_service_date ON orders(scheduled_service_date);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Payments indexes
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);

-- Images indexes
CREATE INDEX idx_images_entity_type_entity_id ON images(entity_type, entity_id);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all relevant tables
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mechanic_companies_updated_at
  BEFORE UPDATE ON mechanic_companies
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_company_ratings_updated_at
  BEFORE UPDATE ON company_ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_updated_at
  BEFORE UPDATE ON staff
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at
  BEFORE UPDATE ON services
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at
  BEFORE UPDATE ON plans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at
  BEFORE UPDATE ON vehicles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE mechanic_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_specializations ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_fuel_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_service_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_additional_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE images ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  USING (auth.uid()::text = user_id);

CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  USING (auth.uid()::text = user_id);

-- Mechanic companies policies (public read, authenticated write)
CREATE POLICY "Anyone can view mechanic companies"
  ON mechanic_companies FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can create mechanic companies"
  ON mechanic_companies FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Company staff can update their company"
  ON mechanic_companies FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT company_id FROM staff 
      WHERE email = auth.jwt()->>'email' 
      AND enabled = true
    )
  );

-- Company ratings policies (public read)
CREATE POLICY "Anyone can view company ratings"
  ON company_ratings FOR SELECT
  TO public
  USING (true);

-- Company certifications policies (public read)
CREATE POLICY "Anyone can view company certifications"
  ON company_certifications FOR SELECT
  TO public
  USING (true);

-- Company specializations policies (public read)
CREATE POLICY "Anyone can view company specializations"
  ON company_specializations FOR SELECT
  TO public
  USING (true);

-- Staff policies
CREATE POLICY "Staff can view their own company staff"
  ON staff FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM staff 
      WHERE email = auth.jwt()->>'email' 
      AND enabled = true
    )
  );

-- Services policies (public read)
CREATE POLICY "Anyone can view services"
  ON services FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Company staff can manage their services"
  ON services FOR ALL
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM staff 
      WHERE email = auth.jwt()->>'email' 
      AND enabled = true
    )
  );

-- Plans policies (public read)
CREATE POLICY "Anyone can view plans"
  ON plans FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Company staff can manage their plans"
  ON plans FOR ALL
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM staff 
      WHERE email = auth.jwt()->>'email' 
      AND enabled = true
    )
  );

-- Plan related tables policies (public read)
CREATE POLICY "Anyone can view plan fuel types"
  ON plan_fuel_types FOR SELECT TO public USING (true);

CREATE POLICY "Anyone can view plan features"
  ON plan_features FOR SELECT TO public USING (true);

CREATE POLICY "Anyone can view plan FAQs"
  ON plan_faqs FOR SELECT TO public USING (true);

CREATE POLICY "Anyone can view plan service outcomes"
  ON plan_service_outcomes FOR SELECT TO public USING (true);

CREATE POLICY "Anyone can view plan additional services"
  ON plan_additional_services FOR SELECT TO public USING (true);

CREATE POLICY "Anyone can view plan steps"
  ON plan_steps FOR SELECT TO public USING (true);

-- Vehicles policies
CREATE POLICY "Users can view their own vehicles"
  ON vehicles FOR SELECT
  TO authenticated
  USING (
    user_id IN (SELECT id FROM users WHERE user_id = auth.uid()::text)
  );

CREATE POLICY "Users can manage their own vehicles"
  ON vehicles FOR ALL
  TO authenticated
  USING (
    user_id IN (SELECT id FROM users WHERE user_id = auth.uid()::text)
  );

-- Orders policies
CREATE POLICY "Users can view their own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (
    user_id IN (SELECT id FROM users WHERE user_id = auth.uid()::text)
  );

CREATE POLICY "Company staff can view their company orders"
  ON orders FOR SELECT
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM staff 
      WHERE email = auth.jwt()->>'email' 
      AND enabled = true
    )
  );

CREATE POLICY "Authenticated users can create orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Company staff can update their company orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (
    company_id IN (
      SELECT company_id FROM staff 
      WHERE email = auth.jwt()->>'email' 
      AND enabled = true
    )
  );

-- Payments policies
CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id IN (SELECT id FROM users WHERE user_id = auth.uid()::text)
    )
  );

CREATE POLICY "Company staff can view their company payments"
  ON payments FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE company_id IN (
        SELECT company_id FROM staff 
        WHERE email = auth.jwt()->>'email' 
        AND enabled = true
      )
    )
  );

-- Images policies (public read)
CREATE POLICY "Anyone can view images"
  ON images FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Authenticated users can upload images"
  ON images FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- =====================================================
-- HELPER VIEWS
-- =====================================================

-- View for company with aggregated data
CREATE VIEW company_profiles AS
SELECT 
  mc.*,
  cr.count as ratings_count,
  cr.professionalism,
  cr.timeliness,
  cr.quality,
  cr.rating,
  COALESCE(json_agg(DISTINCT cc.certification_name) FILTER (WHERE cc.certification_name IS NOT NULL), '[]') as certifications,
  COALESCE(json_agg(DISTINCT cs.specialization_name) FILTER (WHERE cs.specialization_name IS NOT NULL), '[]') as specializations,
  COALESCE(json_agg(DISTINCT s.name) FILTER (WHERE s.name IS NOT NULL), '[]') as services_offered
FROM mechanic_companies mc
LEFT JOIN company_ratings cr ON mc.id = cr.company_id
LEFT JOIN company_certifications cc ON mc.id = cc.company_id
LEFT JOIN company_specializations cs ON mc.id = cs.company_id
LEFT JOIN services s ON mc.id = s.company_id
GROUP BY mc.id, cr.count, cr.professionalism, cr.timeliness, cr.quality, cr.rating;

-- View for orders with related data
CREATE VIEW order_details AS
SELECT 
  o.*,
  u.name as user_name,
  u.email as user_email,
  u.phone as user_phone,
  v.make as vehicle_make,
  v.model as vehicle_model,
  v.year as vehicle_year,
  v.license_plate,
  p.name as plan_name,
  p.base_price,
  p.tax,
  s.name as service_name,
  mc.company_name,
  pay.status as payment_status,
  pay.method as payment_method,
  pay.amount as payment_amount
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN vehicles v ON o.vehicle_id = v.id
JOIN plans p ON o.plan_id = p.id
JOIN services s ON p.service_id = s.id
JOIN mechanic_companies mc ON o.company_id = mc.id
LEFT JOIN payments pay ON o.id = pay.order_id;

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- You can uncomment these to add sample data

-- INSERT INTO mechanic_companies (company_name, address_line_1, city, state, phone_number, pincode, phone, email)
-- VALUES 
--   ('Elite Auto Care', '123 Main Street', 'Mumbai', 'Maharashtra', '+919876543210', '400001', '+919876543210', 'contact@eliteautocare.com'),
--   ('Rapid Repairs', '456 Service Road', 'Bangalore', 'Karnataka', '+919876543211', '560001', '+919876543211', 'info@rapidrepairs.com');


