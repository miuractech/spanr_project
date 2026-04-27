# Storage Setup Guide

## Setup Steps

### Step 1: Create Bucket (SQL)

Run this SQL file in your Supabase SQL Editor:
```
spanr-mechanic/sql/migrations/012_setup_storage_buckets.sql
```

This will create the `orders` bucket with:
- Public access enabled
- 5MB file size limit
- Allowed MIME types: image/jpeg, image/png, image/jpg, image/webp

### Step 2: Set Up Policies (Dashboard)

Storage policies must be created through the Supabase Dashboard.

## Manual Setup (Alternative)

### Create Bucket Manually

1. Go to **Supabase Dashboard** → **Storage**
2. Click **"New bucket"**
3. Configure:
   - **Name**: `orders`
   - **Public bucket**: ✅ Enable (so images can be viewed publicly)
   - **File size limit**: 5242880 (5MB)
   - **Allowed MIME types**: 
     - image/jpeg
     - image/png
     - image/jpg
     - image/webp
4. Click **"Create bucket"**

### Set Up Policies (Required)

1. Go to **Supabase Dashboard** → **Storage** → Click on `orders` bucket
2. Click on **"Policies"** tab
3. Click **"New Policy"**

Create these 4 policies:

#### Policy 1: Allow Upload (INSERT)
- Click **"New Policy"** → **"Custom"**
- **Policy name**: `Authenticated users can upload order images`
- **Allowed operation**: INSERT ✅
- **Target roles**: `authenticated`
- **Policy definition** (USING expression):
  ```sql
  bucket_id = 'orders'
  ```
- Click **"Review"** → **"Save policy"**

#### Policy 2: Allow Public View (SELECT)
- Click **"New Policy"** → **"Custom"**  
- **Policy name**: `Public can view order images`
- **Allowed operation**: SELECT ✅
- **Target roles**: `public`
- **Policy definition** (USING expression):
  ```sql
  bucket_id = 'orders'
  ```
- Click **"Review"** → **"Save policy"**

#### Policy 3: Allow Update (Optional)
- Click **"New Policy"** → **"Custom"**
- **Policy name**: `Users can update recent uploads`
- **Allowed operation**: UPDATE ✅
- **Target roles**: `authenticated`
- **Policy definition** (USING expression):
  ```sql
  bucket_id = 'orders' AND created_at > NOW() - INTERVAL '1 hour'
  ```
- Click **"Review"** → **"Save policy"**

#### Policy 4: Allow Delete (Optional)
- Click **"New Policy"** → **"Custom"**
- **Policy name**: `Users can delete recent uploads`
- **Allowed operation**: DELETE ✅
- **Target roles**: `authenticated`
- **Policy definition** (USING expression):
  ```sql
  bucket_id = 'orders' AND created_at > NOW() - INTERVAL '1 hour'
  ```
- Click **"Review"** → **"Save policy"**

## Folder Structure

The app will automatically create this folder structure:
```
orders/
  └── order_images/
      ├── before/
      │   └── {orderId}_before_{timestamp}_{index}.{ext}
      └── after/
          └── {orderId}_after_{timestamp}_{index}.{ext}
```

## Testing

After setup, test by:
1. Creating an order in the app
2. Uploading before images
3. Check Supabase Storage → `orders` bucket to verify files

## Troubleshooting

### Error: "Bucket not found"
- Verify bucket `orders` exists in Storage
- Check bucket name is exactly `orders` (lowercase)

### Error: "Policy violation"
- Check RLS policies are created
- Verify user is authenticated
- Check policy conditions match your upload path

### Images not displaying
- Verify bucket is set to **public**
- Check image URLs are correct
- Verify MIME types are allowed

### Upload fails
- Check file size (must be < 5MB)
- Verify file type is image (jpeg, png, jpg, webp)
- Check user is authenticated
- Verify RLS policies allow INSERT

## Security Notes

- Images are public (anyone with URL can view)
- Only authenticated users can upload
- Users can update/delete only within 1 hour of upload
- All uploads must go to `order_images` folder
- File size limited to 5MB
- Only image MIME types allowed

## Alternative: Using Dashboard Only

If you prefer not to use SQL, you can create the bucket entirely through the Supabase Dashboard:

1. **Storage** → **New bucket** → Name: `orders`, Public: Yes
2. **Policies** → Add the 4 policies shown above using the policy editor
3. Test by uploading a file through the Dashboard

That's it! The storage is now ready for order images.

