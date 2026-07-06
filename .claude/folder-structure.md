# Folder Structure

## Root

```
spanr_project/
├── .claude/                      ← Project documentation (this directory)
├── .github/workflows/            ← GitHub Actions CI/CD
│   ├── firebase-hosting-merge.yml
│   └── firebase-hosting-pull-request.yml
├── spanr-mechanic/               ← React web dashboard
├── spanr_app/                    ← Flutter customer app
├── spanr-mechanic-app/           ← Flutter mechanic employee app
├── supabase/                     ← Root-level supabase config
├── docs/                         ← Ad-hoc project docs
├── firebase.json                 ← Firebase Hosting SPA config
├── .firebaserc                   ← Firebase project aliases
└── README.md + various *.md     ← Scattered implementation notes
```

---

## `spanr-mechanic/` (React Dashboard)

```
spanr-mechanic/
├── src/
│   ├── App.tsx                   ← Root: routes, providers, theme
│   ├── main.tsx                  ← React entry point
│   ├── supabaseconfig.ts         ← Supabase client singleton
│   │
│   ├── auth/                     ← Authentication domain
│   │   ├── auth.service.ts       ← Supabase Auth calls
│   │   ├── auth.context.tsx      ← AuthContext + AuthProvider
│   │   └── auth.util.ts          ← Auth helper utilities
│   │
│   ├── company/                  ← Company domain (tenant context)
│   │   ├── company.service.ts    ← Company CRUD queries
│   │   ├── company.context.tsx   ← CompanyContext + CompanyProvider
│   │   └── company.constants.ts  ← Company-related constants
│   │
│   ├── orders/                   ← Order management
│   │   ├── orders.service.ts     ← Order queries + status transitions
│   │   └── orders.types.ts       ← Order TypeScript types
│   │
│   ├── plans/
│   │   └── plans.service.ts      ← Plan CRUD
│   │
│   ├── services/
│   │   └── services.service.ts   ← Service CRUD
│   │
│   ├── staff/
│   │   └── staff.service.ts      ← Staff CRUD + provisioning Edge Function calls
│   │
│   ├── assignments/
│   │   ├── assignments.service.ts ← assign_order_to_staff RPC
│   │   └── assignments.types.ts
│   │
│   ├── vehicle-history/
│   │   ├── vehicle_history.service.ts ← License plate lookup
│   │   └── vehicle_history.types.ts
│   │
│   ├── core/                     ← Shared utilities
│   │   ├── phone.util.ts         ← +91 normalization
│   │   ├── password.util.ts      ← Complexity validation
│   │   └── theme.ts              ← Mantine theme config
│   │
│   ├── types/                    ← Shared TypeScript types
│   │   ├── supabase.config.ts    ← Generated Supabase DB types
│   │   ├── company.types.ts      ← Company domain types
│   │   ├── order.types.ts        ← Order domain types
│   │   ├── plan.types.ts         ← Plan domain types
│   │   ├── employee.types.ts     ← Staff domain types
│   │   └── db.mappers.ts         ← snake_case ↔ camelCase converters
│   │
│   └── pages/                    ← Route-level components
│       ├── dashboard.tsx
│       ├── orders.tsx
│       ├── order_detail.tsx
│       ├── services_and_plans.tsx
│       ├── plan_detail.tsx
│       ├── staff.tsx
│       ├── company_profile.tsx
│       ├── vehicle_history.tsx
│       ├── onboarding.tsx
│       └── profile.tsx
│
├── supabase/
│   ├── config.toml               ← Supabase project config
│   └── functions/
│       ├── _shared/
│       │   └── staff_auth.ts     ← Shared: phone normalization, staff lookup
│       ├── signup-owner/index.ts
│       ├── provision-staff-auth/index.ts
│       ├── reset-staff-password/index.ts
│       └── razorpay-webhook/index.ts
│
├── sql/
│   ├── migrations/               ← 001–039 numbered SQL files
│   ├── functions.sql             ← All SECURITY DEFINER functions
│   ├── storage.sql               ← Bucket definitions + RLS policies
│   └── edge-functions/
│       └── create-razorpay-order.ts  ← Source for create-razorpay-order function
│
├── public/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── index.html
```

---

## `spanr_app/lib/` (Flutter Customer App)

```
lib/
├── main.dart                     ← App entry, providers, Supabase init
├── config/
│   ├── app_router.dart           ← GoRouter routes + guards
│   └── supabase_config.dart      ← Supabase URL/key constants
│
├── auth/
│   ├── auth_service.dart
│   ├── auth_provider.dart
│   ├── models/user_model.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── signup_screen.dart
│       └── splash_screen.dart
│
├── booking/
│   ├── order_service.dart        ← Create order, upload photos, create Razorpay order
│   ├── order_provider.dart       ← Razorpay SDK + payment polling
│   ├── order_model.dart
│   ├── order_types.dart          ← Order status enum
│   └── screens/
│       ├── checkout_screen.dart
│       ├── select_vehicle_screen.dart
│       ├── select_vehicle_photos_screen.dart
│       ├── payment_processing_screen.dart
│       ├── order_confirmation_screen.dart
│       ├── orders_screen.dart
│       └── order_details_screen.dart
│
├── mechanics/
│   ├── mechanics_service.dart    ← Geo-search query + Haversine filter
│   ├── mechanics_provider.dart
│   ├── services_plans_service.dart
│   ├── models/
│   │   ├── mechanic_company.dart
│   │   ├── plan_model.dart
│   │   └── service_model.dart
│   └── screens/
│       └── mechanic_detail_screen.dart
│
├── cart/
│   ├── cart_provider.dart
│   └── cart_item.dart
│
├── vehicles/
│   ├── vehicles_service.dart
│   ├── vehicles_provider.dart
│   └── screens/
│       ├── vehicles_screen.dart
│       └── add_vehicle_screen.dart
│
├── addresses/
│   ├── addresses_service.dart    ← Includes nearest-address Haversine
│   ├── addresses_provider.dart
│   ├── models/address.dart
│   └── screens/
│       ├── addresses_screen.dart
│       ├── add_address_screen.dart
│       └── edit_address_screen.dart
│
├── core/services/
│   ├── location_service.dart     ← GPS + permission handling
│   └── places_service.dart       ← Google Places API
│
└── screens/
    ├── home_screen.dart          ← Search, categories, mechanic list
    ├── location_permission_screen.dart
    └── main_tab_shell.dart       ← Bottom tab navigation
```

---

## `spanr-mechanic-app/lib/` (Flutter Mechanic App)

```
lib/
├── main.dart
├── config/
│   ├── app_router.dart
│   └── supabase_config.dart
│
├── auth/
│   ├── auth_service.dart         ← Phone login + password change
│   ├── auth_provider.dart
│   ├── attendance_service.dart   ← Daily check-in upsert
│   ├── models/staff_user.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── splash_screen.dart
│       └── change_password_screen.dart
│
├── jobs/
│   ├── jobs_service.dart         ← Job queries + status transitions + inspection upload
│   ├── jobs_provider.dart        ← Realtime subscription
│   ├── models/
│   │   ├── assigned_job.dart
│   │   ├── job_status.dart
│   │   ├── inspection_image.dart
│   │   └── part_replacement.dart
│   └── screens/
│       ├── jobs_list_screen.dart
│       ├── job_detail_screen.dart
│       ├── before_inspection_screen.dart
│       ├── after_inspection_screen.dart
│       ├── parts_replacement_screen.dart
│       ├── part_replacement_detail_screen.dart
│       ├── service_notes_screen.dart
│       └── complete_job_screen.dart
│
└── core/
    ├── offline/
    │   ├── sync_service.dart     ← Replay queued ops on reconnect
    │   ├── sync_queue_item.dart  ← Hive model for queued operations
    │   ├── hive_boxes.dart       ← Hive box names/keys
    │   └── connectivity_service.dart
    ├── utils/
    │   ├── phone_util.dart
    │   └── auth_error_util.dart
    └── theme/
        └── app_theme.dart
```
