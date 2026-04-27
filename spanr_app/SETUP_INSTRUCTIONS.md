# SPANR App Setup Instructions

## 1. Install Dependencies

```bash
cd spanr_app
flutter pub get
```

## 2. Configure Google Maps API Keys

### Get API Keys
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
4. Create credentials (API Keys) for both platforms

### Android Configuration
1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your Android API key

### iOS Configuration
1. Open `ios/Runner/AppDelegate.swift`
2. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your iOS API key

## 3. Setup Supabase

### Run Database Migrations

Execute these SQL files in your Supabase SQL Editor (in order):

1. `sql/addresses.sql` - Creates addresses table with RLS policies

### Environment Variables

Make sure your `.env` file exists with:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 4. Platform-Specific Setup

### Android
- Minimum SDK: 21
- Target SDK: 34
- Permissions are already configured in AndroidManifest.xml

### iOS
- Minimum iOS version: 12.0
- Usage descriptions are already configured in Info.plist
- Run `cd ios && pod install` if needed

## 5. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For iOS Simulator
open -a Simulator
flutter run
```

## 6. Test Permissions

On first launch, the app will:
1. Check authentication status
2. Request location permission
3. Request storage/photo permission
4. Navigate to home or login

## Features Implemented

### Loading Screen
- Authentication check
- Permission requests (location, storage)
- Status messages during initialization

### Address Management
- Add/Edit/Delete addresses
- Set default address
- Auto-select nearest address when location enabled
- Manual address entry with geocoding
- Interactive map for location selection
- Drag marker to adjust location

### Home Screen
- Location-aware address selector
- Disable services when location/address not set
- Warning banner for location disabled
- Auto-load nearest address on app start

### Location Behavior (like Uber/DoorDash)
- **Location ON**: Auto-selects nearest saved address
- **Location OFF**: Shows warning, forces manual address selection
- **No Addresses**: Prompts to add address
- Service cards disabled without location/address

## Troubleshooting

### Google Maps not showing
- Verify API keys are correct
- Check that Maps SDK is enabled in Google Cloud Console
- Ensure billing is enabled on your Google Cloud project

### Location permissions not working
- On iOS simulator, use Debug > Location > Custom Location
- On Android emulator, use extended controls to set location
- Test on real device for best results

### Supabase errors
- Verify .env file exists and has correct values
- Check RLS policies are created correctly
- Ensure user is authenticated before accessing addresses

## Next Steps

1. Add vehicle management screens
2. Implement mechanic search with location
3. Add booking flow
4. Integrate payment processing

