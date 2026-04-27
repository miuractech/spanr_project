# Order Management System

Comprehensive order management system for the SPANR mechanic dashboard with pagination, search, filtering, image uploads, and service detail tracking.

## Features

### 1. Orders List Page (`/orders`)
- **Pagination**: 10 orders per page with navigation
- **Search**: Search by customer name, email, or phone number (debounced for performance)
- **Filters**:
  - Status filter (created, accepted, in_progress, ready_for_delivery, completed, dispute, cancelled)
  - Date range filter for scheduled service dates
- **Statistics**: Quick view of order counts by status
- **Responsive**: Adapts to mobile, tablet, and desktop screens

### 2. Order Detail Page (`/orders/:orderId`)
- **Comprehensive Order Info**:
  - Customer details (name, email, phone)
  - Contact details from order
  - Vehicle information
  - Service and plan details
  - Service location with coordinates
  - Payment information
  - Special instructions

- **Status Management**:
  - Update order status
  - Add notes when changing status
  - Automatic history tracking

- **Tabbed Interface**:
  - **Images Tab**: View before/after service images, upload new after-service images
  - **Service Details Tab**: Add/edit service description, parts used, labor hours, additional charges
  - **History Tab**: Timeline of all status changes with notes

## Database Schema

### New Tables

#### `order_service_details`
```sql
CREATE TABLE order_service_details (
  id UUID PRIMARY KEY,
  order_id UUID UNIQUE REFERENCES orders(id),
  description TEXT NOT NULL,
  parts_used TEXT,
  labor_hours NUMERIC(5, 2),
  additional_charges NUMERIC(10, 2),
  notes TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

### Existing Tables (from migrations)
- `order_before_images`: Before-service images uploaded by customers
- `order_after_images`: After-service images uploaded by mechanics
- `order_history`: Automatic tracking of status changes

## Setup Instructions

### 1. Run SQL Migrations

Apply the required SQL migrations in order:

```bash
# Run in Supabase SQL Editor:
# 1. Service details table
cat spanr-mechanic/sql/orders.sql

# 2. Fix schema relationships (IMPORTANT!)
cat spanr-mechanic/sql/migrations/015_fix_orders_relationships.sql
```

Or apply directly via Supabase CLI:
```bash
cd spanr-mechanic
supabase db push
```

**Note:** Migration 015 fixes the relationship between orders and users tables, which is critical for the queries to work correctly.

### 2. Storage Configuration
Ensure the `orders` storage bucket exists with proper RLS policies (should already be configured from migration 012).

### 3. Install Dependencies (if needed)
```bash
cd spanr-mechanic
yarn install
```

## File Structure

```
spanr-mechanic/
  src/
    orders/
      orders.types.ts         # TypeScript types and interfaces
      orders.service.ts       # API service functions
      orders.hook.ts          # React hooks for orders

    components/
      order_card.tsx                      # Order card component
      order_status_updater.tsx            # Status update component
      order_images_manager.tsx            # Image upload/management component
      order_service_details_form.tsx      # Service details form
      order_history_timeline.tsx          # Order history timeline

    pages/
      orders.tsx              # Orders list page
      order_detail.tsx        # Order detail page

  sql/
    orders.sql              # SQL schema for order service details
```

## API Service Methods

### Orders Service (`ordersService`)

#### Queries
- `getOrdersByCompany(companyId, page, pageSize, filters)` - Get paginated orders with search/filters
- `getOrderById(orderId)` - Get single order with all details
- `getOrderStats(companyId)` - Get order count statistics by status
- `getOrderHistory(orderId)` - Get status change history
- `getOrderBeforeImages(orderId)` - Get before-service images
- `getOrderAfterImages(orderId)` - Get after-service images
- `getOrderServiceDetails(orderId)` - Get service details

#### Mutations
- `updateOrderStatus(orderId, status, notes?)` - Update order status with optional notes
- `uploadAfterImage(orderId, file)` - Upload after-service image to storage
- `deleteAfterImage(imageId)` - Delete after-service image
- `upsertOrderServiceDetails(orderId, details)` - Create/update service details

## Order Statuses

The system uses the following status workflow:

1. **created** - Order created by customer
2. **accepted** - Mechanic accepted the order
3. **in_progress** - Work in progress
4. **ready_for_delivery** - Work completed, ready for customer
5. **completed** - Order completed and delivered
6. **dispute** - Issue or dispute raised
7. **cancelled** - Order cancelled

## Usage Examples

### Searching Orders
```typescript
// Search is debounced (500ms) for performance
<TextInput
  placeholder="Search by customer name, email, or phone..."
  value={searchQuery}
  onChange={(e) => setSearchQuery(e.target.value)}
/>
```

### Filtering Orders
```typescript
const filters = {
  status: 'in_progress',
  startDate: new Date('2024-01-01'),
  endDate: new Date('2024-12-31'),
  search: 'john@example.com'
};

const { orders } = useOrders(companyId, page, pageSize, filters);
```

### Updating Order Status
```typescript
await ordersService.updateOrderStatus(
  orderId,
  'completed',
  'All work completed successfully. Customer satisfied.'
);
```

### Uploading After-Service Images
```typescript
const imageUrl = await ordersService.uploadAfterImage(orderId, file);
```

### Adding Service Details
```typescript
await ordersService.upsertOrderServiceDetails(orderId, {
  description: 'Full engine service completed',
  parts_used: 'Oil filter, Engine oil (5W-30), Air filter',
  labor_hours: 2.5,
  additional_charges: 500,
  notes: 'Recommended brake pad replacement in 3 months'
});
```

## Performance Optimizations

1. **Pagination**: Only 10 orders loaded per page
2. **Debounced Search**: 500ms debounce on search input
3. **Indexed Queries**: Database indexes on frequently queried columns
4. **Lazy Loading**: Order details and images loaded only when viewing specific order
5. **Efficient Filtering**: Server-side filtering reduces data transfer

## RLS (Row Level Security)

All tables have proper RLS policies:
- Company staff can only view/edit orders for their company
- Image uploads restricted to authenticated staff
- Service details can only be modified by company staff

## Future Enhancements

- Export orders to CSV/PDF
- Bulk status updates
- Advanced analytics and reporting
- Push notifications for status changes
- Customer feedback/rating integration
- Real-time order updates using Supabase Realtime

