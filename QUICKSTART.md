# SPANR Platform - Quick Start Guide

## What's Been Built

### ✅ Fully Functional React Mechanic Dashboard
A complete dashboard for mechanic companies with:
- Authentication & authorization
- Company profile management
- Services and plans management (with complex forms)
- Orders dashboard with filtering and status updates
- Staff management with permissions
- Professional UI with Mantine components

### ✅ Flutter User App Foundation
A working Flutter app with:
- Authentication (login/signup)
- Navigation structure
- Vehicle management (complete CRUD)
- Profile management
- Ready for additional features

### ✅ Complete Database Schema
- All tables created with proper relationships
- Row Level Security configured
- Storage buckets set up
- Helper functions and views

## Quick Start

### 1. Set Up Supabase (5 minutes)

1. Create account at https://supabase.com
2. Create new project
3. Go to SQL Editor
4. Run these scripts in order:
   - `spanr-mechanic/sql/migrations/001_initial_schema.sql`
   - `spanr-mechanic/sql/storage.sql`
   - `spanr-mechanic/sql/functions.sql`

### 2. Start React Dashboard (2 minutes)

```bash
cd spanr-mechanic
yarn install
cp .env.example .env
# Edit .env with your Supabase credentials
yarn dev
```

Access at: http://localhost:5173

#### Try It Out:
1. Click "Sign up" and create an account
2. Complete company onboarding
3. Add services (e.g., "Oil Change", "Brake Service")
4. Create plans with pricing and details
5. View the orders dashboard

### 3. Start Flutter App (3 minutes)

```bash
cd spanr_app
flutter pub get
```

Edit `lib/config/supabase_config.dart`:
```dart
static const String supabaseUrl = 'YOUR_URL';
static const String supabaseAnonKey = 'YOUR_KEY';
```

```bash
flutter run
```

#### Try It Out:
1. Sign up with a different email than dashboard
2. Navigate through bottom tabs
3. Add a vehicle
4. Explore the home screen

## File Structure Reference

### React Dashboard
```
spanr-mechanic/src/
├── auth/              # Authentication
├── company/           # Company management
├── services/          # Services CRUD
├── plans/             # Plans with complex forms
├── orders/            # Orders dashboard
├── staff/             # Staff management
├── components/        # Reusable components
├── layouts/           # Dashboard layout
└── pages/             # Page components
```

### Flutter App
```
spanr_app/lib/
├── auth/              # Authentication
├── vehicles/          # Vehicle management (COMPLETE)
├── mechanics/         # Browse mechanics (models only)
├── config/            # App configuration
├── core/              # Theme, utils, providers
└── screens/           # Main screens
```

## What's Next?

The platform is ready for:
1. Flutter: Mechanics browsing, Services/Plans viewing, Booking flow, Orders tracking
2. React: Analytics, Advanced reporting, Calendar views
3. Both: Real-time notifications, Payment integration, Reviews/ratings

## Key Features

### React Dashboard ✅
- Email/password authentication
- Multi-step company onboarding
- Service categories with icons
- Complex plan builder with:
  - Pricing, duration, vehicle types
  - Features, FAQs, outcomes
  - Image uploads
- Order management with filtering
- Staff permissions system

### Flutter App 🚧
- Authentication ✅
- Navigation ✅
- Vehicle CRUD ✅
- Profile ✅
- Mechanics browsing 📋
- Booking flow 📋
- Orders 📋

## Database Tables

All created and secured:
- `users`, `mechanic_companies`, `staff`
- `services`, `plans` (with 6 related tables)
- `vehicles`, `orders`, `payments`
- `images` (generic storage)

## Testing Credentials

Create your own accounts:
1. Dashboard: Sign up → Create company profile
2. App: Sign up → Add vehicles

Both use the same Supabase instance but different user types.

## Common Issues & Solutions

### React Dashboard
**Issue**: Blank screen after login
**Solution**: Check if Supabase URL/key are correct in `.env`

**Issue**: Can't create company
**Solution**: Ensure all migration scripts ran successfully

### Flutter App
**Issue**: White screen on startup
**Solution**: Check Supabase credentials in `supabase_config.dart`

**Issue**: Build errors
**Solution**: Run `flutter clean && flutter pub get`

## Architecture Highlights

### Security
- Row Level Security on all tables
- JWT-based authentication
- Company-scoped data access
- User-owned resources protection

### State Management
- React: Custom hooks with context
- Flutter: Provider pattern

### File Uploads
- Supabase Storage integration
- Public URLs for images
- Automatic cleanup

### Database
- Normalized schema
- Automatic timestamps
- Soft deletes where needed
- Foreign key constraints

## Development Tips

### React
- Uses Mantine UI - check their docs for components
- Services in `/service.ts` files
- Hooks in `/hook.ts` files
- Forms use controlled components

### Flutter
- Services in `/service.dart` files
- Providers in `/provider.dart` files
- Screens in `/screens/` directory
- Widgets in `/widgets/` directory

## Support

- **Database Issues**: Check Supabase logs in dashboard
- **React Issues**: Check browser console
- **Flutter Issues**: Check terminal output

## Next Development Session

To continue building:
1. **Flutter**: Implement mechanics listing screen
2. **Flutter**: Add services/plans browsing
3. **Flutter**: Create booking wizard
4. **Both**: Add real-time updates
5. **Both**: Integrate payments

---

**You've got a working platform!** 🎉

The mechanic dashboard is production-ready for basic operations.
The user app needs booking and orders features to be complete.
All infrastructure and patterns are in place for rapid development.

