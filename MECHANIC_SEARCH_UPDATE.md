# Mechanic Search and Display Updates

## Changes Summary

### 1. **Search by Company Name**
- Changed search functionality from services to mechanic companies
- Added functional search bar with debouncing (500ms delay)
- Search performs case-insensitive partial matching on company names

### 2. **Mechanic Card Updates**
- **Removed**: Pricing information (previously hardcoded $250.00)
- **Added**: Star rating with review count (e.g., "4.5 (23)" or "New")
- **Added**: Distance from user location (e.g., "2.3km away" or "850m away")
- **Added**: Full address display (address line, city)
- **Added**: Phone number display
- Improved layout with better spacing and information hierarchy

### 3. **Infinite Scroll with 7km Radius**
- Implemented infinite scroll pagination (loads 10 mechanics at a time)
- Enforces 7km radius limit from user location
- Shows "End of results" message when no more mechanics within 7km
- Loading indicator while fetching more results

### 4. **Database Schema Updates**
- Added `latitude` and `longitude` columns to `mechanic_companies` table
- Created migration file: `add_geolocation_to_companies.sql`
- Added indexes for better geolocation query performance

## Files Modified

### Flutter App (spanr_app)
1. **lib/mechanics/models/mechanic_company.dart**
   - Added `distanceKm` field
   - Added `displayDistance` getter
   - Added `copyWith` method

2. **lib/mechanics/mechanics_service.dart**
   - Added `searchQuery` parameter to `getNearbyMechanics`
   - Implemented distance calculation and attachment to each mechanic
   - Enhanced filtering by search query and radius

3. **lib/mechanics/mechanics_provider.dart**
   - Added `_lastSearchQuery` state
   - Updated `loadNearbyMechanics` to support search
   - Added `searchMechanics` method

4. **lib/mechanics/widgets/mechanic_card.dart**
   - Removed hardcoded pricing
   - Added rating display with star icon
   - Added distance display with location icon
   - Enhanced address and contact info display

5. **lib/screens/home_screen.dart**
   - Changed title to "Find Mechanics Near You"
   - Replaced static search UI with functional TextField
   - Added debouncing to search (500ms delay)
   - Enhanced "end of results" message with icon and description

### Backend (spanr-mechanic)
1. **sql/migrations/001_initial_schema.sql**
   - Added latitude and longitude columns to mechanic_companies table

2. **sql/migrations/add_geolocation_to_companies.sql** (NEW)
   - Migration script to add geolocation columns to existing databases
   - Added indexes for better performance

## How It Works

### Search Flow
1. User types in search bar
2. 500ms debounce timer starts
3. When timer completes, `searchMechanics()` is called
4. Service fetches companies matching search query
5. Distance is calculated and attached to each company
6. Companies within 7km radius are returned, sorted by distance

### Infinite Scroll
1. User scrolls to 80% of list
2. Provider checks if more results available (`hasMore`)
3. Loads next batch of 10 mechanics
4. When no more results or 7km limit reached, shows "End of results" message

## Next Steps

### Required Actions
1. **Run Migration**: Execute `add_geolocation_to_companies.sql` on existing database
2. **Update Company Data**: Add latitude/longitude to existing mechanic companies
3. **Test Search**: Verify search functionality with various company names
4. **Test Distance**: Ensure distance calculations are accurate

### Optional Enhancements
- Add geocoding service to automatically convert addresses to lat/lng when companies register
- Implement search filters (rating, services offered, etc.)
- Add map view of nearby mechanics
- Cache search results for better performance

