# Business Rules

## Order Lifecycle

```
created → accepted → assigned → in_progress → [waiting_for_parts →] ready_for_delivery → completed
                                                                                        → cancelled
                                                                                        → dispute
```

- **created**: Customer places order (payment may be pending)
- **accepted**: Company admin acknowledges the order via dashboard
- **assigned**: Admin assigns a mechanic via `assign_order_to_staff()` RPC
- **in_progress**: Mechanic taps "Start Job" in mechanic app
- **waiting_for_parts**: Mechanic taps "Waiting for Parts"; can resume → `in_progress`
- **ready_for_delivery**: Set by dashboard (vehicle ready for pickup)
- **completed**: `complete_job()` RPC atomically finalizes everything
- **cancelled**: Customer or company cancels; no reversal
- **dispute**: Side state; no automated transitions

## One Active Assignment Per Order

The partial unique index `uq_order_active_assignment ON order_assignments(order_id) WHERE status = 'active'` enforces that only one mechanic can be active on an order at a time.

To reassign, always call `assign_order_to_staff()` RPC — it atomically:
1. Sets old active assignment to `reassigned`
2. Creates new active assignment
3. Sets order status to `assigned`

**Never** directly INSERT into `order_assignments` from app code.

## Payment Flow

- Order is created before payment is confirmed (status: `created`, payment: `unpaid`)
- Razorpay order is created in the Edge Function → amount in paise
- App polls `payments` table every 2 seconds for up to 90 seconds
- Webhook (HMAC-verified) is the authoritative payment confirmation
- If polling times out before webhook: UI shows failed state; webhook may still arrive later

## Phone Number Normalization

- All staff phones normalized to `+91XXXXXXXXXX` format before storage
- Mechanic app email = `<91XXXXXXXXXX>@spanr.staff` (no `+` prefix in email)
- `phone.util.ts` and `phone_util.dart` handle all normalization
- Duplicate: mechanic with same phone at same company is blocked by unique index

## Staff Authentication

- Company owners: real email + password
- Mechanic employees: phone number (shown in login) + temp password
  - Temp password set by `provision-staff-auth` Edge Function
  - On first login, `staff_profiles.must_change_password = true` → forced redirect to `/change-password`
  - `complete_staff_password_change()` RPC clears the flag
- Attendance: auto-logged on login (upsert on `staff_attendance` with `check_in_date = today`)

## Vehicle Access Control

- Customers can only access their own vehicles
- Company staff can access vehicles that appear on their company's orders (via `vehicle_on_company_order()`)
- Mechanics can access vehicles on their active assignments (via `vehicle_on_assigned_order()`)
- No staff member can browse the full vehicle table

## Inspection Photos

- Before inspection: 4 angles required (front, back, left, right) before a job can proceed past before-inspection step
- After inspection: same 4 angles required to complete the job
- Photos uploaded to `inspection-images` storage bucket, records in `inspection_images` table
- After job completion, `complete_job()` links all inspection images to the `vehicle_service_history` record

## Job Completion (Atomic via RPC)

`complete_job(order_id, staff_id, odometer, service_notes, services_performed)`:
1. Verifies calling staff is the active assignee (unless admin)
2. Creates `vehicle_service_history` with denormalized snapshot
3. Updates `parts_replaced.service_history_id` for all parts on this order
4. Updates `inspection_images.service_history_id` for all images on this order
5. Sets `order_assignments.status = 'completed'`
6. Sets `orders.status = 'completed'`
7. Sets `staff_profiles.availability = 'available'`

All in one transaction — never call these individually.

## Plan and Pricing

- Plans belong to a service, which belongs to a company
- Each plan has `base_price` + `tax` fields (separate)
- Plan can restrict by `vehicle_type` (car or bike)
- Plans have `location_type` (in-shop, doorstep, etc.)
- Plan child tables: fuel types, features, FAQs, service outcomes, additional services, steps

## Geospatial Search

- Search radius: 7km
- Step 1: SQL bounding-box pre-filter (~0.063° delta for 7km)
- Step 2: Dart Haversine post-filter for accurate distance
- Results sorted by distance ascending
- No PostGIS — pure coordinate arithmetic

## Multi-Cart Limitation

- `CartProvider` supports multiple plan items (from same company only)
- `CheckoutScreen` only submits `cartProvider.items.first` — effectively single-plan orders
- Known bug/limitation — see `business-rules.md`

## KYC Documents

- Three document types: GST certificate, PAN card, utility bill
- Unique per company per type
- Stored in private `company-documents` bucket (signed URLs, 1hr expiry)
- Status: `pending | verified | rejected` — no admin review UI exists yet

## Service Categories (Home Screen)

Six tiles displayed: General Service, AC Repair, Denting, Painting, Battery, Tyre. These are currently **UI-only** and do not filter mechanics or plans. Filtering mechanics by service category is not implemented.

## Ratings

- `company_ratings` table exists with aggregated `rating` (0–5), `professionalism`, `timeliness`, `quality`
- INSERT/UPDATE RLS policies exist for customers
- No user-facing rating submission UI is implemented
