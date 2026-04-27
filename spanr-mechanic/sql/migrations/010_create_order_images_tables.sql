-- =====================================================
-- Create Order Images Tables
-- =====================================================

-- Table to store before service images
CREATE TABLE IF NOT EXISTS order_before_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table to store after service images (taken by mechanic)
CREATE TABLE IF NOT EXISTS order_after_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  uploaded_by UUID REFERENCES staff(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_order_before_images_order_id ON order_before_images(order_id);
CREATE INDEX IF NOT EXISTS idx_order_after_images_order_id ON order_after_images(order_id);

-- Enable RLS
ALTER TABLE order_before_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_after_images ENABLE ROW LEVEL SECURITY;

-- RLS Policies for order_before_images
CREATE POLICY "Users can view their order before images"
  ON order_before_images FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Company staff can view their company order before images"
  ON order_before_images FOR SELECT
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

CREATE POLICY "Users can insert before images"
  ON order_before_images FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- RLS Policies for order_after_images
CREATE POLICY "Users can view their order after images"
  ON order_after_images FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Company staff can view their company order after images"
  ON order_after_images FOR SELECT
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

CREATE POLICY "Company staff can insert after images"
  ON order_after_images FOR INSERT
  TO authenticated
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

