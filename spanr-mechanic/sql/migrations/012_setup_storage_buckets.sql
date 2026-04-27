-- =====================================================
-- Setup Storage Buckets for Order Images
-- =====================================================

-- Create the orders bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'orders',
  'orders',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- NOTE: Storage policies must be set up through Supabase Dashboard
-- Go to Storage > orders bucket > Policies to add these policies:
--
-- 1. Allow authenticated users to upload:
--    Operation: INSERT
--    Policy: authenticated users can upload to order_images folder
--
-- 2. Allow public to view:
--    Operation: SELECT  
--    Policy: public can view order images
--
-- See STORAGE_SETUP.md for detailed instructions

