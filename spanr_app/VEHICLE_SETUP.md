# Vehicle Management Setup Instructions

## 1. Run Database Migration FIRST (IMPORTANT!)

Execute the SQL migration in your Supabase project:
```bash
spanr-mechanic/sql/migrations/add_vehicle_image_support.sql
```

Or via Supabase dashboard:
1. Go to SQL Editor
2. Copy and paste the contents of `add_vehicle_image_support.sql`
3. Execute

This adds:
- `vehicle` to the `entity_type` enum
- `vehicle-images` storage bucket
- Storage policies for vehicle images

## 2. Install Flutter Dependencies

```bash
cd spanr_app
flutter pub get
```

This will install the new `image_picker` package.

## 3. Configure Permissions

### iOS (ios/Runner/Info.plist)
Add these permissions:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to add vehicle images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take vehicle photos</string>
```

### Android (android/app/src/main/AndroidManifest.xml)
Add these permissions before `<application>`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
```

## 4. Verify Storage Bucket

In Supabase dashboard:
1. Go to Storage
2. Verify `vehicle-images` bucket exists
3. Check that policies are set correctly (public read, authenticated write)

## 5. Test the Implementation

1. Run the app: `flutter run`
2. Navigate to Vehicles tab
3. Add a new vehicle
4. Test adding images from gallery and camera
5. Test editing and deleting vehicles
6. Verify images persist and load correctly

## Troubleshooting

### Images not uploading
- Check Supabase storage bucket exists
- Verify RLS policies are correct
- Check network connectivity
- Look for errors in console

### Image picker not working
- Verify permissions are added to iOS/Android configs
- Rebuild the app after adding permissions
- Check device/simulator permissions settings

### Images not displaying
- Check image URLs in Supabase dashboard
- Verify public read policy on storage bucket
- Check network in device/simulator

## API Reference

### VehiclesProvider Methods
```dart
// Load all vehicles for user
await vehiclesProvider.loadVehicles(userId);

// Add new vehicle
final vehicle = await vehiclesProvider.addVehicle(vehicleModel);

// Update vehicle
await vehiclesProvider.updateVehicle(vehicleId, updates);

// Delete vehicle
await vehiclesProvider.deleteVehicle(vehicleId);

// Upload image
await vehiclesProvider.uploadImage(vehicleId, imageFile);

// Delete image
await vehiclesProvider.deleteImage(vehicleId, imageUrl);
```

