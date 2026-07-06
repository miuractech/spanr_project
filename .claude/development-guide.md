# Development Guide

## Prerequisites

- Node.js (for React dashboard)
- Flutter SDK ^3.9.2
- Dart SDK
- Supabase CLI (for Edge Functions)
- Firebase CLI (for deployment)
- Git

## Environment Setup

### React Dashboard

Create `spanr-mechanic/.env.local`:
```env
VITE_SUPABASE_URL=https://afwkdsbdwoytsdexwjkk.supabase.co
VITE_SUPABASE_ANON_KEY=<anon key>
VITE_APP_URL=http://localhost:3000
```

### Flutter User App (`spanr_app`)

Create `spanr_app/.env` or configure via `--dart-define`:
```
SUPABASE_URL=https://afwkdsbdwoytsdexwjkk.supabase.co
SUPABASE_ANON_KEY=<anon key>
RAZORPAY_KEY_ID=rzp_test_SiX0rZlVuhU7lY
```

### Flutter Mechanic App (`spanr-mechanic-app`)

```
SUPABASE_URL=https://afwkdsbdwoytsdexwjkk.supabase.co
SUPABASE_ANON_KEY=<anon key>
```

### Edge Functions (Supabase Secrets)

Set via `supabase secrets set`:
```
RAZORPAY_KEY_ID=...
RAZORPAY_KEY_SECRET=...
RAZORPAY_WEBHOOK_SECRET=...
```

---

## Running Locally

### React Dashboard
```bash
cd spanr-mechanic
npm install
npm run dev          # http://localhost:3000
```

### Flutter User App
```bash
cd spanr_app
flutter pub get
flutter run          # select device when prompted
```

### Flutter Mechanic App
```bash
cd spanr-mechanic-app
flutter pub get
flutter run
```

### Edge Functions (Local)
```bash
cd spanr-mechanic
supabase start       # local Supabase instance
supabase functions serve signup-owner
supabase functions serve razorpay-webhook
```

---

## Building for Production

### React Dashboard
```bash
cd spanr-mechanic
npm run build        # output in dist/
```

### Flutter
```bash
flutter build apk          # Android APK
flutter build appbundle    # Android AAB (Play Store)
flutter build ios          # iOS (requires macOS + Xcode)
flutter build web          # Web
```

---

## Running Tests

No test files were found in the repository — test coverage is not yet established.

For React: `npm test` (if configured)
For Flutter: `flutter test`

---

## Deployment

### Dashboard (Firebase Hosting)

Manual:
```bash
cd spanr-mechanic
npm run deploy:firebase    # runs: npm run build && firebase deploy --only hosting
```

Automatic: Push to branch `changes_5_5_26` → GitHub Actions triggers Firebase deploy.

Firebase project ID: `fir-9-dojo-44cec`
Live URL: `https://fir-9-dojo-44cec.web.app`

### Edge Functions
```bash
cd spanr-mechanic
supabase functions deploy signup-owner
supabase functions deploy provision-staff-auth
supabase functions deploy reset-staff-password
supabase functions deploy razorpay-webhook
supabase functions deploy create-razorpay-order
```

### Database Migrations
```bash
supabase db push    # apply pending migrations
```

Or apply SQL files manually in Supabase dashboard SQL editor.

---

## Common Development Tasks

### Adding a New API Endpoint (Edge Function)
1. Create `supabase/functions/<name>/index.ts`
2. Follow existing pattern (CORS headers, auth check, error handling)
3. Add to `supabase/config.toml` if needed
4. Deploy: `supabase functions deploy <name>`

### Adding a New DB Table
1. Create migration file: `sql/migrations/040_description.sql`
2. Add RLS policies (always scope to `user_company_id()`)
3. Add `updated_at` trigger
4. Add to `src/types/supabase.config.ts` (or regenerate)
5. Create service functions and TypeScript types

### Adding a New Dashboard Page
1. Create `src/pages/<page>.tsx`
2. Add route to `src/App.tsx`
3. Create `src/<domain>/<domain>.service.ts` if needed
4. Add nav link to sidebar

### Adding a New Flutter Screen
1. Create `lib/<domain>/screens/<screen>_screen.dart`
2. Add route to `lib/config/app_router.dart`
3. Update provider if new state needed

---

## Supabase Project Details

- **Project ID**: `afwkdsbdwoytsdexwjkk`
- **URL**: `https://afwkdsbdwoytsdexwjkk.supabase.co`
- **Firebase Project**: `fir-9-dojo-44cec`

---

## Gotchas & Tips

- **Company ID in React**: Never hardcode. Always call `user_company_id()` RPC or read from `CompanyContext`
- **Staff auth in mechanic app**: Staff email is `<phone>@spanr.staff` — never display this to the user; show phone number instead
- **Realtime in mechanic app**: Subscriptions are in `jobs_provider.dart` — ensure they're disposed in `dispose()`
- **Partial unique index**: The `uq_order_active_assignment` index prevents inserting a second active assignment — always use the `assign_order_to_staff` RPC
- **Image uploads**: Always upload to the correct bucket or RLS will block it
- **Razorpay amount**: Always in paise (₹1 = 100 paise) when calling the API
