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

Critical RLS helper functions (SECURITY DEFINER), as of migration 056:
- `auth_staff_id()` — caller's staff row, matched by `staff.auth_user_id = auth.uid()`. Email fallback only for unlinked legacy rows with a confirmed email, never for `@spanr.staff` / `@spanr.owner` (anyone can register those addresses).
- `user_company_id()` — shop the caller can **manage**: only resolves for `staff.role IN ('owner','admin')`. Mechanics get NULL.
- `auth_staff_company_id()` — shop of any staff member (mechanics included). Use for read-only scoping only.
- `staff_assigned_to_order()`, `vehicle_on_assigned_order()`, `user_on_assigned_order()` — mechanic access to their own jobs.

`staff.role` is `owner | admin | mechanic`. The first staff row of a shop becomes `owner` (via `company_bootstrap_allowed()`); every other client-inserted row is forced to `mechanic`. Logins are linked to staff rows only by `provision-staff-auth` (service role).

**Column guards (056).** BEFORE triggers on `staff`, `staff_profiles`, `mechanic_companies`, `company_documents`, `orders`, `payments`, `extra_work_requests` pin sensitive columns for direct client writes (`current_user IN ('authenticated','anon')`). SECURITY DEFINER RPCs and the service role are not affected. Examples: clients cannot set `payments.status = 'paid'`, change `payments.amount` (the booking price is recomputed from the plan), self-verify a shop or document, or change `staff.role`.

**RLS gotcha:** for UPDATE, PostgreSQL ORs `WITH CHECK` across all permissive policies. A row can pass one policy's `USING` and another policy's `WITH CHECK`. Don't rely on per-policy `WITH CHECK` to restrict state transitions; use a trigger.

**Never disable RLS on any table.** Adding a table without RLS policies means any authenticated user can read/write all rows. Never add `USING (true)` / `WITH CHECK (true)` write policies.

## Webhook Security

`razorpay-webhook` verifies Razorpay HMAC-SHA256 signature:
```typescript
const expectedSignature = createHmac('sha256', webhookSecret)
  .update(rawBody)
  .digest('hex')
if (expectedSignature !== receivedSignature) return 403
```

This is the only authentication on the webhook endpoint — never remove this check.

The signature does not prove the customer paid what we billed. The webhook also checks that the captured amount (paise) equals `round(payments.amount * 100)` and the currency is INR. On a mismatch it marks the payment `failed` ("held for manual review") instead of `paid`.

`create-razorpay-order` takes only a `payment_id`. It verifies the caller owns the order, bills `payments.amount`, reuses an already-attached Razorpay order on retry, and attaches the Razorpay order id with the service role. Clients never send an amount.

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

Fixed in the 2026-10-05 audit (migration 056 + edge functions): cross-tenant staff self-insert, mechanic = owner rights, client-set payment status/amount, Razorpay amount not verified, self-verified KYC, world-readable KYC storage, `complete_job` / `assign_order_to_staff` / `admin_add_admin` authz gaps, leftover `WITH CHECK (true)` policies, unauthenticated `signup-owner` (retired), and staff password reset of any colleague.

Still open:
1. **Public buckets**: `orders`, `vehicle-images`, `inspection-images`, `staff-certificates` are public, so anyone with a URL can open a file (listing is now blocked). Moving them to private plus signed URLs needs app changes.
2. **No rate limiting / CAPTCHA**: phone OTP signup (SMS pumping) and edge functions. Enable Supabase Auth CAPTCHA.
3. **Super admin login is password-only**: add TOTP MFA and require `aal2` in `is_super_admin()`.
4. **`must_change_password`**: `complete_staff_password_change()` can be called without actually changing the password.
5. **Razorpay test key in source**: `rzp_test_SiX0rZlVuhU7lY` visible in Flutter app. Not a live key but should be moved to env vars.
6. **Idempotency in webhook**: correctly implemented via `payment_webhook_events.event_id UNIQUE`. Do not remove this.
