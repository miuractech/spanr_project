# URGENT FIX - Storage Policies Missing!

## ✅ Database Policies - FIXED
All database policies are now working:
- ✅ Orders: INSERT policy exists
- ✅ Payments: INSERT policy exists  
- ✅ order_before_images: INSERT policy exists
- ✅ order_history: Trigger function fixed with SECURITY DEFINER

## ❌ Storage Policies - MISSING (This is the problem!)

The storage bucket exists but **NO POLICIES** have been created. This is blocking image uploads.

## Fix Now (2 minutes)

### Go to Supabase Dashboard

1. **Storage** → Click on `orders` bucket → **Policies** tab

2. **Create Policy 1: Upload**
   - Click **"New Policy"**
   - Choose **"For full customization"**
   - **Policy name**: `Allow authenticated uploads`
   - **Allowed operation**: Check **INSERT**
   - **Target roles**: Select `authenticated`
   - **Policy definition (WITH CHECK)**: 
     ```sql
     bucket_id = 'orders'
     ```
   - Click **Review** → **Save policy**

3. **Create Policy 2: View**
   - Click **"New Policy"**
   - Choose **"For full customization"**
   - **Policy name**: `Allow public reads`
   - **Allowed operation**: Check **SELECT**
   - **Target roles**: Select `public`
   - **Policy definition (USING)**: 
     ```sql
     bucket_id = 'orders'
     ```
   - Click **Review** → **Save policy**

## Test Order Creation

After creating these 2 policies:
1. Open your Flutter app
2. Try creating an order again
3. It should now work!

## What Was Fixed

1. ✅ **Trigger Function**: Added `SECURITY DEFINER` so order_history can be inserted by the trigger
2. ✅ **Database Policies**: All INSERT policies verified to be in place
3. ⏳ **Storage Policies**: YOU NEED TO CREATE THESE NOW (see above)

## Why Storage Policies Can't Be Created via SQL

Supabase storage policies must be created through the Dashboard UI because:
- They require special permissions on the `storage.objects` table
- The storage schema has different access controls
- SQL migrations don't have sufficient privileges

## Verification

After creating storage policies, run this in SQL Editor to verify:

```sql
SELECT 
  policyname,
  cmd as operation,
  roles
FROM pg_policies 
WHERE schemaname = 'storage'
AND tablename = 'objects';
```

Should show your 2 new policies.

