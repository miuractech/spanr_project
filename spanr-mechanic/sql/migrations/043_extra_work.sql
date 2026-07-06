-- =====================================================
-- Extra work approval flow
-- Mechanic submits extra work request with photo + cost.
-- Order goes 'on_hold'. Customer approves or rejects
-- via the customer app before work can continue.
-- =====================================================

-- Add on_hold status to order lifecycle
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'on_hold';

-- Extra work requests
CREATE TABLE IF NOT EXISTS extra_work_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  mechanic_id UUID REFERENCES staff(id) ON DELETE SET NULL,
  description TEXT NOT NULL,
  photo_url TEXT,
  estimated_cost NUMERIC(10,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  customer_response_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_extra_work_requests_updated_at
  BEFORE UPDATE ON extra_work_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE INDEX IF NOT EXISTS idx_extra_work_order ON extra_work_requests(order_id);
CREATE INDEX IF NOT EXISTS idx_extra_work_status ON extra_work_requests(status);

ALTER TABLE extra_work_requests ENABLE ROW LEVEL SECURITY;

-- Company staff can view all extra work requests for their orders
CREATE POLICY "Staff can view extra work requests"
  ON extra_work_requests FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR mechanic_id = auth_staff_id()
  );

-- Mechanics can insert extra work requests for orders they are assigned to
CREATE POLICY "Mechanics can submit extra work requests"
  ON extra_work_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    mechanic_id = auth_staff_id()
    AND order_id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id() AND status = 'active'
    )
  );

-- Mechanics can update their own pending requests (e.g. add photo after submit)
CREATE POLICY "Mechanics can update own pending requests"
  ON extra_work_requests FOR UPDATE
  TO authenticated
  USING (mechanic_id = auth_staff_id() AND status = 'pending');

-- Customers can view extra work requests on their orders
CREATE POLICY "Customers can view their order extra work requests"
  ON extra_work_requests FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
  );

-- Customers can update (approve/reject) pending requests on their orders
CREATE POLICY "Customers can respond to extra work requests"
  ON extra_work_requests FOR UPDATE
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
    AND status = 'pending'
  )
  WITH CHECK (
    status IN ('approved', 'rejected')
  );

-- Storage bucket for extra work photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('extra-work-photos', 'extra-work-photos', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Mechanics can upload extra work photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'extra-work-photos');

CREATE POLICY "Anyone can view extra work photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'extra-work-photos');
