# Ramadan Feature - Phase 1 Implementation

## Overview
This document describes the Ramadan feature implementation for the Islamic App. The feature provides accurate Sehri and Iftar times based on the user's GPS location, along with a beautiful countdown timer and a 30-day Ramadan calendar.

## Features Implemented

### 1. **Prayer Time Calculation Service**
- **File**: `lib/core/services/prayer_time_service.dart`
- **Technology**: Uses the `adhan` package (v2.0.0+1) - industry standard for Islamic prayer time calculations
- **Calculation Method**: Muslim World League (widely accepted globally)
- **Madhab**: Hanafi (configurable)
- **Features**:
  - Calculates all 5 daily prayers + sunrise
  - Generates 30-day Ramadan calendar
  - Caches prayer times for performance
  - Automatic location-based calculation

### 2. **Ramadan Countdown Card** (Home Page Widget)
- **File**: `lib/features/home/presentation/widgets/ramadan_countdown_card.dart`
- **Design Features**:
  - **Dynamic Gradient Backgrounds**:
    - Dawn colors (blue tones) for Sehri countdown
    - Sunset colors (orange/purple) for Iftar countdown
  - **Live Countdown Timer**: Updates every second showing Hours:Minutes:Seconds
  - **Ramadan Day Indicator**: Shows current day (1-30)
  - **Islamic Geometric Pattern**: Decorative overlay for premium feel
  - **Next Prayer Time Display**: Shows exact Sehri/Iftar time
  - **Smart Display Logic**: 
    - Before Fajr: Shows Sehri countdown
    - After Fajr: Shows Iftar countdown
    - Only visible during Ramadan month

### 3. **Ramadan Calendar Page**
- **File**: `lib/features/ramadan/presentation/pages/ramadan_calendar_page.dart`
- **Features**:
  - Full 30-day schedule with Sehri and Iftar times
  - Current day highlighted with special styling
  - Color-coded time indicators (blue for Sehri, orange for Iftar)
  - Elegant card-based layout
  - Empty states for non-Ramadan periods and missing location

### 4. **State Management**
- **File**: `lib/core/providers/ramadan_provider.dart`
- **Responsibilities**:
  - Manages prayer times state
  - Handles countdown timer (updates every second)
  - Tracks Ramadan start date and current day
  - Provides computed properties for UI (isRamadan, currentRamadanDay, etc.)
  - Supports refresh when location changes

### 5. **Data Models**
- **File**: `lib/core/models/prayer_times_data.dart`
- **Purpose**: Clean data structure for prayer times with helper methods
- **Methods**:
  - `getNextPrayerTime()`: Returns next upcoming prayer
  - `isCurrentlyFasting()`: Checks if between Fajr and Maghrib
  - `getTimeUntilSehriEnds()`: Duration until Fajr
  - `getTimeUntilIftar()`: Duration until Maghrib

## User Interface/UX Highlights

### Professional Design Elements
1. **Gradient Backgrounds**: Context-aware colors (dawn vs sunset)
2. **Smooth Animations**: Live countdown with no jank
3. **Islamic Aesthetics**: Geometric patterns, appropriate color palette
4. **Responsive Layout**: Works on all screen sizes
5. **Clear Typography**: Easy-to-read countdown numbers
6. **Visual Hierarchy**: Important info (countdown) is prominent

### User Flow
1. **Home Page**: User sees Ramadan countdown card immediately (if in Ramadan)
2. **Quick Access**: "Ramadan" button in horizontal scroll section
3. **Calendar View**: Tap Ramadan button to see full 30-day schedule
4. **Today Highlight**: Current day is visually distinct in calendar

## Configuration

### Ramadan Start Date
Currently hardcoded in `main.dart`:
```dart
await ramadanProvider.setRamadanStartDate(DateTime(2026, 2, 17));
```

**TODO**: Make this configurable in Settings page with:
- Manual date picker
- Automatic detection based on Hijri calendar
- Country-specific adjustments

### Prayer Calculation Settings
Currently uses:
- **Method**: Muslim World League
- **Madhab**: Hanafi

**TODO**: Add settings to allow users to choose:
- Different calculation methods (ISNA, Egypt, Makkah, etc.)
- Madhab preference (Hanafi vs Shafi)
- Manual time adjustments (+/- minutes)

## Dependencies Added

```yaml
# Prayer times calculation
adhan: ^2.0.0+1

# Date and time formatting
intl: ^0.19.0
```

## Integration Points

### Main App (`lib/main.dart`)
- Added `RamadanProvider` to MultiProvider
- Initialized provider on app startup
- Added `/ramadan-calendar` route

### Home Page (`lib/features/home/presentation/pages/home_page.dart`)
- Imported `RamadanCountdownCard`
- Added card after greeting/search section
- Positioned for maximum visibility

### Quick Access Section
- Added "Ramadan" tile with crescent moon icon
- Routes to Ramadan calendar page

## Location Permissions
The feature requires location permissions to calculate accurate prayer times. It uses the existing `LocationService` which handles:
- Permission requests
- GPS accuracy
- Fallback to last known location
- Error handling

## Performance Considerations

1. **Caching**: Prayer times are cached per day to avoid recalculation
2. **Timer Optimization**: Single timer updates UI every second (not per widget)
3. **Lazy Loading**: Calendar is only generated when needed
4. **Efficient Rebuilds**: Uses `Consumer` to rebuild only necessary widgets

## Future Enhancements (Phase 2+)

### Planned Features
1. **Smart Notifications**:
   - Pre-Sehri alarm (30-45 mins before Fajr)
   - Iftar alert at exact Maghrib time
   - Customizable notification sounds

2. **Daily Tracker**:
   - Fasting status checkbox
   - Prayer completion tracking
   - Quran reading progress
   - Charity (Sadaqah) log

3. **Duas & Supplications**:
   - Sehri Niyat (intention)
   - Iftar Dua
   - Audio playback for pronunciation
   - Bengali translations

4. **Khatam-ul-Quran Planner**:
   - Goal setting (finish Quran in 30 days)
   - Daily page recommendations
   - Progress tracking

5. **Zakat Calculator**:
   - Input assets (cash, gold, silver)
   - Automatic calculation (2.5%)
   - Currency support

6. **Settings Integration**:
   - Ramadan start date picker
   - Calculation method selector
   - Time adjustment sliders
   - Notification preferences

## Testing Checklist

- [x] Prayer times calculate correctly for current location
- [x] Countdown timer updates every second
- [x] Ramadan day counter is accurate
- [x] Calendar shows all 30 days
- [x] Current day is highlighted in calendar
- [x] Gradient colors change based on Sehri/Iftar
- [x] Navigation to calendar page works
- [x] Empty states display correctly
- [ ] Test with different locations (different time zones)
- [ ] Test on Ramadan start date boundary
- [ ] Test on Ramadan end date boundary
- [ ] Test with location permissions denied
- [ ] Test with no internet connection

## Known Issues / Limitations

1. **Ramadan Start Date**: Currently hardcoded, needs settings UI
2. **Calculation Method**: Fixed to Muslim World League, needs to be configurable
3. **Hijri Calendar**: Not integrated yet for automatic Ramadan detection
4. **Time Adjustments**: No manual +/- minutes adjustment yet
5. **Notifications**: Not implemented in Phase 1

## Code Quality

- ✅ Follows existing app architecture (features/core structure)
- ✅ Uses Provider for state management (consistent with app)
- ✅ Responsive design (tablet support)
- ✅ Dark mode support
- ✅ Proper error handling
- ✅ Clean separation of concerns (service/provider/UI)
- ✅ Reusable components (ElegantCard, AppTypography)

## Maintenance Notes

### Updating Ramadan Date Annually
1. Open `lib/main.dart`
2. Update the date in `setRamadanStartDate(DateTime(YEAR, MONTH, DAY))`
3. Rebuild and deploy

### Changing Calculation Method
1. Open `lib/core/services/prayer_time_service.dart`
2. Modify line: `final params = CalculationMethod.muslim_world_league.getParameters();`
3. Available methods: `muslim_world_league`, `egyptian`, `karachi`, `umm_al_qura`, `dubai`, `moon_sighting_committee`, `north_america`, `kuwait`, `qatar`, `singapore`

### Changing Madhab
1. Same file as above
2. Modify line: `params.madhab = Madhab.hanafi;`
3. Options: `Madhab.hanafi` or `Madhab.shafi`

---

**Implementation Date**: January 23, 2026  
**Version**: 1.0.0  
**Developer**: AI Assistant  
**Status**: Phase 1 Complete ✅
