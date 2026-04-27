# SPANR - Mechanic Booking Platform

A comprehensive mechanic booking platform where multiple companies and mechanics can enroll and users can book them for service, repairs, etc.

## Project Structure

- **spanr-mechanic/** - React dashboard for mechanic companies
- **spanr_app/** - Flutter mobile app for users

## Tech Stack

### Backend
- **Supabase** - Backend as a Service
  - PostgreSQL database
  - Row Level Security (RLS)
  - Storage for images
  - Real-time subscriptions

### Mechanic Dashboard (React)
- **React 19** with TypeScript
- **Mantine UI** - Component library
- **React Router** - Navigation
- **Supabase Client** - Backend integration
- **Vite** - Build tool

### User App (Flutter)
- **Flutter** - Cross-platform mobile framework
- **Supabase Flutter** - Backend integration
- **Provider** - State management
- **GoRouter** - Navigation
- **Google Maps** - Location services

## Setup Instructions

### Prerequisites
- Node.js 18+ and Yarn
- Flutter 3.9+
- Supabase account

### Database Setup

1. Create a new Supabase project at https://supabase.com

2. Run the migration:
```bash
cd spanr-mechanic/sql/migrations
# Copy the contents of 001_initial_schema.sql to Supabase SQL Editor and run
```

3. Run storage setup:
```bash
# Copy the contents of storage.sql to Supabase SQL Editor and run
```

4. Run helper functions:
```bash
# Copy the contents of functions.sql to Supabase SQL Editor and run
```

### Mechanic Dashboard Setup

1. Navigate to the mechanic dashboard directory:
```bash
cd spanr-mechanic
```

2. Install dependencies:
```bash
yarn install
```

3. Create environment file:
```bash
cp .env.example .env
```

4. Update `.env` with your Supabase credentials:
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

5. Start the development server:
```bash
yarn dev
```

The dashboard will be available at http://localhost:5173

### User App Setup

1. Navigate to the Flutter app directory:
```bash
cd spanr_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update Supabase configuration in `lib/config/supabase_config.dart`:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

4. Run the app:
```bash
flutter run
```

## Features

### Mechanic Dashboard

#### Completed ✅
- **Authentication**
  - Email/password signup and login
  - Protected routes
  - Session management

- **Company Management**
  - Onboarding flow
  - Profile editing with logo upload
  - Certifications and specializations
  - Auto-create staff record for owner

- **Services Management**
  - Create, read, update, delete services
  - Icon uploads
  - Filter by vehicle type (car/bike)

- **Plans Management**
  - Complex plan creation with:
    - Basic info (name, vehicle type, location, duration, pricing)
    - Fuel types selection
    - Features list
    - FAQs
    - Service outcomes with images
    - Additional services
    - Process steps
  - Plan detail view
  - Image uploads

- **Orders Management**
  - Orders dashboard with stats
  - Filter by status and date range
  - Order detail view
  - Status update workflow
  - Customer and vehicle information
  - Payment tracking

- **Staff Management**
  - Add/edit/disable staff members
  - Permissions management
  - Staff access control

- **Dashboard & Navigation**
  - Sidebar navigation
  - Dashboard with statistics
  - Company branding in header

### User App (Flutter)

#### Completed ✅
- **Authentication**
  - Email/password signup and login
  - Session persistence
  - User profile creation

- **Core Setup**
  - Supabase integration
  - Navigation with bottom tabs
  - Theme configuration
  - State management with Provider

- **Home Screen**
  - User greeting
  - Search bar (placeholder)
  - Popular services grid
  - Quick access navigation

- **Profile**
  - View user information
  - Logout functionality

#### In Progress 🚧
- **Vehicles Management**
  - Models and services created
  - UI screens pending

- **Browse Mechanics**
  - Company model created
  - Listing and detail screens pending

#### Pending 📋
- **Services & Plans**
  - Browse services by company
  - View plan details
  - Price breakdown

- **Booking Flow**
  - Select vehicle
  - Choose date/time
  - Location picker with maps
  - Contact details form
  - Booking summary and confirmation

- **Orders**
  - View order history
  - Order details with status tracking
  - Contact mechanic

## Database Schema

### Core Tables
- `users` - Customer accounts
- `mechanic_companies` - Mechanic shop profiles
- `staff` - Employees of mechanic shops
- `services` - Service categories
- `plans` - Service plans with pricing
- `vehicles` - Customer vehicles
- `orders` - Service bookings
- `payments` - Payment transactions

### Supporting Tables
- `company_ratings` - Shop ratings
- `company_certifications` - Certifications
- `company_specializations` - Specializations
- `staff_access` - Permissions
- `plan_*` tables - Plan details (features, FAQs, outcomes, etc.)
- `images` - Generic image storage

## Security

- **Row Level Security (RLS)** enabled on all tables
- Public read access for company/service/plan data
- User-scoped access for personal data
- Company staff can only access their company's data
- JWT-based authentication

## API/Services Architecture

### React Services
- `auth.service.ts` - Authentication
- `company.service.ts` - Company CRUD
- `services.service.ts` - Services CRUD
- `plans.service.ts` - Plans with related data
- `orders.service.ts` - Orders management
- `staff.service.ts` - Staff management

### Flutter Services
- `auth_service.dart` - Authentication
- `vehicles_service.dart` - Vehicle management
- More services to be implemented...

## Next Steps

1. **Flutter App Completion**
   - Complete vehicle management UI
   - Implement mechanics browsing
   - Build services/plans browsing
   - Create booking flow with maps
   - Implement orders tracking

2. **Enhanced Features**
   - Real-time order updates
   - Push notifications
   - Payment gateway integration
   - Review and rating system
   - Analytics dashboard

3. **Testing**
   - Unit tests for services
   - Integration tests
   - E2E tests

4. **Deployment**
   - React app deployment (Vercel/Netlify)
   - Flutter app builds (iOS/Android)
   - Environment-specific configurations

## Contributing

This is a private project. Please contact the development team for contribution guidelines.

## License

Proprietary - All rights reserved

