# Orders Schema Relationship Fix

## Issue
The error "Could not find a relationship between 'orders' and 'users' in the schema cache" occurred because:

1. Supabase's implicit relationship syntax (`users!inner(...)`) requires proper foreign key constraints
2. The schema cache wasn't recognizing the relationship between tables
3. The initial schema had some inconsistencies with the users table structure

## Solutions Applied

### 1. Updated Orders Service Queries
Changed from implicit relationship syntax to explicit queries:

**Before:**
```typescript
supabase.from('orders').select(`
  *,
  users!inner(name, email, phone),
  vehicles!inner(make, model, year, license_plate)
`)
```

**After:**
```typescript
// Fetch order first
const { data: order } = await supabase.from('orders').select('*')

// Fetch related data separately
const [userRes, vehicleRes] = await Promise.all([
  supabase.from('users').select('name, email, phone').eq('id', order.user_id),
  supabase.from('vehicles').select('make, model, year, license_plate').eq('id', order.vehicle_id)
])
```

This approach:
- ✅ Avoids relying on Supabase's schema cache
- ✅ Works regardless of foreign key constraint status
- ✅ Provides better error handling
- ✅ More explicit and easier to debug

### 2. Created Migration to Fix Schema Issues

Run this migration: `spanr-mechanic/sql/migrations/015_fix_orders_relationships.sql`

This migration:
- Ensures the `users` table exists with correct structure
- Removes incorrect index (`idx_users_user_id`)
- Adds correct indexes for search performance
- Verifies foreign key constraint exists
- Updates RLS policies to use `auth.uid()` correctly
- Adds search indexes on contact fields

### 3. Apply the Migration

```bash
# Option 1: Via Supabase Dashboard
# Go to SQL Editor and paste the contents of:
# spanr-mechanic/sql/migrations/015_fix_orders_relationships.sql

# Option 2: Via Supabase CLI
cd spanr-mechanic
supabase db push
```

## Files Modified

1. **spanr-mechanic/src/orders/orders.service.ts**
   - `getOrdersByCompany()` - Now uses explicit queries
   - `getOrderById()` - Now uses explicit queries

2. **spanr-mechanic/sql/migrations/015_fix_orders_relationships.sql**
   - New migration to fix schema issues

## Testing

After applying the migration, test the following:

1. **Orders List Page**
   ```
   Navigate to /orders in the mechanic dashboard
   Should display orders without errors
   ```

2. **Search Functionality**
   ```
   Search by customer email, phone, or name
   Should filter results correctly
   ```

3. **Order Details**
   ```
   Click on any order card
   Should display full order details with user, vehicle, and payment info
   ```

## Performance Considerations

The new approach fetches related data in parallel using `Promise.all()`, which:
- Minimizes total query time
- Provides better control over data fetching
- Allows for better error handling per entity

For large result sets (many orders), this is actually more efficient than a single complex join query.

## Alternative: Using Database Views

If you prefer to use joins, you can query the existing `order_details` view:

```typescript
const { data } = await supabase.from('order_details').select('*')
```

However, views have limitations with filtering and pagination, so the current explicit approach is recommended.

