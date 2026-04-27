# Edge Function Deployment Guide

## Deploy Razorpay Edge Function

### Option 1: Via Supabase Dashboard (Recommended)

1. Go to **Supabase Dashboard** → **Edge Functions**
2. Click **"Create a new function"**
3. **Function name**: `create-razorpay-order`
4. Copy the contents from:
   ```
   supabase/functions/create-razorpay-order/index.ts
   ```
5. Paste into the editor
6. Click **"Deploy"**

### Option 2: Via Supabase CLI

```bash
# Login to Supabase
npx supabase login

# Link your project
npx supabase link --project-ref YOUR_PROJECT_REF

# Deploy the function
npx supabase functions deploy create-razorpay-order

# Set environment variables
npx supabase secrets set RAZORPAY_KEY_ID=your_razorpay_key_id
npx supabase secrets set RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

## Set Environment Variables

After deploying, set the Razorpay credentials:

### Via Dashboard
1. Go to **Edge Functions** → **create-razorpay-order**
2. Click **"Settings"** tab
3. Add **Secrets**:
   - `RAZORPAY_KEY_ID`: Your Razorpay Key ID
   - `RAZORPAY_KEY_SECRET`: Your Razorpay Key Secret
4. Click **"Save"**

### Via CLI
```bash
npx supabase secrets set RAZORPAY_KEY_ID=rzp_test_xxxxx
npx supabase secrets set RAZORPAY_KEY_SECRET=xxxxx
```

## Get Razorpay Credentials

1. Go to https://dashboard.razorpay.com/
2. Login or Sign up
3. Go to **Settings** → **API Keys**
4. Click **"Generate Test Key"** (for development)
5. Copy:
   - **Key ID** (starts with `rzp_test_`)
   - **Key Secret**

## Test the Function

### Using curl
```bash
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/create-razorpay-order' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "amount": 50000,
    "currency": "INR",
    "receipt": "test_receipt_1"
  }'
```

### Expected Response
```json
{
  "id": "order_xxxxx",
  "entity": "order",
  "amount": 50000,
  "currency": "INR",
  "receipt": "test_receipt_1",
  "status": "created",
  "created_at": 1234567890
}
```

## Troubleshooting

### Error: "Razorpay credentials not configured"
- Verify secrets are set correctly
- Check secret names match exactly: `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`
- Redeploy function after setting secrets

### Error: "Razorpay API error: Unauthorized"
- Verify Key ID and Secret are correct
- Check you're using test keys for development
- Ensure no extra spaces in secret values

### Error: "CORS error"
- The function includes CORS headers
- Check your app is using the correct function URL
- Verify Authorization header is included

### Function not found
- Verify function is deployed: Check Edge Functions in dashboard
- Check function name is exactly: `create-razorpay-order`
- Verify project URL is correct

## Production Deployment

For production:
1. Generate **Live Keys** from Razorpay Dashboard
2. Update secrets with live keys:
   ```bash
   npx supabase secrets set RAZORPAY_KEY_ID=rzp_live_xxxxx
   npx supabase secrets set RAZORPAY_KEY_SECRET=xxxxx
   ```
3. Test thoroughly before going live

## Security Notes

- Never commit API keys to version control
- Use test keys for development
- Live keys should only be in production environment
- Edge function keeps secrets secure on server
- Credentials never exposed to client

## Function URL

Your function will be available at:
```
https://YOUR_PROJECT_REF.supabase.co/functions/v1/create-razorpay-order
```

Replace `YOUR_PROJECT_REF` with your actual Supabase project reference.

