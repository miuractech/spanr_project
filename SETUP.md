# SPANR — Setup Guide

Complete setup for all three applications and the Supabase backend.

---

## Prerequisites

Install these before anything else:

| Tool | Version | Install |
|---|---|---|
| Node.js | ≥ 20 | https://nodejs.org |
| Flutter | ≥ 3.9.2 | https://docs.flutter.dev/get-started/install |
| Dart | ≥ 3.9.2 | Bundled with Flutter |
| Supabase CLI | latest | `npm i -g supabase` |
| Firebase CLI | latest | `npm i -g firebase-tools` |
| Git | any | https://git-scm.com |

Verify installs:

```bash
node -v
flutter --version
supabase --version
firebase --version
```

---

## 1. Clone the Repository

```bash
git clone <repo-url>
cd spanr_project
```

---

## 2. Supabase Setup

### 2.1 Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) → New Project
2. Note your **Project URL** and **anon public key** (Settings → API)
3. Note your **service role key** (keep this secret — only for Edge Functions)

### 2.2 Run Migrations

From the project root or `spanr-mechanic/`:

```bash
# Login to Supabase CLI
supabase login

# Link to your remote project (find project-ref in your Supabase dashboard URL)
supabase link --project-ref <your-project-ref>

# Push all 039 migrations in order
supabase db push
```

Or run them manually in the Supabase SQL editor in order:
`spanr-mechanic/sql/migrations/001_*.sql` → `039_*.sql`

### 2.3 Apply Stored Functions and Storage

Run these in the Supabase SQL editor (or via `supabase db push`):

```bash
# Stored functions (SECURITY DEFINER — RLS core)
psql <connection-string> -f spanr-mechanic/sql/functions.sql

# Storage buckets + policies
psql <connection-string> -f spanr-mechanic/sql/storage.sql
```

### 2.4 Deploy Edge Functions

```bash
cd spanr-mechanic

# Deploy all Edge Functions
supabase functions deploy signup-owner
supabase functions deploy provision-staff-auth
supabase functions deploy create-razorpay-order
supabase functions deploy razorpay-verify-payment
supabase functions deploy razorpay-webhook
supabase functions deploy reset-staff-password
```

Set secrets for Edge Functions (Supabase Dashboard → Edge Functions → Secrets, or via CLI):

```bash
supabase secrets set RAZORPAY_KEY_ID=<your-key>
supabase secrets set RAZORPAY_KEY_SECRET=<your-secret>
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
```

---

## 3. React Dashboard (`spanr-mechanic/`)

### 3.1 Install Dependencies

```bash
cd spanr-mechanic
npm install
```

### 3.2 Environment Variables

Create `spanr-mechanic/.env`:

```env
VITE_SUPABASE_URL=https://<your-project-ref>.supabase.co
VITE_SUPABASE_ANON_KEY=<your-anon-key>
VITE_APP_URL=http://localhost:3000
```

### 3.3 Run Dev Server

```bash
npm run dev
# Opens at http://localhost:3000
```

### 3.4 Build for Production

```bash
npm run build
```

### 3.5 Deploy to Firebase Hosting

```bash
# Login to Firebase (first time only)
firebase login

# Deploy
npm run deploy:firebase
```

> CI/CD: Pushes to `changes_5_5_26` branch auto-deploy via GitHub Actions.
> Requires these GitHub Secrets set in the repo:
> - `VITE_SUPABASE_URL`
> - `VITE_SUPABASE_ANON_KEY`
> - `FIREBASE_SERVICE_ACCOUNT_FIR_9_DOJO_44CEC`

---

## 4. Flutter User App (`spanr_app/`)

### 4.1 Install Dependencies

```bash
cd spanr_app
flutter pub get
```

### 4.2 Environment Variables

Create `spanr_app/.env`:

```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
RAZORPAY_KEY_ID=<your-razorpay-key-id>
```

### 4.3 Google Maps Setup

#### Android
Add your API key to `spanr_app/android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="<your-google-maps-api-key>" />
```

#### iOS
Add to `spanr_app/ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("<your-google-maps-api-key>")
```

### 4.4 Run the App

```bash
flutter run                  # pick a connected device
flutter run -d <device-id>   # specific device
```

### 4.5 Build

```bash
flutter build apk            # Android APK
flutter build appbundle      # Android App Bundle (Play Store)
flutter build ios            # iOS (requires macOS + Xcode)
```

---

## 5. Flutter Mechanic Employee App (`spanr-mechanic-app/`)

### 5.1 Install Dependencies

```bash
cd spanr-mechanic-app
flutter pub get
```

### 5.2 Environment Variables

Create `spanr-mechanic-app/.env`:

```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```

### 5.3 Run the App

```bash
flutter run
```

### 5.4 Build

```bash
flutter build apk
flutter build appbundle
flutter build ios            # macOS + Xcode required
```

---

## 6. Razorpay Configuration

1. Create an account at [razorpay.com](https://razorpay.com)
2. For testing: use keys from **Test Mode** in the Razorpay dashboard
3. For production: swap to **Live Mode** keys
4. Set the webhook URL in Razorpay Dashboard → Webhooks:
   ```
   https://<your-project-ref>.supabase.co/functions/v1/razorpay-webhook
   ```
5. Copy the **Webhook Secret** and set it as a Supabase Edge Function secret:
   ```bash
   supabase secrets set RAZORPAY_WEBHOOK_SECRET=<your-webhook-secret>
   ```

---

## 7. Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
3. Create an API key and restrict it to your app's bundle ID / package name

---

## 8. Linting

```bash
# React dashboard
cd spanr-mechanic && npm run lint

# Flutter apps
cd spanr_app && flutter analyze
cd spanr-mechanic-app && flutter analyze
```

---

## 9. Local Edge Function Development

```bash
cd spanr-mechanic

# Serve a specific function locally
supabase functions serve razorpay-webhook --env-file .env.local

# Serve all functions
supabase functions serve
```

---

## Environment Files Summary

| File | App | Required Keys |
|---|---|---|
| `spanr-mechanic/.env` | React Dashboard | `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_APP_URL` |
| `spanr_app/.env` | Flutter User App | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `RAZORPAY_KEY_ID` |
| `spanr-mechanic-app/.env` | Flutter Mechanic App | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |

---

## Common Issues

**`flutter pub get` fails** — ensure Flutter SDK ≥ 3.9.2: `flutter upgrade`

**Supabase auth not working** — confirm your anon key matches the project URL; they are project-specific

**Google Maps blank on Android** — API key missing in `AndroidManifest.xml` or Maps SDK not enabled in Cloud Console

**Razorpay payment not completing** — check webhook URL is set and `RAZORPAY_WEBHOOK_SECRET` secret matches the Razorpay dashboard value

**`npm run dev` env vars undefined** — `.env` file must be in `spanr-mechanic/`, not the project root

**RLS blocking queries** — never call Supabase directly in UI; all queries go through `*service.ts` / `*_service.dart` files
