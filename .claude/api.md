# API Documentation

SPANR uses Supabase PostgREST (auto-generated REST from PostgreSQL schema) plus custom Deno Edge Functions. There is no hand-written HTTP API server.

---

## Supabase Edge Functions

Base URL: `https://afwkdsbdwoytsdexwjkk.supabase.co/functions/v1/`

### POST `/signup-owner`

**Auth**: None (public)

**Purpose**: Create a new mechanic company owner account with email verification.

**Request body**:
```json
{
  "email": "string",
  "password": "string (8+ chars, upper+lower+number+special)",
  "name": "string"
}
```

**Response**:
- `200` — `{ message: "Verification email sent" }`
- `400` — validation errors (password too weak, missing fields)
- `409` — email already confirmed
- `500` — server error

**Logic**:
1. Validates password complexity
2. If email exists and unconfirmed → updates password + resends verification
3. Creates Auth user via Admin API (email NOT confirmed)
4. Sends verification email

---

### POST `/provision-staff-auth`

**Auth**: Bearer JWT (staff must be company member)

**Purpose**: Create or update a Supabase Auth user for a mechanic employee.

**Request body**:
```json
{ "staff_id": "uuid" }
```

**Response**:
- `200` — `{ tempPassword: "string" }`
- `400` — missing staff_id
- `403` — staff not in caller's company
- `500` — server error

**Logic**:
1. Looks up staff record
2. Normalizes phone → `<91XXXXXXXXXX>@spanr.staff` email
3. Creates Supabase Auth user if not exists, else updates password
4. Sets `must_change_password = true` in `staff_profiles`
5. Returns plaintext temp password (shown once in UI)

---

### POST `/reset-staff-password`

**Auth**: Bearer JWT

**Purpose**: Generate a new temp password for an existing mechanic.

**Request body**:
```json
{ "staff_id": "uuid" }
```

**Response**: `200` — `{ tempPassword: "string" }`

---

### POST `/razorpay-webhook`

**Auth**: Razorpay HMAC-SHA256 signature in `x-razorpay-signature` header

**Purpose**: Handle Razorpay payment events.

**Events handled**:
| Event | Action |
|---|---|
| `payment.captured` | Update payment to `paid`, set `paid_at` |
| `order.paid` | Update payment to `paid` |
| `payment.failed` | Update payment to `failed`, record `failure_reason` |

**Idempotency**: checks `payment_webhook_events.event_id` before processing.

**Response**: `200` — always (Razorpay retries on non-200)

---

### POST `/create-razorpay-order`

**Auth**: Bearer JWT

**Purpose**: Create a Razorpay order and return the order ID to the Flutter app.

**Request body**:
```json
{
  "amount": 150000,
  "currency": "INR",
  "receipt": "order_uuid"
}
```

**Response**: `200` — `{ id: "order_rzp_xxx", ... }` (Razorpay order object)

---

## PostgREST Endpoints (Auto-generated)

All accessed via Supabase JS/Flutter client. Not directly called by raw HTTP. Listed for reference.

Base URL: `https://afwkdsbdwoytsdexwjkk.supabase.co/rest/v1/`

RLS automatically scopes all responses. Auth header: `Authorization: Bearer <JWT>`.

### Key Table Endpoints

| Table | Methods | Notes |
|---|---|---|
| `mechanic_companies` | GET, PATCH | Scoped to user's company |
| `staff` | GET, POST, PATCH | Scoped to company |
| `staff_profiles` | GET, POST, PATCH | |
| `services` | GET, POST, PATCH, DELETE | Scoped to company |
| `plans` | GET, POST, PATCH, DELETE | Scoped to company |
| `orders` | GET, POST, PATCH | Company or user scoped |
| `order_assignments` | GET, POST, PATCH | Company scoped |
| `payments` | GET, POST, PATCH | Scoped |
| `vehicles` | GET, POST, PATCH, DELETE | User scoped |
| `inspection_images` | GET, POST | Company/assignment scoped |
| `parts_replaced` | GET, POST, PATCH, DELETE | Company/assignment scoped |

### Key RPC Endpoints

Called via `.rpc('function_name', params)`:

| RPC | Caller | Purpose |
|---|---|---|
| `user_company_id` | Dashboard | Get calling user's company UUID |
| `auth_staff_id` | Mechanic app | Get calling staff's UUID |
| `assign_order_to_staff` | Dashboard | Assign mechanic to order (atomic) |
| `complete_job` | Mechanic app | Complete job (atomic, creates history) |
| `complete_staff_password_change` | Mechanic app | Clear must_change_password |
| `get_plan_details` | User app | Full plan with all child data |
| `get_staff_company_id` | Internal | Lookup company by staff email |

---

## React Dashboard Routes

| Route | Component | Purpose |
|---|---|---|
| `/login` | LoginPage | Email/password sign-in |
| `/signup` | SignupPage | New owner registration |
| `/forgot-password` | ForgotPasswordPage | Request reset email |
| `/reset-password` | ResetPasswordPage | Set new password from link |
| `/auth/callback` | AuthCallbackPage | OAuth/email verification redirect |
| `/onboarding` | OnboardingPage | First-time company profile setup |
| `/dashboard` | DashboardPage | Overview stats |
| `/company-profile` | CompanyProfilePage | Edit company details |
| `/services` | ServicesAndPlansPage | Service + plan management |
| `/plans/:planId` | PlanDetailPage | Edit individual plan |
| `/orders` | OrdersPage | Paginated order list |
| `/orders/:orderId` | OrderDetailPage | Order tabs: details, job card, service, photos |
| `/staff` | StaffPage | Mechanic management |
| `/vehicle-history` | VehicleHistoryPage | License plate lookup |
| `/profile` | ProfilePage | Account info + logout |

All routes except auth routes are protected. `/onboarding` requires auth but not a company (for new owners).

---

## Flutter User App Routes (GoRouter)

| Path | Screen | Purpose |
|---|---|---|
| `/splash` | SplashScreen | Auth redirect |
| `/login` | LoginScreen | Sign in |
| `/signup` | SignupScreen | Register |
| `/home` | HomeShell | Tab shell |
| `/mechanic/:id` | MechanicDetailScreen | Browse plans, add to cart |
| `/select-vehicle` | SelectVehicleScreen | Pick vehicle for booking |
| `/select-vehicle-photos` | SelectVehiclePhotosScreen | 4-angle before photos |
| `/checkout` | CheckoutScreen | Review + pay |
| `/payment-processing` | PaymentProcessingScreen | Processing/failed state |
| `/order-confirmation` | OrderConfirmationScreen | Success |
| `/orders` | OrdersScreen | Order list |
| `/orders/:id` | OrderDetailsScreen | Detail + cancel |
| `/vehicles` | VehiclesScreen | Vehicle list |
| `/vehicles/add` | AddVehicleScreen | Add vehicle |
| `/addresses` | AddressesScreen | Address list |
| `/addresses/add` | AddAddressScreen | Add address |
| `/addresses/edit` | EditAddressScreen | Edit address |

---

## Flutter Mechanic App Routes (GoRouter)

| Path | Screen | Purpose |
|---|---|---|
| `/splash` | SplashScreen | Auth + mustChangePassword check |
| `/login` | LoginScreen | Phone + password |
| `/change-password` | ChangePasswordScreen | Forced first-login |
| `/jobs` | JobsListScreen | Active job list |
| `/jobs/:orderId` | JobDetailScreen | Job workflow |
| `/jobs/:orderId/before` | BeforeInspectionScreen | 4-angle before photos |
| `/jobs/:orderId/after` | AfterInspectionScreen | 4-angle after photos |
| `/jobs/:orderId/parts` | PartsReplacementScreen | Parts list + add |
| `/jobs/:orderId/parts/:partId` | PartDetailScreen | Part detail |
| `/jobs/:orderId/notes` | ServiceNotesScreen | Write service notes |
| `/jobs/:orderId/complete` | CompleteJobScreen | Odometer + final notes |
