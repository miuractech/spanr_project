# Troubleshooting

## Auth Issues

### "User not found in staff table" (Dashboard)
- Cause: Auth user exists but no `staff` record
- Fix: Manually insert staff record in Supabase, or ensure `signup-owner` Edge Function completed successfully

### Mechanic can't log in (Mechanic App)
- Cause 1: `provision-staff-auth` not called — staff has no Auth user
- Cause 2: Phone not normalized correctly
- Fix: Call `provision-staff-auth` from dashboard; check `staff.email` matches `<91PHONE>@spanr.staff`

### `must_change_password` loop
- Cause: `complete_staff_password_change()` RPC not called after password update
- Fix: Ensure `change_password_screen.dart` calls the RPC after `supabase.auth.updateUser()`

### `auth_user_id` is null in mechanic app
- Cause: Staff was created before `provision-staff-auth` was called
- Fix: The mechanic app auth service has fallback logic — looks up by email if `auth_user_id` is null and auto-updates it

---

## Database / RLS Issues

### "new row violates row-level security policy"
- Cause: Missing or incorrect RLS policy for INSERT
- Debug: Check `user_company_id()` returns correct value; check the table's RLS policies in Supabase dashboard
- Common: New table added without policies — add `USING (company_id = user_company_id())` policies

### "duplicate key value violates unique constraint uq_order_active_assignment"
- Cause: Trying to insert a second active assignment directly
- Fix: **Always** use `assign_order_to_staff()` RPC — never direct INSERT into `order_assignments`

### `vehicle_service_history` not created after `complete_job`
- Cause: `complete_job()` RPC failed partway through
- Debug: Check `order_assignments.status` — if still `active`, the RPC rolled back. Check for missing `staff_profiles` record for the mechanic.

---

## Payment Issues

### Payment stuck on "processing"
- Cause: Razorpay webhook not received or not processed
- Debug: Check `payment_webhook_events` table for the event; check Edge Function logs in Supabase
- Check: Webhook URL is correct and webhook secret matches `RAZORPAY_WEBHOOK_SECRET`

### "Razorpay order creation failed"
- Cause: `create-razorpay-order` Edge Function error
- Debug: Check Edge Function logs; verify `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET` secrets are set
- Note: Amount must be in paise (multiply ₹ by 100)

### Payment shows `failed` but money was deducted
- This is a Razorpay test/race condition. In production, Razorpay guarantees webhook delivery with retries. Contact Razorpay support if in production.

---

## Geolocation Issues

### No mechanics showing on home screen
- Cause 1: Location permission denied — check `LocationService`
- Cause 2: No mechanics within 7km radius
- Cause 3: Mechanic companies have `latitude/longitude = null` — ensure coordinates are set in company profile

### Distance showing incorrectly
- The bounding-box pre-filter uses `~0.063°` per 7km. Near the equator this is accurate. Near poles it underestimates. For India (8°N–37°N) this is acceptable.

---

## React Dashboard Issues

### "Cannot find company" after login
- Cause: Staff record exists in `auth.users` but not in `staff` table, or `company_id` is null
- Fix: Check `staff` table in Supabase

### Images not uploading
- Cause: Bucket name mismatch or RLS policy on storage
- Fix: Check bucket name in `storage.sql`; verify auth token is being sent

### `supabase.config.ts` type errors
- Cause: DB schema changed but types not regenerated
- Fix: `supabase gen types typescript --project-id afwkdsbdwoytsdexwjkk > src/types/supabase.config.ts`

---

## CI/CD Issues

### Firebase deploy fails with "permission denied"
- Check: `FIREBASE_SERVICE_ACCOUNT_FIR_9_DOJO_44CEC` secret is set correctly in GitHub
- Check: Service account has Firebase Hosting Admin role

### Build fails with missing env vars
- Check: `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` secrets are set in GitHub Actions

---

## Flutter Issues

### `vehicle.is_primary` column error (User App)
- Known issue: Column may be missing in some environments
- The `VehiclesService` wraps this query in try/catch and falls back automatically

### Hive not initializing (Mechanic App)
- Cause: `Hive.initFlutter()` not called before first `Hive.openBox()`
- Fix: `main.dart` must call `await Hive.initFlutter()` before runApp
