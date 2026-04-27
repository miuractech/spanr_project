# Users Table Structure Fix

## Problem
The `users` table had both an `id` field (UUID primary key) and a `user_id` field (TEXT for auth.uid()). This caused issues:
- Vehicles table referenced `users.id` instead of the auth user ID
- Required unnecessary lookups to match auth.uid() to database user records
- Caused error: "Cannot coerce the result to a single JSON object" when fetching vehicles

## Solution
Simplified the `users` table to use `id` as the primary key that directly matches `auth.uid()`:

### Database Changes

1. **Updated users table structure** (`migrations/users.sql`):
   - Removed separate `user_id` TEXT field
   - Made `id` UUID the primary key (matches auth.uid() from Supabase Auth)
   - No auto-generation of UUID (must be provided as auth.uid())

2. **Migration script** (`migrations/006_fix_users_table_structure.sql`):
   - Drops old `user_id` column
   - Updates all RLS policies to use `id` directly
   - Updates vehicle, order, and payment policies

### Flutter App Changes

1. **UserModel** (`lib/auth/models/user_model.dart`):
   - Removed `userId` field
   - `id` field is now the auth user ID

2. **AuthService** (`lib/auth/auth_service.dart`):
   - Changed `'user_id'` to `'id'` in insert operations
   - Updated queries to use `.eq('id', ...)` instead of `.eq('user_id', ...)`

3. **VehiclesService** (`lib/vehicles/vehicles_service.dart`):
   - Removed user lookup logic
   - Directly uses auth user ID for vehicle queries

4. **Updated all references**:
   - `booking/select_vehicle_screen.dart`
   - `screens/home_screen.dart`
   - `addresses/screens/addresses_list_screen.dart`
   - `addresses/screens/address_form_screen.dart`
   - Changed `user.userId` to `user.id`

5. **SQL Helper Queries** (`sql/vehicles.sql`):
   - Simplified queries to use `'auth-uid'::uuid` directly
   - Removed unnecessary user table lookups

## Migration Steps

Run the migration in this order:

```sql
-- 1. Apply the fix migration
\i migrations/006_fix_users_table_structure.sql

-- 2. If you have existing data, you need to migrate it first
-- This migration assumes empty table or you've backed up data
```

## Benefits

- Simpler data model
- Better performance (no extra lookups)
- Direct mapping between Supabase Auth and database users
- Clearer code with less confusion between `id` and `user_id`


