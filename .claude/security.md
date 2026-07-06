# Security

## Authentication

| App | Mechanism | Notes |
|---|---|---|
| Dashboard | Supabase Auth (email/password) | Email verification required |
| User app | Supabase Auth (email/password + Google OAuth) | `spanr://login-callback` deep link for OAuth |
| Mechanic app | Supabase Auth (phone-derived email + temp password) | Forced password change on first login |

JWT tokens issued by Supabase; all API calls include `Authorization: Bearer <JWT>`.

## Authorization: Row Level Security

**All multi-tenancy is enforced via PostgreSQL RLS.** No application-level tenancy checks exist.

Critical RLS helper functions (SECURITY DEFINER):
- `user_company_id()` — returns company UUID for the JWT's email — prevents RLS recursion
- `auth_staff_id()` — returns staff UUID for the JWT
- `vehicle_on_company_order()` — boolean for vehicle access policy
- `vehicle_on_assigned_order()` — boolean for mechanic vehicle access

**Never disable RLS on any table.** Adding a table without RLS policies means any authenticated user can read/write all rows.

## Webhook Security

`razorpay-webhook` verifies Razorpay HMAC-SHA256 signature:
```typescript
const expectedSignature = createHmac('sha256', webhookSecret)
  .update(rawBody)
  .digest('hex')
if (expectedSignature !== receivedSignature) return 403
```

This is the only authentication on the webhook endpoint — never remove this check.

## Sensitive Data

| Data | Storage | Access |
|---|---|---|
| KYC documents (GST, PAN, utility bill) | `company-documents` bucket (private) | Signed URLs with 1-hour expiry |
| Staff temp passwords | Returned once by Edge Function, never stored | Never persisted |
| Razorpay keys | Supabase secrets (env vars in Edge Functions) | Never in client code |
| Supabase service role key | Edge Function env only | Never in client/frontend |

## Secrets

**Never commit to git:**
- `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` / `RAZORPAY_WEBHOOK_SECRET`
- `SUPABASE_SERVICE_ROLE_KEY`
- Firebase service account JSON

**Currently in CI/CD (GitHub Secrets):**
- `FIREBASE_SERVICE_ACCOUNT_FIR_9_DOJO_44CEC`
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

The Supabase anon key is safe to expose in client code — RLS enforces authorization. The service role key bypasses RLS and must never leave the server.

## Known Razorpay Issue

The Flutter app uses test-mode key `rzp_test_SiX0rZlVuhU7lY`. Before production launch, this must be replaced with a live key and the webhook secret updated accordingly.

## Input Validation

- Password complexity: validated in `signup-owner` Edge Function (8+ chars, upper, lower, number, special)
- Phone normalization: centralized in `phone.util.ts` / `phone_util.dart` — prevents invalid formats reaching DB
- License plates: `is_indian_licensed` flag on vehicle; no format enforcement
- Images: client-side max dimensions (1920×1080, 85% quality) but no server-side validation

## Potential Vulnerabilities / Recommendations

1. **No server-side image validation**: uploads to Storage are not validated for file type or size beyond bucket settings. Recommend adding file type checks.
2. **`complete_job` admin bypass**: if `p_staff_id != v_caller_staff_id`, the assignment check is skipped. Document this intent clearly; add an admin permission check if unintended.
3. **Early RLS policies use `WITH CHECK (true)`**: migrations 003 and 004 for `company_certifications`, `company_specializations`, `company_ratings`. Should be tightened to scope by company.
4. **No rate limiting on Edge Functions**: signup-owner and provision-staff-auth have no rate limiting. Recommend Supabase's rate limiting or a proxy.
5. **Razorpay test key in source**: `rzp_test_SiX0rZlVuhU7lY` visible in Flutter app. Not a live key but should be moved to env vars.
6. **Idempotency in webhook**: correctly implemented via `payment_webhook_events.event_id UNIQUE`. Do not remove this.
