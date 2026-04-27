# Payment Webhook Implementation Guide

This document describes the implementation of Razorpay payment webhook handling for order confirmations in the SPANR application.

## Overview

The payment flow now includes:
1. User initiates payment through Razorpay
2. Payment is marked as "processing"
3. Webhook receives payment confirmation from Razorpay
4. Payment status is updated to "paid" or "failed"
5. User is redirected to order confirmation or error screen

## Database Changes

### 1. Payment Status Enum Update
Added new payment statuses in migration `014_add_payment_processing_status.sql`:
- `unpaid` - Initial status when payment is created
- `processing` - Payment initiated, waiting for webhook confirmation
- `paid` - Payment confirmed by webhook
- `failed` - Payment failed

### 2. New Tables
- `payment_webhook_events` - Tracks all webhook events received from Razorpay
  - Stores event type, payload, and processing status
  - Helps with debugging and audit trails

### 3. New Payment Fields
- `failure_reason` - Stores error message if payment fails

## Webhook Implementation

### Edge Function: `razorpay-webhook`
Location: `spanr-mechanic/supabase/functions/razorpay-webhook/index.ts`

**Features:**
- Verifies Razorpay signature for security
- Handles `payment.captured` and `payment.failed` events
- Updates payment status in database
- Stores webhook events for audit trail

**Environment Variables Required:**
- `RAZORPAY_WEBHOOK_SECRET` - Webhook secret from Razorpay dashboard
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key for database access

### Deployment

```bash
# Deploy webhook function
cd spanr-mechanic
supabase functions deploy razorpay-webhook

# Set environment variables
supabase secrets set RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_here
```

### Razorpay Dashboard Setup

1. Go to Razorpay Dashboard → Settings → Webhooks
2. Add new webhook URL: `https://your-project.supabase.co/functions/v1/razorpay-webhook`
3. Subscribe to events:
   - `payment.captured`
   - `payment.failed`
4. Copy the webhook secret and set it as environment variable

## Flutter App Changes

### 1. Payment Flow

**Updated Files:**
- `order_service.dart` - Added payment polling functionality
- `order_provider.dart` - Updated payment callbacks
- `checkout_screen.dart` - New navigation flow

**Flow:**
```
1. User clicks "Pay Now"
2. Order created → Images uploaded → Payment record created
3. Razorpay payment gateway opens
4. User completes payment
5. Payment marked as "processing"
6. Navigate to "Payment Processing" screen
7. Poll payment status every 2 seconds (max 30 attempts = 1 minute)
8. Once webhook updates status:
   - If "paid" → Navigate to Order Confirmation
   - If "failed" → Show error with retry option
```

### 2. New Screens

#### Payment Processing Screen
`payment_processing_screen.dart`
- Shows loading spinner while waiting for webhook
- Displays payment status
- Allows retry on failure

#### Order Confirmation Screen
`order_confirmation_screen.dart`
- Shows order details
- Displays payment confirmation
- Navigation to order details and orders list

### 3. Order Types Update

Added display names for payment statuses:
```dart
enum PaymentStatus {
  unpaid,      // "Unpaid"
  processing,  // "Processing"
  paid,        // "Paid"
  failed       // "Failed"
}
```

### 4. Router Updates

Added new routes in `app_router.dart`:
- `/orders` - List all user orders
- `/orders/:id` - Order details
- `/order-confirmation` - Post-payment success
- `/payment-processing` - Payment status screen

## Testing

### 1. Test Payment Flow

```dart
// Test successful payment
1. Create order
2. Complete payment on Razorpay
3. Verify webhook is received
4. Check payment status updates to "paid"
5. User sees confirmation screen

// Test failed payment
1. Create order
2. Cancel or fail payment on Razorpay
3. Verify webhook is received
4. Check payment status updates to "failed"
5. User sees error with retry option
```

### 2. Webhook Testing

Use Razorpay's webhook test tool:
1. Go to Dashboard → Webhooks → Test Webhook
2. Send test `payment.captured` event
3. Verify database updates correctly

### 3. Local Testing

```bash
# Run Supabase locally
supabase start

# Deploy function locally
supabase functions serve razorpay-webhook

# Test webhook with curl
curl -X POST http://localhost:54321/functions/v1/razorpay-webhook \
  -H "Content-Type: application/json" \
  -H "x-razorpay-signature: test_signature" \
  -d '{"event": "payment.captured", "payload": {...}}'
```

## Security Considerations

1. **Webhook Signature Verification**
   - Always verify Razorpay signature before processing
   - Use HMAC SHA256 with webhook secret

2. **Payment Status Transitions**
   - Only allow valid state transitions
   - Once "paid", status cannot change to "failed"
   - Implement idempotency for webhook events

3. **Environment Variables**
   - Never commit secrets to repository
   - Use Supabase secrets for production
   - Use `.env` for local development

## Monitoring

### Check Webhook Events

```sql
-- View recent webhook events
SELECT * FROM payment_webhook_events 
ORDER BY created_at DESC 
LIMIT 10;

-- Check unprocessed events
SELECT * FROM payment_webhook_events 
WHERE processed = false;

-- View payment status distribution
SELECT status, COUNT(*) 
FROM payments 
GROUP BY status;
```

### Common Issues

1. **Webhook not received**
   - Check Razorpay webhook URL is correct
   - Verify webhook is active in dashboard
   - Check function logs: `supabase functions logs razorpay-webhook`

2. **Payment stuck in "processing"**
   - Check webhook events table for errors
   - Manually update payment if needed
   - Increase polling timeout if necessary

3. **Signature verification fails**
   - Verify webhook secret is correct
   - Check request body is not modified
   - Ensure correct HMAC algorithm

## Future Enhancements

1. **Retry Failed Webhooks**
   - Implement automatic retry for failed webhook processing
   - Store retry count and last attempt time

2. **Payment Reconciliation**
   - Daily job to reconcile payments with Razorpay
   - Flag discrepancies for manual review

3. **Webhook Analytics**
   - Track webhook delivery times
   - Monitor failure rates
   - Alert on anomalies

4. **Refund Support**
   - Handle `refund.processed` events
   - Update order status on refund
   - Notify user of refund

## Support

For issues related to:
- Razorpay integration: Check Razorpay documentation
- Supabase functions: Check Supabase Edge Functions docs
- Flutter payment flow: Review order_provider.dart implementation

