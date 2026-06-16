-- =====================================================
-- Permanent vehicle service history records
-- =====================================================

CREATE TABLE IF NOT EXISTS vehicle_service_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID UNIQUE REFERENCES orders(id) ON DELETE SET NULL,
  vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
  company_id UUID REFERENCES mechanic_companies(id) ON DELETE SET NULL,
  staff_id UUID REFERENCES staff(id) ON DELETE SET NULL,
  customer_id UUID REFERENCES users(id) ON DELETE SET NULL,
  vehicle_make TEXT,
  vehicle_model TEXT,
  vehicle_year INTEGER,
  license_plate TEXT,
  customer_name TEXT,
  mechanic_name TEXT,
  company_name TEXT,
  service_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  odometer_reading INTEGER,
  services_performed TEXT,
  service_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vehicle_service_history_vehicle_id ON vehicle_service_history(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_service_history_license_plate ON vehicle_service_history(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicle_service_history_company_id ON vehicle_service_history(company_id);
CREATE INDEX IF NOT EXISTS idx_vehicle_service_history_order_id ON vehicle_service_history(order_id);
