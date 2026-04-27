-- =====================================================
-- Create Order Service Details Table
-- =====================================================

CREATE TABLE IF NOT EXISTS order_service_details (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  parts_used TEXT,
  labor_hours NUMERIC(5, 2),
  additional_charges NUMERIC(10, 2) DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_order_service_details_order_id ON order_service_details(order_id);

-- Enable RLS
ALTER TABLE order_service_details ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their order service details"
  ON order_service_details FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Company staff can view their company order service details"
  ON order_service_details FOR SELECT
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

CREATE POLICY "Company staff can insert/update order service details"
  ON order_service_details FOR ALL
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
  )
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders 
      WHERE company_id IN (
        SELECT company_id FROM staff 
        WHERE email = auth.jwt()->>'email' 
        AND enabled = true
      )
    )
  );

-- Update trigger
CREATE TRIGGER update_order_service_details_updated_at
  BEFORE UPDATE ON order_service_details
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

