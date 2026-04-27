-- =====================================================
-- SPANR Platform - Supabase Storage Setup
-- =====================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public)
VALUES 
  ('company-logos', 'company-logos', true),
  ('company-images', 'company-images', true),
  ('service-icons', 'service-icons', true),
  ('plan-images', 'plan-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for company logos
CREATE POLICY "Anyone can view company logos"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'company-logos');

CREATE POLICY "Authenticated users can upload company logos"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'company-logos');

CREATE POLICY "Users can update their company logos"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'company-logos');

CREATE POLICY "Users can delete their company logos"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'company-logos');

-- Storage policies for company images
CREATE POLICY "Anyone can view company images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'company-images');

CREATE POLICY "Authenticated users can upload company images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'company-images');

CREATE POLICY "Users can update company images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'company-images');

CREATE POLICY "Users can delete company images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'company-images');

-- Storage policies for service icons
CREATE POLICY "Anyone can view service icons"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'service-icons');

CREATE POLICY "Authenticated users can upload service icons"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'service-icons');

CREATE POLICY "Users can update service icons"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'service-icons');

CREATE POLICY "Users can delete service icons"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'service-icons');

-- Storage policies for plan images
CREATE POLICY "Anyone can view plan images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'plan-images');

CREATE POLICY "Authenticated users can upload plan images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'plan-images');

CREATE POLICY "Users can update plan images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'plan-images');

CREATE POLICY "Users can delete plan images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'plan-images');

