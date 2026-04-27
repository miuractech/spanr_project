# Booking Flow Implementation

## Overview
Complete implementation of the booking flow from mechanic selection to checkout with cart functionality and vehicle before pictures.

## Flow
1. **Home Screen** → Click mechanic card → **Mechanic Detail Page**
2. **Mechanic Detail Page** → Browse services & plans → Add to cart
3. Cart with multiple plans → Click "Next" → **Select Vehicle & Photos Page**
4. **Select Vehicle & Photos** → Choose vehicle & take before pictures → **Checkout Page**
5. **Checkout Page** → Review & confirm → Place order

## Files Created

### Models
- `lib/mechanics/models/service_model.dart` - Service model with description
- `lib/mechanics/models/plan_model.dart` - Plan model with pricing, features, duration

### Cart System
- `lib/cart/cart_item.dart` - Cart item model
- `lib/cart/cart_provider.dart` - Cart state management (add/remove/update quantity)

### Services
- `lib/mechanics/services_plans_service.dart` - Fetch services and plans by company

### Screens
- `lib/mechanics/screens/mechanic_detail_screen.dart` - Display services grouped by sections with plans
- `lib/booking/select_vehicle_screen.dart` - Select vehicle and capture before pictures
- `lib/booking/checkout_screen.dart` - Final checkout with price breakdown

### Widgets
- `lib/mechanics/widgets/plan_card.dart` - Plan card with add to cart functionality

### SQL
- `spanr_app/sql/booking.sql` - Order before/after images tables with RLS policies

## Files Modified

### Router
- `lib/config/app_router.dart`
  - Added `/mechanic/:id` route
  - Added `/select-vehicle` route
  - Added `/checkout` route
  - Added `/vehicles/add` route

### Providers
- `lib/core/providers/app_providers.dart`
  - Added `CartProvider` to app providers

### Home Screen
- `lib/screens/home_screen.dart`
  - Added navigation to mechanic detail on card click

## Features Implemented

### 1. Cart System
- Add multiple plans from same company (no duplicates)
- Remove plans from cart
- Auto-clear cart when switching companies
- Real-time price calculation (subtotal, tax, total)
- Cart badge in app bar
- Cart bottom sheet for quick review
- No quantity - each plan can only be added once

### 2. Mechanic Detail Page
- Company header with logo, rating, address
- Services grouped as sections
- Plans displayed under each service
- Add to cart button per plan
- Plan features, warranty, guarantee display
- Badge support (e.g., "Popular")
- Sticky checkout bar with total

### 3. Vehicle Selection
- List all user vehicles
- Radio button selection
- "Add New Vehicle" card always visible
- Navigate to add vehicle form and return
- Before service photo capture (camera + gallery)
- Multiple image support
- Image preview with delete option
- Validation (must select vehicle and take photos)

### 4. Checkout Page
- Company info display
- Vehicle info display
- Cart items summary
- Before photos preview
- Price breakdown:
  - Subtotal
  - Tax
  - Total
- Place order button
- Loading state during order placement

## Data Flow

```
HomeScreen
  ↓ (click mechanic card)
MechanicDetailScreen
  - Load services by company_id
  - Load plans by service_id
  - Add plans to CartProvider
  ↓ (cart has items, click Next)
SelectVehicleScreen
  - Load user vehicles
  - Select vehicle
  - Capture before photos
  ↓ (has vehicle + photos, click Proceed)
CheckoutScreen
  - Display all info
  - Calculate final price
  - Place order (TODO: implement backend)
  ↓
OrdersPage (future)
```

## Database Schema

### Services Table
```sql
services (
  id, company_id, name, description, 
  category, icon_url, created_at, updated_at
)
```

### Plans Table
```sql
plans (
  id, service_id, company_id, name,
  vehicle_type, location_type, duration,
  base_price, tax, warranty, guarantee, badge,
  created_at, updated_at
)
```

### Plan Features
```sql
plan_features (id, plan_id, feature, display_order)
plan_fuel_types (id, plan_id, fuel_type)
```

### Order Images
```sql
order_before_images (id, order_id, image_url)
order_after_images (id, order_id, image_url, uploaded_by)
```

## TODO: Backend Implementation

The checkout screen currently has a placeholder for order placement. Implement:

1. **Upload Before Images**
   ```dart
   // Upload to Supabase Storage
   final urls = await uploadBeforeImages(beforeImages, orderId);
   ```

2. **Create Order**
   ```dart
   final order = await supabase.from('orders').insert({
     'company_id': company.id,
     'user_id': userId,
     'plan_id': plans (handle multiple plans),
     'vehicle_id': vehicle.id,
     'scheduled_service_date': selectedDate,
     'service_latitude': lat,
     'service_longitude': lng,
     'service_address': address,
     // ... other fields
   });
   ```

3. **Save Before Images**
   ```dart
   await supabase.from('order_before_images').insert(
     urls.map((url) => {'order_id': orderId, 'image_url': url})
   );
   ```

4. **Create Payment Record**
   ```dart
   await supabase.from('payments').insert({
     'order_id': orderId,
     'amount': total,
     'status': 'unpaid',
     // ... payment details
   });
   ```

5. **Handle Multiple Plans**
   - Either create multiple orders (one per plan)
   - Or create order_items table linking order to multiple plans

## UI/UX Features

### Cart
- Visual feedback when adding/removing from cart
- Snackbar confirmation
- Cart badge with item count
- Prevent mixing plans from different companies
- Prevent duplicate plans (each plan can only be added once)
- Toggle button: "Add to Cart" / "Remove from Cart"

### Plan Cards
- Visual hierarchy (plan name, price, features)
- Badge display for special plans
- Tax display
- Duration in human-readable format
- Warranty/Guarantee chips
- Toggle between "Add to Cart" (outlined) and "Remove from Cart" (red filled)
- No quantity controls - simple add/remove

### Before Photos
- Camera and gallery options
- Grid layout for multiple images
- Delete button overlay
- Image count display
- Validation before proceeding

### Checkout
- Clean price breakdown
- All info in one place
- Clear CTA button
- Loading state

## Testing Checklist

- [ ] Navigate from home to mechanic detail
- [ ] Add single plan to cart
- [ ] Add multiple plans to cart
- [ ] Try to add same plan twice (should not add duplicate)
- [ ] Remove plan from cart
- [ ] Switch between companies (cart clears)
- [ ] Select existing vehicle
- [ ] Click "Add New Vehicle" and add vehicle
- [ ] Return to vehicle selection after adding vehicle
- [ ] Take/select before photos
- [ ] Remove before photo
- [ ] View checkout summary
- [ ] Verify no quantity shown in cart items
- [ ] Place order (when implemented)

## Dependencies Used
- `provider` - State management
- `go_router` - Navigation
- `image_picker` - Photo capture
- `supabase_flutter` - Backend

## Notes
- Cart is company-specific (clears when selecting different company)
- Before pictures are required (minimum 1)
- Vehicle selection is required
- After pictures will be taken by mechanic company staff after service completion
- All prices include tax calculation
- Plan features are limited to 3 in card view (expandable in future)

