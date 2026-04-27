# Google Maps Setup Instructions

To enable the Google Maps view in the add address form, you need to configure Google Maps API keys for both Android and iOS.

## Prerequisites

1. Create a Google Cloud Project at https://console.cloud.google.com/
2. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API (already used for address features)
3. Create API keys (can create separate keys for Android and iOS or use one key for both)

## Android Configuration

Add your Google Maps API key to the AndroidManifest.xml:

**File:** `android/app/src/main/AndroidManifest.xml`

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual Android API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_ANDROID_API_KEY" />
```

## iOS Configuration

Add your Google Maps API key to the AppDelegate.swift:

**File:** `ios/Runner/AppDelegate.swift`

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual iOS API key:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_IOS_API_KEY")
```

## Security Recommendations

### For Production:
1. **Android:** Restrict the API key by:
   - Application restrictions: Android apps
   - Add your app's package name and SHA-1 certificate fingerprint
   
2. **iOS:** Restrict the API key by:
   - Application restrictions: iOS apps
   - Add your app's bundle identifier

### Get SHA-1 for Android:
```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore /path/to/your/keystore -alias your-key-alias
```

## Testing

After adding the API keys:

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **iOS additional step:**
   ```bash
   cd ios
   pod install
   cd ..
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Features

The map view now supports:
- Display selected location with a marker
- Drag marker to adjust location
- Tap anywhere on map to set location
- Auto-center on location when coordinates are set
- Integration with "Use Current Location" button
- Integration with "Get Coordinates from Address" button

## Troubleshooting

### Map shows blank/gray:
- Verify API keys are correct
- Ensure Maps SDK is enabled in Google Cloud Console
- Check API key restrictions match your app's credentials
- For iOS: Ensure you ran `pod install` after updating AppDelegate.swift

### Location permissions:
The app already has location permissions configured in:
- **Android:** AndroidManifest.xml (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION)
- **iOS:** Info.plist (NSLocationWhenInUseUsageDescription)

## API Billing

Google Maps Platform has a free tier:
- $200 monthly credit (covers ~28,000 map loads)
- After free tier: $7 per 1,000 map loads

Set up billing alerts in Google Cloud Console to monitor usage.

