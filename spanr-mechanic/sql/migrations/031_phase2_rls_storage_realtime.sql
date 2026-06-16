-- =====================================================
-- Phase 2 RLS, storage buckets, realtime
-- =====================================================

-- staff_profiles RLS
ALTER TABLE staff_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view company profiles"
  ON staff_profiles FOR SELECT
  TO authenticated
  USING (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Staff can manage company profiles"
  ON staff_profiles FOR ALL
  TO authenticated
  USING (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  )
  WITH CHECK (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

-- staff_skills RLS
ALTER TABLE staff_skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view company skills"
  ON staff_skills FOR SELECT
  TO authenticated
  USING (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Staff can manage company skills"
  ON staff_skills FOR ALL
  TO authenticated
  USING (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  )
  WITH CHECK (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

-- staff_access RLS (was missing)
ALTER TABLE staff_access ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can view company access"
  ON staff_access FOR SELECT
  TO authenticated
  USING (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Staff can manage company access"
  ON staff_access FOR ALL
  TO authenticated
  USING (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
  )
  WITH CHECK (
    staff_id IN (
      SELECT id FROM staff WHERE company_id = user_company_id()
    )
  );

-- order_assignments RLS
ALTER TABLE order_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Company staff can view assignments"
  ON order_assignments FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

CREATE POLICY "Company staff can manage assignments"
  ON order_assignments FOR ALL
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  )
  WITH CHECK (
    order_id IN (
      SELECT id FROM orders WHERE company_id = user_company_id()
    )
    OR staff_id = auth_staff_id()
  );

-- vehicle_service_history RLS
ALTER TABLE vehicle_service_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Customers can view own vehicle history"
  ON vehicle_service_history FOR SELECT
  TO authenticated
  USING (customer_id = auth.uid());

CREATE POLICY "Company staff can view company history"
  ON vehicle_service_history FOR SELECT
  TO authenticated
  USING (company_id = user_company_id());

CREATE POLICY "Assigned staff can view history they created"
  ON vehicle_service_history FOR SELECT
  TO authenticated
  USING (staff_id = auth_staff_id());

-- parts_replaced RLS
ALTER TABLE parts_replaced ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view parts for their orders"
  ON parts_replaced FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
    OR order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR created_by = auth_staff_id()
  );

CREATE POLICY "Staff can manage parts on assigned orders"
  ON parts_replaced FOR ALL
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR order_id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id() AND status = 'active'
    )
  )
  WITH CHECK (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR order_id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id() AND status = 'active'
    )
  );

-- inspection_images RLS
ALTER TABLE inspection_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view inspection images for their orders"
  ON inspection_images FOR SELECT
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
    OR order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR uploaded_by = auth_staff_id()
  );

CREATE POLICY "Staff can manage inspection images on assigned orders"
  ON inspection_images FOR ALL
  TO authenticated
  USING (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR order_id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id() AND status = 'active'
    )
  )
  WITH CHECK (
    order_id IN (SELECT id FROM orders WHERE company_id = user_company_id())
    OR order_id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id() AND status = 'active'
    )
  );

-- Assigned employees can view/update their orders
CREATE POLICY "Assigned staff can view their orders"
  ON orders FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id()
        AND status IN ('active', 'completed')
    )
  );

CREATE POLICY "Assigned staff can update their orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT order_id FROM order_assignments
      WHERE staff_id = auth_staff_id()
        AND status = 'active'
    )
  );

-- Storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('staff-photos', 'staff-photos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp']),
  ('inspection-images', 'inspection-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('orders', 'orders', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- orders bucket policies
DROP POLICY IF EXISTS "Public can view order images" ON storage.objects;
CREATE POLICY "Public can view order images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'orders');

DROP POLICY IF EXISTS "Authenticated can upload order images" ON storage.objects;
CREATE POLICY "Authenticated can upload order images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'orders');

DROP POLICY IF EXISTS "Authenticated can update order images" ON storage.objects;
CREATE POLICY "Authenticated can update order images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'orders');

DROP POLICY IF EXISTS "Authenticated can delete order images" ON storage.objects;
CREATE POLICY "Authenticated can delete order images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'orders');

-- staff-photos bucket policies
DROP POLICY IF EXISTS "Public can view staff photos" ON storage.objects;
CREATE POLICY "Public can view staff photos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'staff-photos');

DROP POLICY IF EXISTS "Authenticated can upload staff photos" ON storage.objects;
CREATE POLICY "Authenticated can upload staff photos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'staff-photos');

DROP POLICY IF EXISTS "Authenticated can update staff photos" ON storage.objects;
CREATE POLICY "Authenticated can update staff photos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'staff-photos');

DROP POLICY IF EXISTS "Authenticated can delete staff photos" ON storage.objects;
CREATE POLICY "Authenticated can delete staff photos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'staff-photos');

-- inspection-images bucket policies
DROP POLICY IF EXISTS "Public can view inspection images" ON storage.objects;
CREATE POLICY "Public can view inspection images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'inspection-images');

DROP POLICY IF EXISTS "Authenticated can upload inspection images" ON storage.objects;
CREATE POLICY "Authenticated can upload inspection images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'inspection-images');

DROP POLICY IF EXISTS "Authenticated can update inspection images" ON storage.objects;
CREATE POLICY "Authenticated can update inspection images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'inspection-images');

DROP POLICY IF EXISTS "Authenticated can delete inspection images" ON storage.objects;
CREATE POLICY "Authenticated can delete inspection images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'inspection-images');

-- Realtime publication
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE order_assignments;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE orders;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
