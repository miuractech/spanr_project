# SPANR — Claude Project Memory

> Single source of truth for all future Claude sessions. Read this first.
> Cross-reference detailed docs in this directory; do not re-analyze the entire repo unless significant changes occurred.

---

## Project Summary

SPANR is a **multi-tenant mechanic booking platform for the Indian market**. Three applications share one Supabase backend:

| App | Tech | Users |
|---|---|---|
| `spanr-mechanic` | React 19 + TypeScript (web dashboard) | Mechanic company owners/admins |
| `spanr_app` | Flutter (mobile) | End customers booking vehicle service |
| `spanr-mechanic-app` | Flutter (mobile) | Mechanic employees receiving and executing jobs |

Key India-specific details: pricing in ₹ (Indian Rupees), phone numbers normalized to `+91` format, Razorpay for payments, Indian license plate format.

---

## Architecture Summary

**Layered service architecture** with Supabase as the sole backend:

```
┌──────────────────────────────────────────────────────┐
│  spanr-mechanic (React)  │  spanr_app  │  mechanic-app│
│  Dashboard (Web)         │  (Flutter)  │  (Flutter)   │
└────────────┬─────────────┴──────┬──────┴──────┬───────┘
             │                   │             │
             └───────────────────▼─────────────┘
                          Supabase Platform
              ┌──────────────────────────────────────┐
              │  PostgreSQL (RLS)  │  Auth            │
              │  Edge Functions    │  Storage         │
              │  Realtime          │  (10 buckets)    │
              └──────────────────────────────────────┘
                          │
              ┌───────────▼────────────┐
              │  Razorpay (payments)   │
              │  Google Maps (geo)     │
              │  Firebase Hosting      │
              └────────────────────────┘
```

Multi-tenancy is enforced 100% via **PostgreSQL Row Level Security**. Two identity domains:
- **Staff** (dashboard + mechanic app): `staff.email = auth.jwt()->>'email'`
- **End users** (user app): `auth.uid() = users.id`

See [`architecture.md`](architecture.md) for full Mermaid diagrams.

---

## Folder Map

```
spanr_project/
├── .claude/                  ← This documentation directory
├── spanr-mechanic/           ← React web dashboard
│   ├── src/
│   │   ├── auth/             ← Auth context, service, util
│   │   ├── company/          ← Company context, service, types
│   │   ├── orders/           ← Orders service and types
│   │   ├── plans/            ← Plans service
│   │   ├── services/         ← Services service
│   │   ├── staff/            ← Staff management service
│   │   ├── assignments/      ← Order assignment service
│   │   ├── vehicle-history/  ← License-plate search service
│   │   ├── core/             ← Utilities (phone, password, theme)
│   │   ├── types/            ← Supabase types, domain types, DB mappers
│   │   └── pages/            ← Route-level page components
│   ├── supabase/
│   │   └── functions/        ← Deno Edge Functions
│   └── sql/
│       ├── migrations/       ← 001–039 numbered SQL migrations
│       ├── functions.sql     ← All DB stored functions (SECURITY DEFINER)
│       └── storage.sql       ← Storage buckets + policies
├── spanr_app/lib/            ← Flutter user app
│   ├── auth/                 ← Auth service, provider, screens
│   ├── booking/              ← Orders, checkout, payment screens + services
│   ├── mechanics/            ← Mechanic discovery, detail, plans
│   ├── cart/                 ← Cart provider + item model
│   ├── vehicles/             ← Vehicle CRUD
│   ├── addresses/            ← Address CRUD
│   ├── core/services/        ← Location, places services
│   └── screens/              ← Home, splash, location permission
├── spanr-mechanic-app/lib/   ← Flutter mechanic employee app
│   ├── auth/                 ← Staff auth, attendance, change-password
│   ├── jobs/                 ← Job list, detail, inspection, parts, notes
│   └── core/
│       ├── offline/          ← Hive-based sync queue + connectivity
│       ├── utils/            ← Phone, auth error utilities
│       └── theme/            ← App theme
├── .github/workflows/        ← GitHub Actions CI/CD
├── firebase.json             ← Firebase Hosting SPA config
└── supabase/                 ← Root-level supabase config (if any)
```

---

## Technology Stack

| Category | Technology |
|---|---|
| **Database/Backend** | Supabase (PostgreSQL 15, RLS, Auth, Storage, Realtime) |
| **Edge Functions** | Deno (TypeScript), deployed to Supabase |
| **Web Framework** | React 19, TypeScript 5.9 |
| **Web Build** | Vite (rolldown-vite 7.1.14) |
| **Web UI** | Mantine v8, Tailwind CSS v4, Tabler Icons |
| **Web Routing** | React Router v7 |
| **Mobile Framework** | Flutter / Dart (SDK ^3.9.2) |
| **Mobile State** | Provider pattern (`ChangeNotifier`) |
| **Mobile Routing** | GoRouter |
| **Payments** | Razorpay (Flutter SDK + webhook) |
| **Maps/Location** | google_maps_flutter, geolocator, geocoding |
| **Offline Storage** | Hive (mechanic app only) |
| **Animations** | Lottie (mechanic app) |
| **Hosting** | Firebase Hosting |
| **CI/CD** | GitHub Actions |

---

## Development Workflow

### React Dashboard (`spanr-mechanic/`)
```bash
cd spanr-mechanic
npm install
npm run dev          # dev server on port 3000
npm run build        # tsc + vite build
npm run lint         # ESLint
npm run deploy:firebase   # build + firebase deploy
```

### Flutter Apps
```bash
cd spanr_app          # or spanr-mechanic-app
flutter pub get
flutter run           # pick device
flutter build apk     # Android
flutter build ios     # iOS
```

### Supabase Edge Functions
```bash
cd spanr-mechanic
supabase functions serve <function-name>   # local dev
supabase functions deploy <function-name>  # deploy
```

### CI/CD
Pushes to branch `changes_5_5_26` trigger Firebase Hosting deploy automatically via GitHub Actions.

---

## Coding Conventions

- **No direct Supabase calls in components** — all queries go through `*service.ts` / `*_service.dart` files
- **DB naming**: snake_case (DB) ↔ camelCase (app) via `db.mappers.ts` in the React app
- **Error pattern**: services throw → providers/hooks catch and expose `error` string
- **Auth guard**: `useAuth()` + `useCompany()` hooks in React; `ChangeNotifier` providers in Flutter
- **Phone normalization**: always done in `phone.util.ts` (React) and `phone_util.dart` (Flutter)
- **Pagination**: offset-based cursor in Flutter (infinite scroll), page-number in React (10/page)
- **Search debounce**: 500ms across all apps
- **Image uploads**: max 1920×1080, 85% JPEG quality in Flutter

---

## Important Components

| Component | Location | Role |
|---|---|---|
| `App.tsx` | `spanr-mechanic/src/` | Root router + providers |
| `auth.service.ts` | `spanr-mechanic/src/auth/` | Supabase Auth wrapper |
| `auth.context.tsx` | `spanr-mechanic/src/auth/` | React Auth context |
| `company.context.tsx` | `spanr-mechanic/src/company/` | Company data context |
| `db.mappers.ts` | `spanr-mechanic/src/types/` | snake_case ↔ camelCase converters |
| `orders.service.ts` | `spanr-mechanic/src/orders/` | Order CRUD + status transitions |
| `assignments.service.ts` | `spanr-mechanic/src/assignments/` | Staff assignment (calls RPC) |
| `staff.service.ts` | `spanr-mechanic/src/staff/` | Staff CRUD + provisioning |
| `order_service.dart` | `spanr_app/lib/booking/` | User order creation + payment init |
| `order_provider.dart` | `spanr_app/lib/booking/` | Razorpay SDK integration + polling |
| `mechanics_service.dart` | `spanr_app/lib/mechanics/` | Geospatial mechanic discovery |
| `sync_service.dart` | `spanr-mechanic-app/lib/core/offline/` | Offline queue with Hive |
| `jobs_service.dart` | `spanr-mechanic-app/lib/jobs/` | Job status transitions + inspection |
| `signup-owner/index.ts` | `supabase/functions/` | Owner account creation |
| `provision-staff-auth/index.ts` | `supabase/functions/` | Mechanic credential provisioning |
| `razorpay-webhook/index.ts` | `supabase/functions/` | Payment webhook handler |

---

## Data Flow

### Booking Flow (User App)
```
HomeScreen → search mechanics → MechanicDetailScreen
→ add plan to CartProvider → SelectVehicleScreen
→ SelectVehiclePhotosScreen (4 before-photos)
→ CheckoutScreen → "Pay Now"
→ OrderService.initiateOrder():
    1. INSERT orders (status: created)
    2. INSERT order_before_images (upload photos)
    3. call create-razorpay-order Edge Function
    4. INSERT payments (status: unpaid)
→ OrderProvider.openRazorpay()
→ Razorpay SDK opens
→ On success: update payment → processing
→ Poll payments table (2s interval, 90s max)
→ razorpay-webhook Edge Function (HMAC verified)
    → update payment → paid/failed
→ Navigate to /order-confirmation or /payment-processing
```

### Job Execution Flow (Mechanic App)
```
jobs_list_screen ← Realtime subscription on order_assignments
→ job_detail_screen
→ "Start Job" → status: in_progress
→ before_inspection_screen (4 angles required)
→ parts_replacement_screen (add parts + photos)
→ service_notes_screen
→ after_inspection_screen
→ complete_job_screen (odometer + services performed)
→ complete_job() RPC:
    1. CREATE vehicle_service_history (denormalized)
    2. Link parts_replaced + inspection_images to history
    3. Mark assignment completed
    4. Set order → completed
    5. Set staff availability → available
```

---

## Common Commands

```bash
# React dashboard dev
cd spanr-mechanic && npm install && npm run dev

# React dashboard deploy
cd spanr-mechanic && npm run deploy:firebase

# Flutter user app
cd spanr_app && flutter pub get && flutter run

# Flutter mechanic app
cd spanr-mechanic-app && flutter pub get && flutter run

# Run all linting (React)
cd spanr-mechanic && npm run lint

# Build React for production
cd spanr-mechanic && npm run build
```

---

## Important Files

| File | Why Important |
|---|---|
| `spanr-mechanic/sql/migrations/` | Authoritative DB schema — 039 numbered files |
| `spanr-mechanic/sql/functions.sql` | All SECURITY DEFINER functions (RLS core) |
| `spanr-mechanic/sql/storage.sql` | Storage bucket definitions + RLS policies |
| `spanr-mechanic/src/types/supabase.config.ts` | Generated Supabase types |
| `spanr-mechanic/src/types/db.mappers.ts` | DB ↔ app type converters |
| `spanr-mechanic/supabase/functions/razorpay-webhook/index.ts` | Payment security — HMAC verification |
| `spanr-mechanic/supabase/functions/_shared/staff_auth.ts` | Shared phone normalization for staff |
| `.github/workflows/firebase-hosting-merge.yml` | CI/CD deploy trigger |
| `spanr_app/lib/booking/order_service.dart` | Critical booking flow |
| `spanr-mechanic-app/lib/core/offline/sync_service.dart` | Offline queue implementation |

---

## Things to Avoid

- **Never call Supabase directly in UI components** — always go through service layer
- **Never skip HMAC verification** in `razorpay-webhook` — it's the only auth mechanism
- **Never change RLS without testing** — all multi-tenancy depends on it
- **Never hardcode company_id** — always derive from `user_company_id()` RPC
- **Don't use `WITH CHECK (true)`** for new policies — already present as tech debt in early migrations
- **Don't add a second active assignment** — `uq_order_active_assignment` partial index enforces one; call `assign_order_to_staff()` RPC to reassign safely
- **Don't bypass `complete_job()` RPC** — it handles denormalization atomically

---

## Future Improvements

- Wire service category tiles on home screen to actual filter logic
- Multi-plan orders (cart currently only submits `items.first`)
- Push notifications (FCM/APNs) — currently relying on Realtime only
- KYC document review admin UI
- User-facing rating submission form
- Move CI/CD trigger from `changes_5_5_26` to `main`
- Swap Razorpay test key for production key before launch
- Add PostGIS for more efficient geo queries (currently bounding-box + Dart Haversine)

---

*See individual docs in this directory for deep-dives. Last updated: 2026-06-27.*
