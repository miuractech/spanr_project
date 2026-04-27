# SPANR Types

This directory contains all TypeScript type definitions for the SPANR platform, now fully adapted for Supabase with snake_case database conventions.

## Overview

The types are organized into logical modules:

- **auth.types.ts** - Authentication and user types
- **company.types.ts** - Mechanic company and address types
- **employee.types.ts** - Staff and employee types
- **order.types.ts** - Order, vehicle, and location types
- **plan.types.ts** - Service plans and related types
- **image.types.ts** - Image and media types
- **redux.types.ts** - Redux state types
- **db.mappers.ts** - Utilities to convert between DB and app types
- **supabase.config.ts** - Supabase client configuration with full typing
- **index.ts** - Central export file

## Naming Conventions

### Database Types (snake_case)

Database types are prefixed with `Db` and use snake_case for field names to match PostgreSQL conventions:

```typescript
interface DbMechanicCompany {
  id: string;
  company_name: string;
  address_line_1: string;
  created_at: string;
  updated_at: string;
}
```

### Application Types (camelCase)

Application types maintain the original camelCase convention for use in React components and business logic:

```typescript
interface MechanicCompanyProfile {
  id: string;
  company_name: string;  // Note: we kept snake_case to align with DB
  address: AddressType;
  created_at: string;
  updated_at: string;
}
```

## Using the Types

### Basic Imports

```typescript
// Import specific types
import { DbOrder, OrderType, OrderStatus } from '@spanr/types';

// Import all types
import * as Types from '@spanr/types';
```

### Database Operations

```typescript
import { supabase } from './lib/supabase';
import type { DbMechanicCompany } from '@spanr/types';

// Query with type safety
const { data, error } = await supabase
  .from('mechanic_companies')
  .select('*')
  .returns<DbMechanicCompany[]>();
```

### Converting Between DB and App Types

```typescript
import { dbCompanyToProfile, profileToDbCompany } from '@spanr/types';

// DB → App
const dbCompany: DbMechanicCompany = /* ... */;
const appCompany = dbCompanyToProfile(dbCompany, ratings, certs, specs, services);

// App → DB
const appCompany: MechanicCompanyProfile = /* ... */;
const dbCompany = profileToDbCompany(appCompany);
```

### Using Utility Functions

```typescript
import { objectKeysToCamel, objectKeysToSnake } from '@spanr/types';

// Convert API response from snake_case to camelCase
const dbData = { user_name: 'John', phone_number: '123' };
const appData = objectKeysToCamel(dbData);
// Result: { userName: 'John', phoneNumber: '123' }

// Convert form data from camelCase to snake_case for DB
const formData = { userName: 'John', phoneNumber: '123' };
const dbData = objectKeysToSnake(formData);
// Result: { user_name: 'John', phone_number: '123' }
```

## Type Reference

### Core Database Tables

| Type | Description | Table |
|------|-------------|-------|
| `DbUser` | Customer user account | `users` |
| `DbMechanicCompany` | Mechanic shop profile | `mechanic_companies` |
| `DbStaff` | Shop employee | `staff` |
| `DbService` | Service category | `services` |
| `DbPlan` | Service plan | `plans` |
| `DbVehicle` | Customer vehicle | `vehicles` |
| `DbOrder` | Service order | `orders` |
| `DbPayment` | Payment transaction | `payments` |

### Supporting Tables

| Type | Description | Table |
|------|-------------|-------|
| `DbCompanyRating` | Company ratings | `company_ratings` |
| `DbCompanyCertification` | Company certifications | `company_certifications` |
| `DbCompanySpecialization` | Company specializations | `company_specializations` |
| `DbStaffAccess` | Staff permissions | `staff_access` |
| `DbPlanFuelType` | Plan fuel compatibility | `plan_fuel_types` |
| `DbPlanFeature` | Plan features | `plan_features` |
| `DbPlanFaq` | Plan FAQs | `plan_faqs` |
| `DbPlanServiceOutcome` | Plan outcomes | `plan_service_outcomes` |
| `DbPlanAdditionalService` | Plan add-ons | `plan_additional_services` |
| `DbPlanStep` | Plan steps | `plan_steps` |
| `DbImage` | Generic images | `images` |

### Enums

```typescript
type OrderStatus = 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
type PaymentMethod = 'credit_card' | 'debit_card' | 'net_banking' | 'upi';
type PaymentStatus = 'paid' | 'unpaid';
type MasterVehicleType = 'car' | 'bike';
type FuelType = 'diesel' | 'petrol';
type LocationType = 'in_premise' | 'shed';
```

## Integration with Supabase

### Typed Client

```typescript
import { createSupabaseClient } from '@spanr/types';

const supabase = createSupabaseClient(
  process.env.VITE_SUPABASE_URL!,
  process.env.VITE_SUPABASE_ANON_KEY!
);

// All queries are now fully typed!
const { data } = await supabase.from('mechanic_companies').select('*');
//    ^? DbMechanicCompany[]
```

### Working with Views

The database includes helper views with aggregated data:

```typescript
// Use the company_profiles view for enriched company data
const { data } = await supabase
  .from('company_profiles')
  .select('*')
  .single();

// Use the order_details view for complete order information
const { data } = await supabase
  .from('order_details')
  .select('*')
  .eq('user_id', userId);
```

## Migration from Firebase

If you're migrating from Firebase:

1. **Field names**: Updated to snake_case
2. **Timestamps**: Changed from Firebase Timestamp to ISO 8601 strings
3. **IDs**: Changed from auto-generated to UUIDs
4. **Nested objects**: Some nested objects are now separate tables (e.g., ratings, certifications)

### Migration Helper

```typescript
// Convert Firebase document to Supabase format
function firebaseToSupabase(firebaseDoc: any): DbMechanicCompany {
  return {
    id: firebaseDoc.id,
    company_name: firebaseDoc.companyName,
    address_line_1: firebaseDoc.address.addressLine1,
    // ... map all fields
    created_at: firebaseDoc.createdAt.toISOString(),
    updated_at: firebaseDoc.updatedAt.toISOString(),
  };
}
```

## Best Practices

1. **Always use typed queries**: Leverage the Database types from `supabase.config.ts`
2. **Use mappers**: Convert between DB and app types using the provided mappers
3. **Validate enums**: Use type guards (`isOrderStatus`, `isPaymentMethod`) to validate string values
4. **Handle nulls**: Database fields can be `null`, handle them appropriately
5. **Timestamps**: All timestamps are ISO 8601 strings, use `new Date(timestamp)` to parse

## Examples

### Creating a Company

```typescript
import { supabase } from './lib/supabase';
import type { Database } from '@spanr/types';

type CompanyInsert = Database['public']['Tables']['mechanic_companies']['Insert'];

const newCompany: CompanyInsert = {
  company_name: 'Elite Auto Care',
  address_line_1: '123 Main St',
  city: 'Mumbai',
  state: 'Maharashtra',
  // ... other required fields
};

const { data, error } = await supabase
  .from('mechanic_companies')
  .insert(newCompany)
  .select()
  .single();
```

### Querying with Filters

```typescript
const { data: plans } = await supabase
  .from('plans')
  .select(`
    *,
    services!inner (
      name,
      category
    ),
    mechanic_companies!inner (
      company_name,
      city
    )
  `)
  .eq('vehicle_type', 'car')
  .eq('mechanic_companies.city', 'Mumbai')
  .gte('base_price', 1000)
  .lte('base_price', 5000);
```

### Creating an Order with Related Data

```typescript
import { supabase } from './lib/supabase';

async function createOrderWithPayment(orderData: any) {
  // Insert order
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .insert({
      company_id: orderData.companyId,
      user_id: orderData.userId,
      plan_id: orderData.planId,
      vehicle_id: orderData.vehicleId,
      scheduled_service_date: orderData.scheduledDate,
      status: 'pending',
      // ... other fields
    })
    .select()
    .single();

  if (orderError) throw orderError;

  // Insert payment
  const { data: payment, error: paymentError } = await supabase
    .from('payments')
    .insert({
      order_id: order.id,
      method: 'upi',
      status: 'unpaid',
      amount: orderData.amount,
    })
    .select()
    .single();

  if (paymentError) throw paymentError;

  return { order, payment };
}
```

## Testing

When writing tests, use the type definitions:

```typescript
import { describe, it, expect } from 'vitest';
import type { DbMechanicCompany } from '@spanr/types';

describe('Company CRUD', () => {
  it('should create a company', async () => {
    const company: Partial<DbMechanicCompany> = {
      company_name: 'Test Company',
      // ...
    };
    
    const { data, error } = await supabase
      .from('mechanic_companies')
      .insert(company)
      .select()
      .single();
    
    expect(error).toBeNull();
    expect(data).toBeDefined();
    expect(data?.company_name).toBe('Test Company');
  });
});
```

## Contributing

When adding new types:

1. Add database types (with `Db` prefix) in the appropriate file
2. Add application types if they differ significantly
3. Add mapper functions in `db.mappers.ts` if needed
4. Export from `index.ts`
5. Update this README
6. Update database migrations in `supabase/migrations/`
