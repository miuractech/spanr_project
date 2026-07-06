# Architectural Decisions

## ADR-001: Single Supabase Project for All Apps

**Decision**: One Supabase project (`afwkdsbdwoytsdexwjkk`) serves all three apps (dashboard, user app, mechanic app).

**Rationale**: Simplifies development, eliminates cross-service data sync, and Supabase RLS can handle multi-tenancy natively. All three apps need access to the same `orders`, `staff`, and `companies` data.

**Trade-off**: Single point of failure; scaling would require Supabase plan upgrades, not horizontal microservice scaling.

---

## ADR-002: Row Level Security for Multi-Tenancy

**Decision**: All tenant isolation is enforced via PostgreSQL RLS, not application code.

**Rationale**: Application-level tenancy checks are error-prone and easily bypassed. RLS is enforced at the database layer regardless of which client or code path accesses the data.

**Consequence**: SECURITY DEFINER helper functions (`user_company_id()`, `auth_staff_id()`) are critical infrastructure. Changes to them affect every policy.

---

## ADR-003: Deno Edge Functions for External Integrations

**Decision**: Razorpay and Supabase Auth Admin API calls are in Deno Edge Functions, not in client code.

**Rationale**: 
- Razorpay webhook signature verification requires the webhook secret (server-only)
- Supabase service role key (used to create Auth users) must never be in client code
- HMAC verification must happen server-side

---

## ADR-004: Denormalized `vehicle_service_history`

**Decision**: When a job completes, a snapshot of all relevant data (vehicle, customer, mechanic, company names, odometer, services) is stored in `vehicle_service_history` as denormalized text fields.

**Rationale**: Service history must be immutable — even if a company later changes its name or a mechanic is deleted, the historical record must remain accurate. Denormalization achieves this without complex audit tables.

**Trade-off**: Duplication; updates to names/details after job completion are not reflected in history (intentional).

---

## ADR-005: `complete_job()` as a Stored RPC

**Decision**: Job completion is an atomic database RPC, not a sequence of client-side API calls.

**Rationale**: Job completion involves 6+ operations (history, parts, images, assignment, order status, staff availability) that must all succeed or all fail. An atomic database transaction is the only safe approach — any client-side orchestration would leave inconsistent state on partial failure.

---

## ADR-006: No PostGIS for Geospatial

**Decision**: Mechanic search uses bounding-box SQL + Dart/JavaScript Haversine, not PostGIS.

**Rationale**: Supabase's PostgreSQL has PostGIS available but enabling and indexing it adds complexity. The current approach (bounding-box pre-filter → Haversine post-filter) is adequate for the volume and accuracy needs of a 7km city-level search.

**Trade-off**: Slightly inefficient for dense result sets. Upgrade path: add PostGIS with `ST_DWithin` if query performance becomes an issue.

---

## ADR-007: Hive for Offline Queue (Mechanic App)

**Decision**: Mechanic app uses Hive to persist operation queues when offline.

**Rationale**: Mechanics often work in garages with poor connectivity. Operations (status updates, photo uploads, part additions) must survive connectivity loss without data loss.

**Trade-off**: Hive is a simple key-value store — complex conflict resolution is not supported. Current approach: simple replay in order. No conflict detection.

---

## ADR-008: Phone-Derived Email for Mechanic Auth

**Decision**: Mechanic employees authenticate with `<91PHONE>@spanr.staff` email format, not real emails.

**Rationale**: Mechanics in India often don't have work emails. Phone number is the universal identifier. Supabase Auth requires email format, so phone is encoded as an email.

**Consequence**: Phone normalization must be consistent everywhere. The `_shared/staff_auth.ts` and `phone_util.dart` must use identical normalization logic.

---

## ADR-009: CI/CD Deploys from Feature Branch

**Decision**: GitHub Actions deploys on push to `changes_5_5_26`, not `main`.

**Rationale**: Active development branch named after date (May 5, 2026). The branch serves as the integration branch during this development phase.

**Recommended change**: Once stable, move trigger to `main` and use proper git flow.

---

## ADR-010: Partial Unique Index for Active Assignment

**Decision**: A partial unique index (`WHERE status = 'active'`) on `order_assignments(order_id)` enforces the one-active-assignment business rule at the database level.

**Rationale**: Application-level checks can fail under concurrent writes. The database constraint is the authoritative enforcement point.

**Consequence**: Any attempt to insert a second active assignment will fail with a unique constraint violation. Use `assign_order_to_staff()` RPC which handles the reassignment atomically.
