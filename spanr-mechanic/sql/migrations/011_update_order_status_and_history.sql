 -- =====================================================
-- Update Order Status and Add Order History
-- =====================================================

-- Drop the order_details view first (it depends on orders.status)
DROP VIEW IF EXISTS order_details;

-- Drop existing order_status enum and recreate with new values
ALTER TABLE orders 
  ALTER COLUMN status DROP DEFAULT;

ALTER TABLE orders 
  ALTER COLUMN status TYPE TEXT;

DROP TYPE IF EXISTS order_status CASCADE;

CREATE TYPE order_status AS ENUM (
  'created',
  'accepted',
  'in_progress',
  'ready_for_delivery',
  'completed',
  'dispute',
  'cancelled'
);

ALTER TABLE orders 
  ALTER COLUMN status TYPE order_status USING status::order_status;

ALTER TABLE orders 
  ALTER COLUMN status SET DEFAULT 'created';

-- Create order_history table to track status changes
CREATE TABLE IF NOT EXISTS order_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status order_status NOT NULL,
  notes TEXT,
  changed_by UUID, -- Can be user or staff
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for order_history
CREATE INDEX IF NOT EXISTS idx_order_history_order_id ON order_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_history_created_at ON order_history(created_at);

-- Enable RLS on order_history
ALTER TABLE order_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for order_history
CREATE POLICY "Users can view their order history"
  ON order_history FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Company staff can view their company order history"
  ON order_history FOR SELECT
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

CREATE POLICY "System can insert order history"
  ON order_history FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Function to automatically create order history entry on status change
CREATE OR REPLACE FUNCTION create_order_history_entry()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create history entry if status changed
  IF (TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status)) THEN
    INSERT INTO order_history (order_id, status, notes)
    VALUES (NEW.id, NEW.status, 
      CASE 
        WHEN TG_OP = 'INSERT' THEN 'Order created'
        ELSE 'Status changed from ' || OLD.status::text || ' to ' || NEW.status::text
      END
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic order history
DROP TRIGGER IF EXISTS trigger_create_order_history ON orders;
CREATE TRIGGER trigger_create_order_history
  AFTER INSERT OR UPDATE OF status ON orders
  FOR EACH ROW
  EXECUTE FUNCTION create_order_history_entry();

-- Add razorpay fields to payments table
ALTER TABLE payments ADD COLUMN IF NOT EXISTS razorpay_order_id TEXT;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS razorpay_payment_id TEXT;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS razorpay_signature TEXT;

-- Create index for razorpay fields
CREATE INDEX IF NOT EXISTS idx_payments_razorpay_order_id ON payments(razorpay_order_id);
CREATE INDEX IF NOT EXISTS idx_payments_razorpay_payment_id ON payments(razorpay_payment_id);

-- Recreate the order_details view with updated order_status enum
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

