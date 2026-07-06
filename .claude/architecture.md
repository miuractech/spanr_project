# Architecture

## Style

Layered service architecture. No microservices — single Supabase project serves all three apps. Business logic splits between:
- **PostgreSQL functions** (SECURITY DEFINER) — critical atomic operations, RLS helpers
- **Deno Edge Functions** — external integrations (Razorpay, Auth Admin API)
- **Service layer** (TS/Dart) — query composition, data mapping

---

## High-Level Diagram

```mermaid
graph TB
    subgraph Clients
        WEB["spanr-mechanic\nReact 19 Dashboard"]
        APP["spanr_app\nFlutter (Customer)"]
        MAPP["spanr-mechanic-app\nFlutter (Mechanic)"]
    end

    subgraph Supabase
        AUTH["Auth\n(JWT, OAuth)"]
        DB["PostgreSQL\n(RLS)"]
        EDGE["Edge Functions\n(Deno)"]
        STORE["Storage\n(10 buckets)"]
        RT["Realtime"]
    end

    subgraph External
        RZP["Razorpay\nPayments"]
        GMAPS["Google Maps\nGeolocator"]
        FIREBASE["Firebase\nHosting"]
    end

    WEB -->|PostgREST + RPC| DB
    WEB -->|JWT| AUTH
    WEB -->|file upload| STORE
    APP -->|PostgREST + RPC| DB
    APP -->|JWT| AUTH
    APP -->|file upload| STORE
    APP -->|SDK| RZP
    APP -->|SDK| GMAPS
    MAPP -->|PostgREST + RPC| DB
    MAPP -->|JWT| AUTH
    MAPP -->|file upload| STORE
    MAPP -->|subscribe| RT
    RT -->|order_assignments changes| MAPP
    DB -->|trigger| RT
    EDGE -->|called by clients| DB
    EDGE -->|Razorpay API| RZP
    RZP -->|webhook| EDGE
    FIREBASE -->|serves| WEB
```

---

## Multi-Tenancy Model

```mermaid
graph LR
    COMPANY["mechanic_companies\n(tenant)"]
    STAFF["staff\n(members)"]
    ORDERS["orders\n(scoped)"]
    SERVICES["services\n(scoped)"]
    PLANS["plans\n(scoped)"]

    COMPANY --> STAFF
    COMPANY --> ORDERS
    COMPANY --> SERVICES
    COMPANY --> PLANS

    RLS["RLS: user_company_id()\nreturns company for JWT email"]
    RLS -.enforces.-> ORDERS
    RLS -.enforces.-> SERVICES
    RLS -.enforces.-> PLANS
    RLS -.enforces.-> STAFF
```

All queries are automatically scoped to the company of the authenticated user via RLS. The `user_company_id()` SECURITY DEFINER function is used in nearly every staff-facing policy.

---

## Request Flow — React Dashboard

```
Browser
  ↓
React Router (client-side)
  ↓
Page Component (e.g., orders.tsx)
  ↓
Custom Hook (e.g., useOrders)
  ↓
Service (e.g., orders.service.ts)
  ↓
Supabase JS Client (PostgREST or RPC)
  ↓
PostgreSQL (RLS applied, user_company_id() scopes result)
```

---

## Request Flow — Flutter Apps

```
Screen Widget
  ↓
ChangeNotifier Provider (e.g., OrderProvider)
  ↓
Service (e.g., order_service.dart)
  ↓
Supabase Flutter Client (PostgREST or RPC)
  ↓
PostgreSQL (RLS applied)
```

---

## Edge Function Invocation Patterns

| Caller | Function | Auth |
|---|---|---|
| User Flutter app | `create-razorpay-order` | Bearer JWT |
| Razorpay servers | `razorpay-webhook` | HMAC-SHA256 signature |
| Dashboard (React) | `signup-owner` | No auth (public signup) |
| Dashboard (React) | `provision-staff-auth` | Bearer JWT |
| Dashboard (React) | `reset-staff-password` | Bearer JWT |

---

## Offline Architecture (Mechanic App Only)

```mermaid
graph TD
    ACTION["Mechanic taps action\n(update status, upload photo, etc.)"]
    CHECK["ConnectivityService\nonline?"]
    EXEC["Execute Supabase call\ndirectly"]
    QUEUE["Enqueue in Hive\nSyncQueueItem"]
    SYNC["SyncService\nreplay on reconnect"]

    ACTION --> CHECK
    CHECK -->|yes| EXEC
    CHECK -->|no| QUEUE
    QUEUE --> SYNC
    SYNC -->|connectivity restored| EXEC
```

Operation types queued: `update_status`, `upload_inspection`, `add_part`, `save_notes`, `complete_job`.
