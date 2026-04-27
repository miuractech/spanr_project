# Services & Plans Update

## Overview
Services and Plans have been restructured with a tab-based UI where each service is a tab, and clicking a service tab shows all its plans.

## Key Changes

### 1. Database Schema
- Added `description` field to `services` table (optional)
- Added indexes for better query performance
- Clarified relationship: Service → Multiple Plans

### 2. UI/UX Changes
- **Tab-Based Interface**: Each service appears as a tab in the header
- **Service Tabs**: Click a service tab to view all its plans
- **Plan Count Badge**: Each tab shows number of plans (e.g., "Bike Repair (3)")
- **Inline Service Actions**: Edit/Delete service via dropdown menu on each tab
- **Sidebar**: Single "Services & Plans" link instead of two separate items
- **Auto-Selection**: First service is automatically selected when page loads
- **Context-Aware Plan Creation**: When adding a plan, the current service is pre-selected

### 3. Features Added
- **Notifications**: Toast notifications for all CRUD operations (success/error)
- **Loading States**: Proper loading indicators throughout
- **Service Descriptions**: Services can have detailed descriptions shown in a card
- **Empty States**: Helpful prompts when no services or plans exist
- **Confirmation Dialogs**: Shows plan count when deleting a service
- **Automatic Navigation**: After creating a service, automatically switches to its tab

### 4. File Structure

#### New Files
```
spanr-mechanic/src/
  ├── core/
  │   └── notification.hook.ts          # Notification system
  ├── pages/
  │   └── services_and_plans.tsx        # Combined services & plans page
  └── sql/migrations/
      └── 005_add_service_description.sql
```

#### Deleted Files
```
spanr-mechanic/src/pages/
  ├── services.tsx                       # ❌ Removed
  └── plans.tsx                          # ❌ Removed
```

#### Updated Files
```
spanr-mechanic/src/
  ├── App.tsx                            # Added Notifications, updated routes
  ├── components/
  │   ├── service_form.tsx               # Added description field
  │   ├── plan_form.tsx                  # Added defaultServiceId prop
  │   └── sidebar.tsx                    # Removed separate Plans link
  ├── services/
  │   └── services.service.ts            # Added description field support
  └── types/
      └── plan.types.ts                  # Added description to DbService
```

## UI Structure

```
┌─────────────────────────────────────────────────────────────┐
│  Services & Plans                        [+ Add Service]    │
├─────────────────────────────────────────────────────────────┤
│  [Bike Repair (3) ▼] [Car Maintenance (2)] [AC Service (1)] │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │ About this service                          [bike]   │   │
│  │ Complete bike repair and maintenance services       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  Plans (3)                                   [+ Add Plan]   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ Basic       │ │ Deluxe      │ │ Premium     │          │
│  │ $1499       │ │ $2499       │ │ $3499       │          │
│  │ [Edit/View] │ │ [Edit/View] │ │ [Edit/View] │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Relationship Model

```
Service: "Bike Repair"
├── Description: "Complete bike repair and maintenance services"
├── Category: bike
├── Icon: URL
└── Plans (3)
    ├── "Basic Service" - $1499
    │   ├── Duration: 60 mins
    │   ├── Features: [Oil Change, Brake Check, ...]
    │   └── FAQs, Steps, Outcomes...
    ├── "Deluxe Service" - $2499
    └── "Premium Service" - $3499
```

## Migration Steps

### 1. Apply Database Migration
```sql
-- In Supabase SQL Editor
\i sql/migrations/005_add_service_description.sql
```

### 2. Restart Development Server
```bash
cd spanr-mechanic
yarn dev
```

### 3. Test Functionality
- ✅ Create services with descriptions
- ✅ Click service tabs to view their plans
- ✅ Create plans (auto-selects current service)
- ✅ Edit/Delete services via tab dropdown
- ✅ Edit/Delete plans
- ✅ Verify notifications appear
- ✅ Check loading states
- ✅ Test empty states

## User Workflow

### Creating a Service
1. Go to "Services & Plans" in sidebar
2. Click "[+ Add Service]" button (top right)
3. Fill in:
   - Service Name (e.g., "Bike Repair")
   - Description (optional, e.g., "Complete bike repair services")
   - Category (car/bike)
   - Icon (optional)
4. Click "Create"
5. **Automatically switches to the new service's tab**

### Managing Services
1. Each service appears as a tab header
2. Click the dropdown (⋮) on any tab to:
   - Edit service details
   - Delete service (with confirmation)
3. Tab shows plan count badge (e.g., "Bike Repair (3)")

### Creating Plans for a Service
1. Click on a service tab (e.g., "Bike Repair")
2. See all plans for that service
3. Click "[+ Add Plan]" button
4. **Service is pre-selected** in the form
5. Fill in plan details:
   - Name, pricing, duration
   - Features, FAQs, steps, outcomes
6. Click "Create"

### Managing Plans
- View all plans under their respective service tabs
- Edit/Delete plans individually
- View full plan details
- Plans automatically grouped by service

## Benefits

1. **Intuitive Hierarchy**: Service tabs make the parent-child relationship obvious
2. **Faster Navigation**: One click to see all plans for a service
3. **Context-Aware**: Creating plans pre-selects the active service
4. **Less Clutter**: Single sidebar item with cleaner interface
5. **Visual Feedback**: Plan count badges on each tab
6. **Quick Actions**: Edit/delete services directly from tabs
7. **Better Organization**: Plans naturally grouped under services
8. **User Feedback**: Toast notifications for all actions
9. **Smart Defaults**: Auto-selects first service on page load
10. **Empty States**: Helpful prompts guide users to create content

## Technical Details

### Tab State Management
- Active service ID stored in component state
- First service auto-selected on mount
- Switching tabs updates active service
- Creating service switches to new service tab
- Deleting active service switches to first remaining service

### Plan Form Enhancement
- Added `defaultServiceId` prop
- Pre-selects service when opening from a service tab
- Service dropdown still allows changing service
- Resets to default service after form submission

### Notifications
- Success notifications (green) for create/update/delete
- Error notifications (red) for failures
- Warning notifications (yellow) for validation issues
- Auto-dismiss after 3-5 seconds

### Loading States
- LoadingOverlay for action operations
- Initial loading for data fetch
- Form loading during submissions
- Prevents duplicate submissions
