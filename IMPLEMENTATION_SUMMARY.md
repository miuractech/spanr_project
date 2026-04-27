# Payment Webhook & Order Confirmation Implementation

## Summary

Implemented complete payment flow with webhook verification, order confirmation, and order management features.

## Changes Made

### 1. Database (Supabase)

#### Migration: `014_add_payment_processing_status.sql`
- Updated `payment_status` enum to include:
  - `unpaid` - Initial status
  - `processing` - Payment initiated, awaiting confirmation
  - `paid` - Payment successful
  - `failed` - Payment failed
- Added `failure_reason` column to `payments` table
- Created `payment_webhook_events` table to track all webhook events from Razorpay

#### Edge Function: `razorpay-webhook`
- Location: `spanr-mechanic/supabase/functions/razorpay-webhook/index.ts`
- Verifies Razorpay webhook signatures for security
- Handles `payment.captured` and `payment.failed` events
- Updates payment status in real-time
- Stores webhook events for audit trail

### 2. Flutter App

#### Updated Models & Types
- `order_types.dart` - Added `displayName` getter to `PaymentStatus`
- `order_model.dart` - Added `failureReason` field to `PaymentModel`

#### New Services
- `order_service.dart`:
  - `updatePaymentProcessing()` - Marks payment as processing
  - `waitForPaymentResolution()` - Polls payment status until resolved
  - `getPaymentById()` - Fetches payment by ID
  - `getOrderWithDetails()` - Fetches complete order information

#### New Screens

1. **Order Confirmation Screen** (`order_confirmation_screen.dart`)
   - Shows order success message
   - Displays order and payment details
   - Navigation to order details and orders list

2. **Payment Processing Screen** (`payment_processing_screen.dart`)
   - Shows loading state while waiting for webhook
   - Displays payment status (processing/success/failed)
   - Retry option on payment failure
   - Shows failure reason if available

3. **Orders Screen** (Enhanced - already existed)
   - Lists all user orders with status badges
   - Shows order date, scheduled date, and location
   - Click to view order details
   - Pull to refresh functionality

4. **Order Details Screen** (Enhanced - already existed)
   - Complete order information
   - Payment status with visual indicators
   - Order timeline with status history
   - Before/after service images
   - Cancel order option (for created/accepted orders)

#### Updated Screens

1. **Checkout Screen** (`checkout_screen.dart`)
   - Updated payment flow with new callbacks:
     - `onPaymentInitiated` - Navigate to processing screen
     - `onPaymentSuccess` - Navigate to confirmation screen
     - `onPaymentError` - Navigate to error screen with retry

2. **Home Screen** (`home_screen.dart`)
   - Replaced placeholder Orders tab with actual `OrdersScreen`

#### Updated Providers
- `order_provider.dart`:
  - Updated `createOrderWithPayment()` with new callback structure
  - Integrated payment polling logic
  - Better error handling with order/payment context

#### Router Updates
- `app_router.dart` - Added new routes:
  - `/orders` - Orders list
  - `/orders/:id` - Order details
  - `/order-confirmation` - Post-payment success
  - `/payment-processing` - Payment status

## Payment Flow

```
1. User adds items to cart
2. User proceeds to checkout
3. User clicks "Pay Now"
   ↓
4. Order created in database
5. Before images uploaded to storage
6. Razorpay order created
7. Payment record created (status: unpaid)
   ↓
8. Razorpay payment gateway opens
9. User completes payment
   ↓
10. Razorpay callback received by app
11. Payment status updated to "processing"
12. Navigate to "Payment Processing" screen
    ↓
13. App polls payment status every 2 seconds
    (max 30 attempts = 60 seconds)
    ↓
14. Razorpay webhook hits Edge Function
15. Webhook verifies signature
16. Payment status updated to "paid" or "failed"
    ↓
17. Polling detects status change
18. Navigate to appropriate screen:
    - If paid → Order Confirmation Screen
    - If failed → Error Screen with retry option
```

## Features Implemented

### ✅ Webhook-based Payment Verification
- Secure signature verification
- Real-time payment status updates
- Audit trail of all webhook events

### ✅ Payment Status Polling
- Polls every 2 seconds for up to 1 minute
- Graceful timeout handling
- Prevents user from getting stuck

### ✅ Order Confirmation Flow
- Beautiful confirmation screen with all details
- Quick navigation to orders or order details
- Clears cart on successful payment

### ✅ Payment Failure Handling
- Shows clear error messages
- Displays failure reason from Razorpay
- Easy retry mechanism
- Option to go back to home

### ✅ Orders Management
- View all orders with status badges
- Filter by status (implicitly via visual badges)
- Pull to refresh
- Order details with complete information

### ✅ Order Status Tracking
- Order timeline with history
- Visual status indicators
- Real-time updates

## Testing Checklist

- [ ] Run database migration `014_add_payment_processing_status.sql`
- [ ] Deploy Razorpay webhook Edge Function
- [ ] Set `RAZORPAY_WEBHOOK_SECRET` in Supabase
- [ ] Configure webhook URL in Razorpay dashboard
- [ ] Test successful payment flow
- [ ] Test failed payment flow
- [ ] Test payment timeout scenario
- [ ] Verify webhook events are logged
- [ ] Test order list loading
- [ ] Test order details view
- [ ] Verify images display correctly
- [ ] Test order cancellation

## Environment Setup

### Supabase
```bash
# Apply migration
psql -U postgres -d spanr -f spanr-mechanic/sql/migrations/014_add_payment_processing_status.sql

# Deploy webhook function
cd spanr-mechanic
supabase functions deploy razorpay-webhook

# Set webhook secret
supabase secrets set RAZORPAY_WEBHOOK_SECRET=your_secret_here
```

### Razorpay Dashboard
1. Navigate to Settings → Webhooks
2. Add webhook URL: `https://your-project.supabase.co/functions/v1/razorpay-webhook`
3. Select events: `payment.captured`, `payment.failed`
4. Save and copy webhook secret
5. Set secret in Supabase (above)

## Files Created
- `spanr-mechanic/sql/migrations/014_add_payment_processing_status.sql`
- `spanr-mechanic/supabase/functions/razorpay-webhook/index.ts`
- `spanr_app/lib/booking/order_confirmation_screen.dart`
- `spanr_app/lib/booking/payment_processing_screen.dart`
- `PAYMENT_WEBHOOK_SETUP.md`
- `IMPLEMENTATION_SUMMARY.md`

## Files Modified
- `spanr_app/lib/booking/order_types.dart`
- `spanr_app/lib/booking/order_model.dart`
- `spanr_app/lib/booking/order_service.dart`
- `spanr_app/lib/booking/order_provider.dart`
- `spanr_app/lib/booking/checkout_screen.dart`
- `spanr_app/lib/booking/orders_screen.dart`
- `spanr_app/lib/config/app_router.dart`
- `spanr_app/lib/screens/home_screen.dart`

## Security Considerations

1. ✅ Webhook signature verification implemented
2. ✅ Using service role key for webhook (not accessible to clients)
3. ✅ Payment status transitions are one-way (can't go from paid to unpaid)
4. ✅ Webhook events logged for audit
5. ✅ CORS properly configured in Edge Function

## Next Steps (Future Enhancements)

1. **Push Notifications**
   - Notify user when payment is confirmed
   - Alert when order status changes

2. **Refund Support**
   - Handle refund webhooks
   - Update order status
   - Show refund in order history

3. **Payment Reconciliation**
   - Daily job to verify all payments match Razorpay
   - Flag discrepancies

4. **Analytics**
   - Track payment success rates
   - Monitor webhook delivery times
   - Alert on anomalies

5. **Retry Failed Webhooks**
   - Automatic retry mechanism
   - Manual retry option in admin panel

