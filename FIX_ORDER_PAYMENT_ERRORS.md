# Fix Order & Payment Errors - Quick Guide

## Current Error
```
Payment failed: StorageException(message: new row violates row-level security policy, statusCode: 403, error: Unauthorized)
```

## Root Cause
Missing INSERT policies for orders, payments, and order image tables.

## Fix Steps (In Order)

### 1. Run SQL Migrations

Run these 4 SQL files in your Supabase SQL Editor **in this order**:

```sql
-- File 1: Create order images tables
spanr-mechanic/sql/migrations/010_create_order_images_tables.sql

-- File 2: Fix order status and add history tracking
spanr-mechanic/sql/migrations/011_update_order_status_and_history.sql

-- File 3: Create storage bucket
spanr-mechanic/sql/migrations/012_setup_storage_buckets.sql

-- File 4: Fix missing INSERT policies (CRITICAL)
spanr-mechanic/sql/migrations/013_fix_order_insert_policies.sql
```

### 2. Set Up Storage Policies

Go to **Supabase Dashboard** → **Storage** → `orders` bucket → **Policies**

**Create 2 policies:**

#### Policy 1: Allow Upload
- **New Policy** → **For full customization**
- Name: `Authenticated users can upload`
- Allowed operation: **INSERT** ✅
- Target roles: `authenticated`
- Policy definition: `bucket_id = 'orders'`

#### Policy 2: Allow View
- **New Policy** → **For full customization**
- Name: `Public can view`
- Allowed operation: **SELECT** ✅
- Target roles: `public`
- Policy definition: `bucket_id = 'orders'`

### 3. Deploy Edge Function

**Option A: Via Dashboard (Easiest)**
1. Go to **Supabase Dashboard** → **Edge Functions**
2. Click **"Create a new function"**
3. Name: `create-razorpay-order`
4. Copy contents from: `spanr-mechanic/supabase/functions/create-razorpay-order/index.ts`
5. Paste and **Deploy**

**Option B: Via CLI**
```bash
npx supabase functions deploy create-razorpay-order
```

### 4. Set Razorpay Secrets

In **Edge Functions** → **create-razorpay-order** → **Settings** → **Secrets**:

Add:
- `RAZORPAY_KEY_ID` = `rzp_test_xxxxx` (get from Razorpay dashboard)
- `RAZORPAY_KEY_SECRET` = `xxxxx` (get from Razorpay dashboard)

Get keys from: https://dashboard.razorpay.com/app/keys

### 5. Update Flutter App

Update Razorpay key in the app:
```dart
// spanr_app/lib/booking/order_service.dart
// Line ~140
'key': 'rzp_test_xxxxx', // Your Razorpay Key ID
```

## Verify Setup

### 1. Check Database Policies
Run this in SQL Editor to verify policies exist:
```sql
SELECT tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('orders', 'payments', 'order_before_images')
ORDER BY tablename, policyname;
```

Should show:
- `orders`: INSERT policy for users
- `payments`: INSERT policy
- `order_before_images`: INSERT policy

### 2. Check Storage
- Go to **Storage** → `orders` bucket
- Verify bucket exists
- Check policies are active

### 3. Test Edge Function
```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/functions/v1/create-razorpay-order' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"amount": 50000, "currency": "INR", "receipt": "test_1"}'
```

Should return: `{"id": "order_xxxxx", ...}`

### 4. Test Order Creation
1. In app, add service to cart
2. Select vehicle
3. Take before photos
4. Proceed to checkout
5. Click "Pay Now"
6. Razorpay payment gateway should open

## Common Issues

### "Bucket not found"
- Run migration 012
- Or manually create `orders` bucket in Storage

### "Policy violation"
- Run migration 013
- Verify policies in SQL query above

### "Edge function not found"
- Deploy function via dashboard or CLI
- Check function name is exactly: `create-razorpay-order`

### "Razorpay credentials not configured"
- Set secrets in Edge Function settings
- Ensure exact names: `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`

### Payment gateway doesn't open
- Update Razorpay key in order_service.dart
- Check browser console for errors
- Verify Razorpay package is installed: `flutter pub get`

## Files Changed

### New Files Created:
1. `spanr-mechanic/sql/migrations/011_update_order_status_and_history.sql`
2. `spanr-mechanic/sql/migrations/012_setup_storage_buckets.sql`
3. `spanr-mechanic/sql/migrations/013_fix_order_insert_policies.sql`
4. `spanr-mechanic/supabase/functions/create-razorpay-order/index.ts`
5. `spanr_app/lib/booking/order_*.dart` (multiple files)

### Documentation:
- `spanr_app/ORDER_PAYMENT_SETUP.md` - Complete setup guide
- `spanr_app/STORAGE_SETUP.md` - Storage bucket setup
- `spanr-mechanic/EDGE_FUNCTION_DEPLOY.md` - Edge function deployment

## Next Steps After Fix

1. Test order creation end-to-end
2. Test payment with Razorpay test cards
3. Verify order appears in Orders screen
4. Check order history timeline
5. Test order cancellation

## Support

If issues persist:
1. Check Supabase logs: **Logs** → **Edge Functions**
2. Check app logs: Look for error messages
3. Verify all 3 migrations ran successfully
4. Ensure user is authenticated before placing order

---

**TL;DR**: Run 3 SQL migrations, set up storage policies, deploy edge function, set Razorpay secrets. Done!

