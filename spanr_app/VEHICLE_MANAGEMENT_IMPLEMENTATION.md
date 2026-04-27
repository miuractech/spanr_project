# Vehicle Management with Image Support

## Overview
Implemented full CRUD operations for vehicles in the Flutter app with image upload/delete support.

## Features

### 1. Vehicle CRUD Operations
- **Create**: Add new vehicles with make, model, year, and license plate
- **Read**: View all user's vehicles with images
- **Update**: Edit vehicle details and manage images
- **Delete**: Remove vehicles (cascades to delete all associated images)

### 2. Image Management
- **Upload Images**: 
  - From gallery (using image_picker)
  - From camera (direct photo capture)
  - Automatic upload to Supabase storage bucket `vehicle-images`
  - Multiple images per vehicle supported
  
- **View Images**:
  - Display first image as vehicle thumbnail in list
  - Show all images in edit mode
  - Image count indicator
  
- **Delete Images**:
  - Individual image deletion with confirmation
  - Automatic cleanup from storage and database

## Implementation Details

### Database Schema Updates
**Migration**: `add_vehicle_image_support.sql`
- Added `vehicle` to `entity_type` enum
- Created `vehicle-images` storage bucket
- Set up RLS policies for image access

### Flutter Components

#### Models
- `VehicleModel`: Extended with `images` field and `copyWith` method

#### Services
- `VehiclesService`:
  - `getVehiclesByUser()`: Fetches vehicles with images using joins
  - `createVehicle()`: Creates new vehicle
  - `updateVehicle()`: Updates vehicle details
  - `deleteVehicle()`: Deletes vehicle and all images
  - `uploadImage()`: Uploads image to storage and creates DB record
  - `deleteImage()`: Removes image from storage and DB

#### Providers
- `VehiclesProvider`:
  - State management for vehicles list
  - Image upload/delete operations
  - Local state updates on image changes

#### UI Components
- `VehiclesScreen`: List of all vehicles with pull-to-refresh
- `AddVehicleScreen`: Form for create/edit with image management
  - Image picker (gallery/camera)
  - Image preview (existing and new)
  - Image deletion
- `VehicleCard`: Card widget showing vehicle with first image

### Dependencies Added
```yaml
image_picker: ^1.1.2  # For selecting images from gallery or camera
```

## Usage

### Add a Vehicle
1. Navigate to Vehicles tab
2. Tap the "+" button
3. Fill in vehicle details
4. Optionally add images via Gallery or Camera buttons
5. Tap "Add Vehicle"

### Edit a Vehicle
1. Tap the menu button (⋮) on any vehicle card
2. Select "Edit"
3. Modify details or manage images
4. Tap "Update Vehicle"

### Delete a Vehicle
1. Tap the menu button (⋮) on any vehicle card
2. Select "Delete"
3. Confirm deletion

### Manage Images
- In edit mode:
  - Add images: Tap "Gallery" or "Camera" buttons
  - Delete existing images: Tap delete icon on image thumbnail
  - Remove new images: Tap close icon before saving

## File Structure
```
spanr_app/
  lib/
    vehicles/
      models/
        vehicle_model.dart        # Vehicle data model with images
      screens/
        vehicles_screen.dart      # Vehicle list screen
        add_vehicle_screen.dart   # Add/Edit vehicle screen
      widgets/
        vehicle_card.dart         # Vehicle list item widget
      vehicles_provider.dart      # State management
      vehicles_service.dart       # API/Database service
  sql/
    vehicles.sql                  # SQL queries with image support

spanr-mechanic/
  sql/
    migrations/
      add_vehicle_image_support.sql  # Database migration
```

## Storage Bucket Configuration
- **Bucket Name**: `vehicle-images`
- **Access**: Public read, authenticated write
- **File Naming**: `{vehicle_id}_{uuid}.jpg`

## Security
- RLS policies ensure users can only manage their own vehicles
- Images are scoped to authenticated users
- Image deletion requires authentication

## Next Steps (Optional Enhancements)
- Add image compression before upload
- Support for multiple image selection at once
- Image carousel for viewing all vehicle images
- Image ordering/reordering
- Vehicle type selection (car/bike)
- Fuel type selection

