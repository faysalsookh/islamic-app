# 🚀 Ramadan Feature - Phase 2 Implementation Plan

## Overview
This document outlines the implementation plan for Phase 2 enhancements to the Ramadan feature. Each feature is designed to enhance the user's Ramadan experience while maintaining the professional UI/UX standards established in Phase 1.

---

## 📋 Feature Priority & Complexity

| Feature | Priority | Complexity | Time Estimate | Impact |
|---------|----------|------------|---------------|--------|
| 1. Smart Notifications | HIGH | Medium | 3-4 hours | High |
| 2. Settings Integration | HIGH | Low | 1-2 hours | High |
| 3. Daily Tracker | MEDIUM | Medium | 4-5 hours | High |
| 4. Khatam-ul-Quran Planner | MEDIUM | Medium | 3-4 hours | Medium |
| 5. Zakat Calculator | LOW | Low | 2-3 hours | Medium |
| 6. Audio Playback for Duas | LOW | Medium | 2-3 hours | Low |

---

## 1️⃣ Smart Notifications 🔔

### Purpose
Automatically remind users about Sehri and Iftar times to help them maintain their fasting schedule.

### Features

#### A. Pre-Sehri Alarm
- **Timing**: 30-45 minutes before Fajr (user configurable)
- **Title**: "Time for Sehri!"
- **Body**: "Sehri ends at [TIME] - [XX] minutes remaining"
- **Action**: Tap to open app and see countdown
- **Sound**: Gentle Islamic nasheed or Adhan sound

#### B. Iftar Alert
- **Timing**: Exactly at Maghrib time
- **Title**: "Time to Break Your Fast!"
- **Body**: "Maghrib has entered. May Allah accept your fast."
- **Action**: Tap to view Iftar dua
- **Sound**: Adhan or custom notification sound

#### C. Optional Reminders
- **Taraweeh Reminder**: 30 mins after Isha
- **Sahoor Wake-up**: 1 hour before Fajr (for heavy sleepers)
- **Dua Reminder**: 10 mins before Maghrib (best time for dua)

### Technical Implementation

**Dependencies Needed**:
```yaml
flutter_local_notifications: ^17.0.0  # Local notifications
timezone: ^0.9.0  # Timezone handling
permission_handler: ^11.0.0  # Notification permissions
```

**Files to Create**:
- `lib/core/services/notification_service.dart` - Notification manager
- `lib/core/services/ramadan_notification_scheduler.dart` - Schedule Ramadan-specific notifications
- `lib/features/settings/widgets/notification_settings_section.dart` - Settings UI

**Implementation Steps**:
1. Create notification service with local notifications
2. Schedule daily notifications based on prayer times
3. Handle notification taps (deep linking to specific pages)
4. Add notification permission request flow
5. Create settings UI for customization
6. Add notification sound selection

**User Settings**:
- Enable/disable Sehri alarm
- Sehri alarm offset (15, 30, 45, 60 minutes before Fajr)
- Enable/disable Iftar alert
- Enable/disable Taraweeh reminder
- Notification sound selection
- Vibration on/off

---

## 2️⃣ Settings Integration ⚙️

### Purpose
Allow users to customize Ramadan feature according to their location, madhab, and preferences.

### Features

#### A. Ramadan Date Settings
- **Manual Date Picker**: Select Ramadan start date
- **Auto-Detection**: Use Hijri calendar API for automatic detection
- **Country Preset**: Common Ramadan dates by country

#### B. Prayer Calculation Settings
- **Calculation Method**: 
  - Muslim World League (default)
  - Egyptian General Authority
  - University of Islamic Sciences, Karachi
  - Umm Al-Qura University, Makkah
  - Dubai
  - ISNA (North America)
  - Kuwait, Qatar, Singapore
- **Madhab**: Hanafi or Shafi (affects Asr time)
- **Manual Adjustments**: +/- minutes for each prayer

#### C. Display Settings
- **Time Format**: 12-hour or 24-hour
- **Language**: English or Bengali for translations
- **Countdown Visibility**: Always show or only during Ramadan

### Technical Implementation

**Files to Create**:
- `lib/features/settings/widgets/ramadan_settings_section.dart` - Settings UI
- `lib/core/models/ramadan_settings.dart` - Settings data model
- `lib/core/services/settings_storage_service.dart` - Persist settings

**Implementation Steps**:
1. Create settings data model
2. Add settings storage (SharedPreferences or Hive)
3. Create settings UI section in Settings page
4. Update PrayerTimeService to use custom settings
5. Add validation and error handling

**UI Components**:
- Date picker dialog
- Dropdown for calculation method
- Radio buttons for Madhab
- Sliders for time adjustments
- Toggle switches for features

---

## 3️⃣ Daily Tracker ✅

### Purpose
Help users track their daily Ramadan activities and maintain consistency throughout the month.

### Features

#### A. Daily Checklist
- **Fasting Status**: "I kept my fast today" checkbox
- **5 Daily Prayers**: Individual checkboxes for Fajr, Dhuhr, Asr, Maghrib, Isha
- **Taraweeh**: "I prayed Taraweeh" checkbox
- **Quran Reading**: Pages read today (number input)
- **Sadaqah**: "I gave charity today" checkbox
- **Dua**: "I made special dua" checkbox

#### B. Progress Visualization
- **Daily Completion**: Circular progress indicator
- **Monthly Overview**: Calendar view with completion dots
- **Streak Counter**: "X days in a row completed"
- **Statistics**: Total prayers, pages read, days fasted

#### C. Motivational Elements
- **Completion Animation**: Celebrate when all items checked
- **Badges**: Earn badges for milestones (7 days, 15 days, 30 days)
- **Quotes**: Daily Islamic quotes about Ramadan

### Technical Implementation

**Dependencies Needed**:
```yaml
fl_chart: ^0.68.0  # For progress charts
confetti: ^0.7.0  # Celebration animations
```

**Files to Create**:
- `lib/features/ramadan/presentation/pages/daily_tracker_page.dart` - Main tracker UI
- `lib/features/ramadan/presentation/widgets/tracker_checklist.dart` - Checklist widget
- `lib/features/ramadan/presentation/widgets/progress_chart.dart` - Progress visualization
- `lib/core/models/daily_tracker_data.dart` - Data model
- `lib/core/services/tracker_storage_service.dart` - Local storage

**Implementation Steps**:
1. Create data model for daily activities
2. Build checklist UI with checkboxes
3. Implement local storage (Hive)
4. Create progress visualization
5. Add streak calculation logic
6. Implement badge system
7. Add celebration animations

**Data Structure**:
```dart
class DailyTrackerData {
  final DateTime date;
  final bool fasted;
  final Map<String, bool> prayers; // fajr, dhuhr, asr, maghrib, isha
  final bool taraweeh;
  final int quranPages;
  final bool sadaqah;
  final bool specialDua;
}
```

---

## 4️⃣ Khatam-ul-Quran Planner 📖

### Purpose
Help users complete reading the entire Quran during Ramadan with a personalized reading plan.

### Features

#### A. Goal Setting
- **Completion Target**: Finish in 15, 20, or 30 days
- **Daily Pages**: Auto-calculated based on target
- **Flexible Schedule**: Adjust daily target
- **Start Date**: Begin from any day of Ramadan

#### B. Progress Tracking
- **Daily Goal**: "Read X pages today"
- **Progress Bar**: Visual indicator of completion
- **Pages Read**: Mark pages as completed
- **Behind/Ahead**: Show if user is on track
- **Completion Date**: Estimated finish date

#### C. Smart Features
- **Reminders**: Daily notification to read Quran
- **Bookmark Integration**: Sync with existing bookmarks
- **Surah Breakdown**: Show which surahs to read today
- **Catch-up Mode**: Redistribute remaining pages if behind

### Technical Implementation

**Files to Create**:
- `lib/features/ramadan/presentation/pages/quran_planner_page.dart` - Main planner UI
- `lib/features/ramadan/presentation/widgets/reading_goal_widget.dart` - Goal display
- `lib/features/ramadan/presentation/widgets/progress_tracker_widget.dart` - Progress UI
- `lib/core/models/quran_reading_plan.dart` - Data model
- `lib/core/services/quran_planner_service.dart` - Calculation logic

**Implementation Steps**:
1. Create reading plan data model
2. Build goal setting UI
3. Implement page calculation algorithm
4. Create progress tracking UI
5. Add daily reminder notifications
6. Integrate with existing Quran reader
7. Add catch-up logic

**Calculation Logic**:
```dart
// Total Quran pages: 604
int dailyPages = 604 / targetDays;
int remainingPages = 604 - completedPages;
int remainingDays = 30 - currentDay;
int adjustedDailyPages = remainingPages / remainingDays;
```

---

## 5️⃣ Zakat Calculator 💰

### Purpose
Help users calculate their annual Zakat obligation, which is often paid during Ramadan.

### Features

#### A. Asset Input
- **Cash**: Savings, checking accounts
- **Gold**: Weight in grams or ounces
- **Silver**: Weight in grams or ounces
- **Investments**: Stocks, bonds, mutual funds
- **Business Assets**: Inventory, receivables
- **Other Assets**: Rental income, etc.

#### B. Liabilities
- **Debts**: Short-term debts to deduct
- **Expenses**: Immediate expenses

#### C. Calculation
- **Nisab Threshold**: Check if Zakat is due
- **Zakat Amount**: 2.5% of eligible assets
- **Currency Support**: Multiple currencies
- **Gold/Silver Prices**: Auto-fetch current prices (optional)

#### D. Payment Tracking
- **Mark as Paid**: Track Zakat payment
- **Payment History**: View past Zakat payments
- **Reminder**: Annual Zakat reminder

### Technical Implementation

**Dependencies Needed**:
```yaml
http: ^1.2.0  # Already added (for gold/silver prices API)
```

**Files to Create**:
- `lib/features/ramadan/presentation/pages/zakat_calculator_page.dart` - Main calculator UI
- `lib/features/ramadan/presentation/widgets/asset_input_form.dart` - Input form
- `lib/core/models/zakat_calculation.dart` - Data model
- `lib/core/services/zakat_calculator_service.dart` - Calculation logic

**Implementation Steps**:
1. Create asset input form
2. Implement Nisab calculation
3. Build Zakat calculation logic (2.5%)
4. Add currency conversion
5. Create results display UI
6. Add payment tracking
7. Implement local storage for history

**Nisab Values** (2026):
- Gold: 87.48 grams (3 ounces)
- Silver: 612.36 grams (21.5 ounces)

---

## 6️⃣ Audio Playback for Duas 🔊

### Purpose
Help users learn correct pronunciation of Ramadan duas through audio playback.

### Features

#### A. Audio Files
- **Sehri Dua**: Audio recitation
- **Iftar Dua**: Audio recitation
- **Laylatul Qadr Dua**: Audio recitation
- **Multiple Reciters**: Choose preferred reciter

#### B. Playback Controls
- **Play/Pause**: Standard controls
- **Repeat**: Loop audio
- **Speed Control**: Slow down for learning
- **Download**: Offline playback

#### C. Learning Features
- **Highlight Text**: Sync Arabic text with audio
- **Phonetic Guide**: Show transliteration during playback
- **Practice Mode**: Pause between phrases

### Technical Implementation

**Dependencies**: Already have `just_audio: ^0.9.40` ✅

**Files to Create**:
- `lib/features/ramadan/presentation/widgets/dua_audio_player.dart` - Audio player widget
- `lib/core/services/dua_audio_service.dart` - Audio management

**Implementation Steps**:
1. Source/record audio files for duas
2. Add audio files to assets
3. Create audio player widget
4. Implement playback controls
5. Add text highlighting sync
6. Implement download for offline use

**Audio Sources**:
- Record with professional reciter
- Use royalty-free Islamic audio
- Ensure high quality (MP3, 128kbps+)

---

## 📊 Implementation Roadmap

### Recommended Order

**Week 1**: Foundation
1. ✅ Settings Integration (1-2 hours)
2. ✅ Smart Notifications (3-4 hours)

**Week 2**: Core Features
3. ✅ Daily Tracker (4-5 hours)
4. ✅ Khatam-ul-Quran Planner (3-4 hours)

**Week 3**: Additional Features
5. ✅ Zakat Calculator (2-3 hours)
6. ✅ Audio Playback for Duas (2-3 hours)

**Total Estimated Time**: 15-20 hours

---

## 🎯 Success Metrics

After Phase 2 implementation, users will be able to:

✅ Receive automatic Sehri and Iftar reminders  
✅ Customize prayer calculation methods  
✅ Track daily Ramadan activities  
✅ Follow a personalized Quran reading plan  
✅ Calculate Zakat accurately  
✅ Learn dua pronunciation with audio  

---

## 🔧 Technical Considerations

### Performance
- Use background tasks for notifications
- Cache audio files for offline use
- Optimize database queries for tracker
- Lazy load heavy components

### Storage
- Hive for local data (tracker, settings)
- SharedPreferences for simple settings
- Asset bundling for audio files

### Permissions
- Notification permissions
- Storage permissions (for audio download)
- Location permissions (already handled)

### Testing
- Unit tests for calculation logic
- Widget tests for UI components
- Integration tests for notification flow
- Manual testing for audio playback

---

## 📱 UI/UX Guidelines

### Consistency
- Use existing color scheme
- Follow established typography
- Maintain card-based layouts
- Ensure dark mode support

### Accessibility
- Clear labels for all inputs
- Sufficient touch targets (48x48dp)
- High contrast for readability
- Screen reader support

### Feedback
- Loading states for async operations
- Success animations for completions
- Error messages with solutions
- Progress indicators

---

## 🚀 Ready to Start?

Choose which feature to implement first, or I can start with the recommended order:

1. **Settings Integration** (Quick win, enables customization)
2. **Smart Notifications** (High impact, users will love this)
3. **Daily Tracker** (Engaging, encourages consistency)
4. **Khatam-ul-Quran Planner** (Unique value proposition)
5. **Zakat Calculator** (Practical utility)
6. **Audio Playback** (Nice-to-have enhancement)

**Which feature would you like me to implement first?**
