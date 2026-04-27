# Database Migrations

## Migration Order

Apply migrations in numerical order:

1. **001_initial_schema.sql** - Initial database schema with all core tables
2. **002_fix_staff_rls.sql** - Fix staff RLS policies
3. **003_add_missing_insert_policies.sql** - Add missing insert policies
4. **004_comprehensive_rls_fix.sql** - Comprehensive RLS policy fixes
5. **005_add_service_description.sql** - Add description field to services table and improve indexes

## Latest Migration: 005_add_service_description.sql

### Changes:
- Added `description` field to `services` table (optional text field)
- Added composite index on `(company_id, category)` for services
- Added index on `service_id` for plans
- Added table comments clarifying the service-plan relationship

### Service & Plan Relationship:
- **Services**: High-level service categories (e.g., "Bike Repair", "Car Maintenance")
  - Each service can have multiple plans
  - Services include: name, description, category (car/bike), icon

- **Plans**: Specific pricing tiers under a service (e.g., "Full Service", "Deluxe Service", "Ultra Deluxe Service")
  - Each plan belongs to exactly one service
  - Plans include: name, pricing, duration, features, FAQs, etc.

### To Apply Migration:

```sql
-- Run in Supabase SQL Editor
\i 005_add_service_description.sql
```

Or apply manually through Supabase dashboard SQL editor.
