-- =====================================================
-- Structured parts and typed inspection images
-- =====================================================

CREATE TYPE inspection_type AS ENUM ('before', 'after');
CREATE TYPE inspection_angle AS ENUM ('front', 'back', 'left', 'right', 'other');

CREATE TABLE IF NOT EXISTS parts_replaced (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  service_history_id UUID REFERENCES vehicle_service_history(id) ON DELETE CASCADE,
  part_name TEXT NOT NULL,
  part_number TEXT,
  brand TEXT,
  quantity INTEGER NOT NULL DEFAULT 1,
  cost NUMERIC(10, 2),
  photo_url TEXT,
  km_reading INTEGER,
  replacement_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inspection_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_history_id UUID REFERENCES vehicle_service_history(id) ON DELETE CASCADE,
  type inspection_type NOT NULL,
  angle inspection_angle NOT NULL DEFAULT 'other',
  image_url TEXT NOT NULL,
  uploaded_by UUID REFERENCES staff(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_parts_replaced_order_id ON parts_replaced(order_id);
CREATE INDEX IF NOT EXISTS idx_parts_replaced_service_history_id ON parts_replaced(service_history_id);
CREATE INDEX IF NOT EXISTS idx_inspection_images_order_id ON inspection_images(order_id);
CREATE INDEX IF NOT EXISTS idx_inspection_images_service_history_id ON inspection_images(service_history_id);
