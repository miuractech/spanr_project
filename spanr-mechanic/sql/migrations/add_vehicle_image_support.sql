-- =====================================================
-- Add Vehicle Image Support
-- =====================================================

-- Add 'vehicle' to entity_type enum
ALTER TYPE entity_type ADD VALUE IF NOT EXISTS 'vehicle';

-- Create storage bucket for vehicle images
INSERT INTO storage.buckets (id, name, public)
VALUES ('vehicle-images', 'vehicle-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for vehicle images
DROP POLICY IF EXISTS "Anyone can view vehicle images" ON storage.objects;
CREATE POLICY "Anyone can view vehicle images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'vehicle-images');

DROP POLICY IF EXISTS "Authenticated users can upload vehicle images" ON storage.objects;
CREATE POLICY "Authenticated users can upload vehicle images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'vehicle-images');

DROP POLICY IF EXISTS "Users can update their vehicle images" ON storage.objects;
CREATE POLICY "Users can update their vehicle images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'vehicle-images');

DROP POLICY IF EXISTS "Users can delete their vehicle images" ON storage.objects;
CREATE POLICY "Users can delete their vehicle images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'vehicle-images');

DROP POLICY IF EXISTS "Users can delete their vehicle images" ON images;
CREATE POLICY "Users can delete their vehicle images"
  ON images FOR DELETE
  TO authenticated
  USING (
    entity_type = 'vehicle'
    AND entity_id IN (
      SELECT id FROM vehicles WHERE user_id = auth.uid()
    )
  );

