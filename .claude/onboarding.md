# Onboarding

## Getting Started in 15 Minutes

### 1. Understand the project (5 min)
Read [`project-overview.md`](project-overview.md) — know what SPANR does and who the users are.

### 2. Understand the architecture (5 min)
Read [`CLAUDE.md`](CLAUDE.md) — covers architecture summary, folder map, tech stack, and key components.

### 3. Set up your environment (5 min)

**React Dashboard**:
```bash
cd spanr-mechanic
npm install
# Create .env.local with VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY (ask team)
npm run dev
# Open http://localhost:3000
```

**Flutter Apps**:
```bash
flutter doctor  # verify Flutter setup
cd spanr_app && flutter pub get && flutter run
cd spanr-mechanic-app && flutter pub get && flutter run
```

---

## Key Things to Know

### Multi-Tenancy
Everything is scoped to a company via RLS. The function `user_company_id()` in PostgreSQL is the keystone. When you query any company-scoped table, RLS automatically filters to the caller's company. You don't add WHERE clauses for tenancy in app code — the database handles it.

### Three Separate Auth Domains
1. **Dashboard owners**: Real email + Supabase Auth
2. **Mechanic employees**: Phone → encoded as `<91phone>@spanr.staff` email + Supabase Auth
3. **Customers**: Real email + Supabase Auth (separate from company auth)

### Service Layer Pattern
**Never call Supabase directly from UI components.** Always:
- React: service file → `useXxx` hook → component
- Flutter: service class → Provider (`ChangeNotifier`) → Widget

### The `complete_job()` RPC
Job completion is atomic. Never try to replicate this logic in app code. Call the RPC.

### The `assign_order_to_staff()` RPC
Never insert directly into `order_assignments`. Always call this RPC.

---

## Where to Find Things

| Need to... | Look at... |
|---|---|
| Understand DB schema | [`database.md`](database.md) or `sql/migrations/` |
| Find an API endpoint | [`api.md`](api.md) |
| Understand a business rule | [`business-rules.md`](business-rules.md) |
| Find coding patterns | [`coding-standards.md`](coding-standards.md) |
| Set up deployment | [`deployment.md`](deployment.md) |
| Debug an issue | [`troubleshooting.md`](troubleshooting.md) |
| Understand a term | [`glossary.md`](glossary.md) |
| Understand why a decision was made | [`decisions.md`](decisions.md) |

---

## First Contribution Checklist

- [ ] Run the React dashboard locally
- [ ] Log in with an owner account (create via `/signup`)
- [ ] Complete the onboarding flow (create a company)
- [ ] Create a service and plan
- [ ] Create a staff member and see the credential modal
- [ ] Understand `user_company_id()` — run it in Supabase SQL editor
- [ ] Read `sql/functions.sql` — especially `complete_job` and `assign_order_to_staff`
- [ ] Read `src/types/db.mappers.ts` — understand the snake_case ↔ camelCase pattern

---

## Team Contacts

Contact the project lead for:
- Supabase project credentials
- Firebase service account
- Razorpay test/production keys
- GitHub repository access
