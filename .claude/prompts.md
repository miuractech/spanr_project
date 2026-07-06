# Useful Claude Prompts

Common prompts for working with this codebase. Copy-paste as starting points.

---

## Investigation

```
Read .claude/CLAUDE.md first, then help me understand how [feature/component] works.
Trace the full data flow from [entry point] to [destination].
```

```
I'm seeing this error: [error]. Check the troubleshooting guide and relevant service files to diagnose.
```

```
What tables and RLS policies are involved when a [customer/owner/mechanic] does [action]?
```

---

## Feature Development

```
I need to add [feature]. Read .claude/CLAUDE.md and the relevant service files first.
Follow the existing patterns (service layer, no direct Supabase calls in components, db.mappers for type conversion).
Show me the minimal change needed.
```

```
Add a new dashboard page for [purpose].
- Read src/App.tsx for the route pattern
- Read an existing page like src/pages/orders.tsx for the structure
- Create the service, types, and page component following existing conventions
```

```
Add a new API endpoint (Edge Function) for [purpose].
- Read supabase/functions/provision-staff-auth/index.ts as the pattern
- Include CORS headers, auth check, error handling
- Never put service role key in client code
```

```
Add a new database table for [purpose].
- Create migration file sql/migrations/040_description.sql
- Include: UUID PK, created_at, updated_at + trigger
- Include RLS policies scoped to user_company_id()
- Never use WITH CHECK (true)
```

---

## Debugging

```
The payment flow is broken. Read:
- spanr_app/lib/booking/order_service.dart
- spanr_app/lib/booking/order_provider.dart  
- supabase/functions/razorpay-webhook/index.ts
Then diagnose the issue.
```

```
A mechanic can't complete a job. Read sql/functions.sql (complete_job function) and 
spanr-mechanic-app/lib/jobs/jobs_service.dart. Trace the full completion flow.
```

```
RLS is blocking [operation]. Read sql/functions.sql and the relevant migration file 
to understand the current policies. Suggest the minimal policy fix.
```

---

## Code Review

```
Review this change for security issues, especially:
- Any direct Supabase calls in UI components
- Any RLS bypasses
- Any hardcoded company IDs
- Any Razorpay amounts not in paise
- Any phone numbers not going through normalization
```

```
Does this new table need RLS? What policies should it have?
Check sql/functions.sql for user_company_id() and auth_staff_id() for the pattern.
```

---

## Schema Changes

```
Regenerate Supabase TypeScript types after schema change:
supabase gen types typescript --project-id afwkdsbdwoytsdexwjkk > spanr-mechanic/src/types/supabase.config.ts
```

```
I changed the DB schema. Update:
1. src/types/supabase.config.ts (regenerate)
2. Relevant domain types file in src/types/
3. db.mappers.ts if column names changed
4. The service file that queries this table
5. .claude/database.md
```
