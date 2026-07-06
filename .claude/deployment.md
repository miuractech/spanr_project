# Deployment

## Infrastructure Overview

| Component | Platform | URL |
|---|---|---|
| React Dashboard | Firebase Hosting | `https://fir-9-dojo-44cec.web.app` |
| Database + Auth + Storage | Supabase | `https://afwkdsbdwoytsdexwjkk.supabase.co` |
| Edge Functions | Supabase Edge | `https://afwkdsbdwoytsdexwjkk.supabase.co/functions/v1/` |
| Flutter Apps | App stores / direct APK | Not yet published |

---

## CI/CD: GitHub Actions

### Merge Deploy (`firebase-hosting-merge.yml`)

**Trigger**: Push to branch `changes_5_5_26`

```yaml
steps:
  - checkout
  - cd spanr-mechanic && npm ci && npm run build
  - firebase deploy --only hosting
```

**Secrets required** (set in GitHub repository settings):
- `FIREBASE_SERVICE_ACCOUNT_FIR_9_DOJO_44CEC`
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

### PR Preview (`firebase-hosting-pull-request.yml`)

**Trigger**: Pull requests from same repo

Deploys to a temporary Firebase preview channel. URL posted as PR comment.

---

## Manual Dashboard Deployment

```bash
cd spanr-mechanic

# Ensure env vars are set in .env.production or environment
export VITE_SUPABASE_URL=https://afwkdsbdwoytsdexwjkk.supabase.co
export VITE_SUPABASE_ANON_KEY=<key>
export VITE_APP_URL=https://fir-9-dojo-44cec.web.app

npm run build
npx firebase deploy --only hosting
```

Or use the convenience script:
```bash
npm run deploy:firebase
```

---

## Edge Functions Deployment

```bash
cd spanr-mechanic

# Deploy all functions
supabase functions deploy signup-owner
supabase functions deploy provision-staff-auth
supabase functions deploy reset-staff-password
supabase functions deploy razorpay-webhook
supabase functions deploy create-razorpay-order

# Set secrets (one-time or when rotating)
supabase secrets set RAZORPAY_KEY_ID=rzp_xxx
supabase secrets set RAZORPAY_KEY_SECRET=xxx
supabase secrets set RAZORPAY_WEBHOOK_SECRET=xxx
```

---

## Database Migrations

```bash
# View pending migrations
supabase db diff

# Apply migrations
supabase db push

# Or apply individual SQL files via Supabase dashboard SQL editor
# File path: spanr-mechanic/sql/migrations/NNN_description.sql
```

---

## Firebase Configuration

`firebase.json`:
```json
{
  "hosting": {
    "public": "spanr-mechanic/dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
```

SPA routing: all paths rewrite to `/index.html`.

`.firebaserc`:
```json
{
  "projects": { "default": "fir-9-dojo-44cec" }
}
```

---

## Razorpay Webhook Setup

1. Log in to Razorpay Dashboard
2. Settings → Webhooks → Add Webhook
3. URL: `https://afwkdsbdwoytsdexwjkk.supabase.co/functions/v1/razorpay-webhook`
4. Events: `payment.captured`, `order.paid`, `payment.failed`
5. Secret: must match `RAZORPAY_WEBHOOK_SECRET` Supabase secret

---

## Production Checklist

- [ ] Swap Razorpay test key (`rzp_test_SiX0rZlVuhU7lY`) for live key
- [ ] Update `RAZORPAY_WEBHOOK_SECRET` to production webhook secret
- [ ] Change CI/CD trigger from `changes_5_5_26` branch to `main`
- [ ] Configure custom domain in Firebase Hosting (if needed)
- [ ] Enable Supabase PITR (point-in-time recovery) for the database
- [ ] Set up Supabase DB backups
- [ ] Review and tighten early RLS policies (`WITH CHECK (true)`)
- [ ] Add rate limiting to public Edge Functions (`signup-owner`)
- [ ] Publish Flutter apps to Play Store / App Store
