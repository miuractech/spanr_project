# Testing

## Current State

**No test files exist in the repository.** There is no established testing infrastructure for any of the three applications.

---

## Recommendations

### React Dashboard

Add Vitest (already compatible with Vite):

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom jsdom
```

Priority test targets:
- `db.mappers.ts` — pure functions, easy to unit test
- `phone.util.ts` — phone normalization edge cases
- `password.util.ts` — password validation rules
- Service functions — mock Supabase client

### Flutter Apps

Flutter has built-in test framework:

```bash
flutter test
```

Priority test targets:
- `phone_util.dart` — phone normalization
- `MechanicsService.getNearbyMechanics()` — Haversine + bounding box filter
- `SyncService` (mechanic app) — offline queue replay logic
- `OrderService.initiateOrder()` — complex booking flow

### Edge Functions

Deno testing:
```bash
deno test supabase/functions/
```

Priority: `razorpay-webhook` HMAC verification logic

---

## Testing the Payment Flow (Manual)

1. Use Razorpay test mode key (`rzp_test_SiX0rZlVuhU7lY`)
2. Test card: `4111 1111 1111 1111`, any future expiry, any CVV
3. Webhook can be tested with Razorpay dashboard test events or `ngrok` + local Edge Function

---

## Testing Geospatial Search (Manual)

The 7km radius search uses bounding-box SQL + Dart Haversine. Test by:
1. Adding mechanic companies at known coordinates
2. Searching from a user location
3. Verifying companies within 7km appear, others don't

---

## CI Test Step

Currently no test step in `.github/workflows/`. To add:

```yaml
- name: Test
  run: cd spanr-mechanic && npm test
```
