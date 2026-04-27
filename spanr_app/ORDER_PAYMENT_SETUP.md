# Order Creation and Payment Setup

This guide explains how to set up and use the order creation and payment integration with Razorpay.

## Database Changes

The database schema has been updated with the following changes:

### New Order Statuses
- `created` - Order has been created
- `accepted` - Mechanic has accepted the order
- `in_progress` - Service is in progress
- `ready_for_delivery` - Service completed, ready for pickup/delivery
- `completed` - Order completed successfully
- `dispute` - There's a dispute on the order
- `cancelled` - Order has been cancelled

### New Tables
1. **order_history** - Tracks all status changes of an order
   - Automatically populated via database trigger when order status changes
   - Shows complete timeline of order lifecycle

2. **Updated payments table** - Added Razorpay fields:
   - `razorpay_order_id` - Razorpay order ID
   - `razorpay_payment_id` - Razorpay payment ID after successful payment
   - `razorpay_signature` - Razorpay signature for verification

## Setup Instructions

### 1. Run Database Migration

Apply the migration file:
```sql
-- Run this file in Supabase SQL Editor
spanr-mechanic/sql/migrations/011_update_order_status_and_history.sql
```

### 2. Create Supabase Storage Bucket

**Option A: Run SQL Migration (Recommended)**
```sql
-- Run this file in Supabase SQL Editor
spanr-mechanic/sql/migrations/012_setup_storage_buckets.sql
```

**Option B: Manual Setup**
See detailed instructions in `spanr_app/STORAGE_SETUP.md`

Quick manual setup:
1. Go to Supabase Dashboard > Storage
2. Create a new bucket named `orders` (public: yes)
3. The app will automatically create folders when uploading

### 3. Deploy Razorpay Edge Function

Deploy the edge function to create Razorpay orders:

```bash
cd spanr-mechanic
supabase functions deploy create-razorpay-order
```

Set environment variables for the edge function:
```bash
supabase secrets set RAZORPAY_KEY_ID=your_razorpay_key_id
supabase secrets set RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

### 4. Configure Razorpay in Flutter

Update the Razorpay key in:
```dart
// spanr_app/lib/booking/order_service.dart
// Line ~140
'key': 'YOUR_RAZORPAY_KEY_ID', // Replace with your key

// OR better - add to .env file:
RAZORPAY_KEY_ID=your_razorpay_key_id
```

### 5. Update Flutter Dependencies

Run:
```bash
cd spanr_app
flutter pub get
```

### 6. Configure Android (if needed)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 7. Configure iOS (if needed)

No additional configuration needed for Razorpay on iOS.

## How It Works

### Order Creation Flow

1. **User selects services** → Adds to cart
2. **User selects vehicle** → Chooses or adds new vehicle
3. **User takes before photos** → Required photos before service
4. **User proceeds to checkout** → Reviews order details
5. **User initiates payment** → Order is created in database
6. **Before images uploaded** → Images uploaded to Supabase Storage
7. **Razorpay order created** → Via edge function
8. **Payment gateway opens** → Razorpay handles payment
9. **Payment success/failure** → Order status updated accordingly

### Order History Tracking

The system automatically tracks all order status changes:
- Each status change creates an entry in `order_history`
- Includes timestamp, status, and optional notes
- Displayed as timeline in order details screen

### Payment Integration

1. **Create Order** → Order created with status 'created'
2. **Create Razorpay Order** → Edge function creates Razorpay order
3. **Create Payment Record** → Payment record with 'unpaid' status
4. **Open Razorpay** → Payment gateway opens
5. **Payment Success** → Payment record updated with Razorpay IDs and status 'paid'
6. **Payment Failure** → User notified, can retry

## Available Screens

### Orders Screen (`/orders`)
- Lists all user orders
- Shows order status with colored badges
- Pull to refresh
- Navigate to order details

### Order Details Screen (`/orders/:id`)
- Complete order information
- Order timeline with status history
- Before/after service photos
- Payment details
- Cancel order option (for eligible statuses)

## Testing

1. **Create Test Order**
   - Add services to cart
   - Select a vehicle
   - Take/upload before photos
   - Proceed to checkout
   - Fill in service details
   - Click "Pay Now"

2. **Test Payment**
   - Use Razorpay test mode
   - Test cards available at: https://razorpay.com/docs/payments/payments/test-card-details/

3. **View Order**
   - Go to Orders screen
   - Click on order to see details
   - Check order timeline

## Important Notes

### Storage Bucket
- Ensure the `orders` bucket exists in Supabase Storage
- Configure public access or appropriate RLS policies
- Images are stored as: `order_images/before/{orderId}_before_{timestamp}_{index}.{ext}`

### Edge Function
- Must be deployed for payment to work
- Requires Razorpay API credentials
- Handles Razorpay order creation securely

### Security
- Never expose Razorpay key secret in client code
- Use edge function for server-side operations
- Validate payment signature on success

### RLS Policies
- Users can only view their own orders
- Company staff can view orders for their company
- Order history follows same access rules

## Razorpay Account Setup

1. Sign up at https://razorpay.com/
2. Go to Settings > API Keys
3. Generate API keys (test mode for development)
4. Copy Key ID and Key Secret
5. Add to edge function environment variables

## Troubleshooting

### Payment not working
- Check Razorpay credentials in edge function
- Verify edge function is deployed
- Check browser console for errors
- Ensure Razorpay package is imported correctly

### Images not uploading
- Verify storage bucket exists
- Check storage bucket permissions
- Ensure file size is within limits
- Check network connection

### Order history not showing
- Verify migration was run successfully
- Check if trigger is created: `trigger_create_order_history`
- Test by manually updating order status

## Next Steps

1. **Implement address selection** - Update service location with user's address
2. **Add notifications** - Notify user on status changes
3. **Add reviews** - Allow users to review completed orders
4. **Add receipt generation** - Generate PDF receipt after payment
5. **Implement refunds** - Handle payment refunds for cancellations

