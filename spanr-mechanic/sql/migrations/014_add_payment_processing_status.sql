-- =====================================================
-- Add processing and failed status to payment_status
-- =====================================================

-- Drop the order_details view first (it depends on payments.status)
DROP VIEW IF EXISTS order_details;

-- Drop existing payment_status enum and recreate with new values
ALTER TABLE payments 
  ALTER COLUMN status DROP DEFAULT;

ALTER TABLE payments 
  ALTER COLUMN status TYPE TEXT;

DROP TYPE IF EXISTS payment_status CASCADE;

CREATE TYPE payment_status AS ENUM (
  'unpaid',
  'processing',
  'paid',
  'failed'
);

ALTER TABLE payments 
  ALTER COLUMN status TYPE payment_status USING status::payment_status;

ALTER TABLE payments 
  ALTER COLUMN status SET DEFAULT 'unpaid';

-- Add failure reason field
ALTER TABLE payments ADD COLUMN IF NOT EXISTS failure_reason TEXT;

-- Add webhook event tracking
CREATE TABLE IF NOT EXISTS payment_webhook_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payment_id UUID REFERENCES payments(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  razorpay_event_id TEXT,
  payload JSONB NOT NULL,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_webhook_events_payment_id ON payment_webhook_events(payment_id);
CREATE INDEX IF NOT EXISTS idx_payment_webhook_events_event_type ON payment_webhook_events(event_type);
CREATE INDEX IF NOT EXISTS idx_payment_webhook_events_processed ON payment_webhook_events(processed);

-- Recreate the order_details view with updated payment_status enum
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

