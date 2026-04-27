# Razorpay iOS Setup Guide

## Configuration Steps

### 1. Environment Variables

Add your Razorpay Key ID to `.env` file:

```env
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxx
```

### 2. iOS Configuration (Already Done)

The following configurations have been added to support Razorpay payments on iOS:

#### Info.plist
- Added `CFBundleURLTypes` with `io.razorpay` URL scheme
- Added `LSApplicationQueriesSchemes` for UPI apps (PhonePe, GPay, Paytm, BHIM, UPI)

#### AppDelegate.swift
- Added URL handling methods for payment callbacks

### 3. Build and Test

After updating your `.env` file with the actual Razorpay key:

```bash
# Clean and rebuild iOS app
cd spanr_app
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run -d ios
```

### 4. Testing Payment Flow

1. Launch the app on iOS simulator or device
2. Navigate to checkout screen
3. Complete payment form
4. Razorpay payment sheet should open
5. Complete test payment
6. App should receive payment callback

## Troubleshooting

### Payment sheet doesn't open
- Verify `RAZORPAY_KEY_ID` is set in `.env`
- Check console logs for errors
- Ensure app has necessary permissions

### Payment completes but callback not received
- Verify URL schemes in Info.plist
- Check AppDelegate URL handling methods
- Review Razorpay dashboard logs

### UPI apps not appearing
- Ensure `LSApplicationQueriesSchemes` is configured in Info.plist
- UPI apps must be installed on device (not available in simulator)

## Production Setup

Before releasing to App Store:

1. Replace test key with live Razorpay key:
   ```env
   RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxx
   ```

2. Test payment flow thoroughly with real payment methods

3. Configure webhook URL in Razorpay dashboard for payment verification

## References

- [Razorpay Flutter SDK](https://github.com/razorpay/razorpay-flutter)
- [Razorpay iOS Integration Guide](https://razorpay.com/docs/payments/payment-gateway/ios-integration/)

