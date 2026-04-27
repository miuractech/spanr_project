# Quick Setup Guide - Payment Webhook Implementation

Follow these steps to get the payment webhook system working:

## 1. Database Setup

```bash
# Connect to your Supabase database
# Run the migration to add payment processing status

cd spanr-mechanic
supabase db push

# Or manually run the migration file
psql -h <your-db-host> -U postgres -d postgres -f sql/migrations/014_add_payment_processing_status.sql
```

## 2. Deploy Webhook Edge Function

```bash
cd spanr-mechanic

# Login to Supabase (if not already)
supabase login

# Link your project (if not already)
supabase link --project-ref <your-project-ref>

# Deploy the webhook function
supabase functions deploy razorpay-webhook

# Set the webhook secret (get this from Razorpay dashboard)
supabase secrets set RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_here
```

## 3. Configure Razorpay Webhook

1. Login to [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Go to **Settings** → **Webhooks**
3. Click **+ Add New Webhook**
4. Enter webhook URL:
   ```
   https://<your-project-ref>.supabase.co/functions/v1/razorpay-webhook
   ```
5. Select **Active Events**:
   - ✅ `payment.captured`
   - ✅ `payment.failed`
6. Click **Create Webhook**
7. Copy the **Webhook Secret** and use it in step 2 above

## 4. Test the Implementation

### Test Successful Payment
1. Open Flutter app
2. Select a service and add to cart
3. Go to checkout
4. Click "Pay Now"
5. Complete payment in Razorpay test mode
6. Verify:
   - Payment processing screen appears
   - After ~2-5 seconds, confirmation screen appears
   - Order appears in "My Orders" tab
   - Payment status is "Paid"

### Test Failed Payment
1. Open Flutter app
2. Go through checkout flow
3. In Razorpay, cancel or fail the payment
4. Verify:
   - Error screen appears
   - Failure reason is displayed
   - "Try Again" button is available
   - Can navigate back to home

### Verify Webhook Events
```sql
-- Check recent webhook events
SELECT * FROM payment_webhook_events 
ORDER BY created_at DESC 
LIMIT 10;

-- Check payment statuses
SELECT 
  id,
  status,
  amount,
  razorpay_payment_id,
  failure_reason,
  created_at
FROM payments 
ORDER BY created_at DESC 
LIMIT 10;
```

## 5. Monitor Webhook Health

### Check Function Logs
```bash
# View webhook function logs
supabase functions logs razorpay-webhook

# Follow logs in real-time
supabase functions logs razorpay-webhook --follow
```

### Check for Errors
```sql
-- Find failed webhooks
SELECT * FROM payment_webhook_events 
WHERE processed = false;

-- Find stuck payments (processing for > 5 minutes)
SELECT * FROM payments 
WHERE status = 'processing' 
AND created_at < NOW() - INTERVAL '5 minutes';
```

## Troubleshooting

### Webhook Not Received
1. Check webhook URL is correct
2. Verify webhook is active in Razorpay dashboard
3. Check function logs for errors
4. Test webhook manually:
   ```bash
   curl -X POST https://your-project.supabase.co/functions/v1/razorpay-webhook \
     -H "Content-Type: application/json" \
     -H "x-razorpay-signature: test" \
     -d '{"event": "payment.captured", "payload": {...}}'
   ```

### Payment Stuck in Processing
1. Check `payment_webhook_events` table for errors
2. Verify webhook secret is correct
3. Manually update payment status if needed:
   ```sql
   UPDATE payments 
   SET status = 'paid', paid_at = NOW() 
   WHERE id = '<payment-id>';
   ```

### App Not Polling Payment Status
1. Check Flutter console for errors
2. Verify `getPaymentById` method is working
3. Increase polling timeout if needed (in `order_service.dart`)

## Environment Variables

Required in Supabase Edge Functions:
- `RAZORPAY_WEBHOOK_SECRET` - From Razorpay dashboard
- `SUPABASE_URL` - Automatically available
- `SUPABASE_SERVICE_ROLE_KEY` - Automatically available

Required in Flutter `.env`:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon key
- `RAZORPAY_KEY_ID` - Your Razorpay key ID

## Next Steps

1. ✅ Complete setup above
2. ✅ Test in development environment
3. ✅ Monitor for 24-48 hours
4. ✅ Review webhook logs and fix any issues
5. ✅ Deploy to production
6. ✅ Set up monitoring/alerting

## Support

- Razorpay Docs: https://razorpay.com/docs/webhooks/
- Supabase Edge Functions: https://supabase.com/docs/guides/functions
- Project Docs: See `PAYMENT_WEBHOOK_SETUP.md` for detailed implementation

## Checklist

- [ ] Database migration applied
- [ ] Edge function deployed
- [ ] Webhook secret set in Supabase
- [ ] Razorpay webhook configured
- [ ] Successful payment tested
- [ ] Failed payment tested
- [ ] Webhook events logging correctly
- [ ] Orders displaying in app
- [ ] Payment statuses correct
- [ ] Error handling working

