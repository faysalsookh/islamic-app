# Shohoz Quran (Easy Quran) Implementation Plan

## Overview
Transform the existing Islamic app into a comprehensive "Shohoz Quran" style application with color-coded Tajweed, Bangla translations/transliterations, Tafsir, audio recitation with highlighting, and offline support.

---

## Phase 1: Data Layer Foundation

### 1.1 Enhanced Data Models

**Update Ayah Model** (`lib/core/models/ayah.dart`)
- Add `textArabicWithTajweed` field (HTML-like markup for Tajweed rules)
- Add `transliterationBengali` field
- Add `transliterationEnglish` field
- Add `tafsir` field (explanation text)
- Add `shaniNuzul` field (context of revelation)
- Add `audioUrl` field (URL to ayah audio)

**Create Tajweed Model** (`lib/core/models/tajweed.dart`)
- Define TajweedRule enum: ikhfa, idgham, iqlab, madd, qalqalah, ghunnah, etc.
- Define color mapping for each rule
- Create TajweedSegment class to represent marked text portions

**Create Juz Model** (`lib/core/models/juz.dart`)
- juzNumber, startSurah, startAyah, endSurah, endAyah
- Create JuzData with all 30 Juz definitions

### 1.2 Local Database Setup

**Implement Hive Storage** (`lib/core/services/database_service.dart`)
- Initialize Hive boxes for: surahs, ayahs, bookmarks, readingProgress, downloadedAudio
- Create TypeAdapters for Surah, Ayah, Bookmark models
- Implement CRUD operations
- Add migration support for future updates

**Create Quran Data Service** (`lib/core/services/quran_data_service.dart`)
- Load initial Quran data from bundled JSON assets
- Sync data to Hive on first launch
- Provide query methods: getAyahsBySurah, getAyahsByJuz, getAyahsByPage
- Support search functionality

### 1.3 Quran JSON Data Structure

**Create comprehensive JSON** (`assets/data/quran_full.json`)
```json
{
  "surahs": [
    {
      "number": 1,
      "nameArabic": "الفاتحة",
      "nameEnglish": "The Opening",
      "nameBengali": "সূরা ফাতিহা",
      "ayahCount": 7,
      "revelationType": "Meccan",
      "ayahs": [
        {
          "numberInSurah": 1,
          "textArabic": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
          "textWithTajweed": "<madd>بِسْمِ</madd> اللَّهِ <ikhfa>الرَّحْمَٰنِ</ikhfa> الرَّحِيمِ",
          "translationEnglish": "In the name of Allah, the Most Gracious, the Most Merciful",
          "translationBengali": "পরম করুণাময় অতি দয়ালু আল্লাহর নামে",
          "transliterationBengali": "বিসমিল্লাহির রাহমানির রাহীম",
          "transliterationEnglish": "Bismillahir Rahmanir Raheem",
          "tafsir": "This verse is known as Basmalah...",
          "shaniNuzul": "This surah was revealed in Makkah...",
          "juz": 1,
          "page": 1,
          "audioUrl": "audio/001001.mp3"
        }
      ]
    }
  ]
}
```

---

## Phase 2: Tajweed System

### 2.1 Tajweed Parser & Renderer

**Create Tajweed Service** (`lib/core/services/tajweed_service.dart`)
- Parse Tajweed markup from JSON (e.g., `<ikhfa>text</ikhfa>`)
- Convert to list of TajweedSegment objects
- Handle nested/overlapping rules

**Create Tajweed Widget** (`lib/core/widgets/tajweed_text.dart`)
- Custom widget extending RichText
- Render Arabic text with color-coded Tajweed
- Color mapping:
  - Ikhfa (إخفاء): Green `#4CAF50`
  - Idgham (إدغام): Red `#E53935`
  - Iqlab (إقلاب): Purple `#9C27B0`
  - Madd (مد): Blue `#2196F3`
  - Qalqalah (قلقلة): Orange `#FF9800`
  - Ghunnah (غنة): Pink `#E91E63`
- Support tap gesture for beginner mode

### 2.2 Tajweed Learning Mode

**Create Tajweed Tooltip** (`lib/core/widgets/tajweed_tooltip.dart`)
- Popup showing rule name in Arabic, English, Bengali
- Brief explanation of the rule
- Audio pronunciation example (optional)

**Update AppStateProvider**
- Add `isTajweedLearningMode` boolean
- Add `showTajweedColors` boolean (toggle colors on/off)

---

## Phase 3: Audio System

### 3.1 Audio Playback Service

**Create Audio Service** (`lib/core/services/audio_service.dart`)
- Use just_audio package (already installed)
- Implement playAyah(surahNumber, ayahNumber)
- Implement playFromAyah(surah, ayah) - continuous play
- Implement pause, resume, stop, seekTo
- Handle audio focus and interruptions
- Support background playback

**Audio Features**
- Multiple reciters support (Mishary, Abdul Basit, etc.)
- Playback speed control (0.5x to 2x)
- Repeat modes: single ayah, range, surah, continuous
- Sleep timer

### 3.2 Audio Highlighting

**Update Ayah Display Widgets**
- Highlight currently playing ayah with subtle background color
- Auto-scroll to current ayah during playback
- Visual progress indicator within ayah (optional)

### 3.3 Offline Audio

**Create Audio Cache Service** (`lib/core/services/audio_cache_service.dart`)
- Download audio files to app storage
- Track download progress
- Manage storage (delete old cached files)
- Check connectivity before streaming

---

## Phase 4: Enhanced UI Components

### 4.1 Book-Like Quran View

**Update MushafView** (`lib/features/quran/widgets/mushaf_view.dart`)
- Clean, book-like layout matching printed Shohoz Quran
- Page numbers at bottom
- Decorative borders (subtle)
- Bismillah header for each surah
- Surah header with name and info

### 4.2 Ayah Display Enhancements

**Update AyahListView** (`lib/features/quran/widgets/ayah_list_view.dart`)
- Show Tajweed-colored Arabic text
- Toggle: Translation (English/Bengali/Both/None)
- Toggle: Transliteration (English/Bengali/None)
- Tafsir button per ayah (opens bottom sheet)
- Play button per ayah
- Bookmark button per ayah

### 4.3 Tafsir & Shani Nuzul Sheet

**Create TafsirBottomSheet** (`lib/features/quran/widgets/tafsir_bottom_sheet.dart`)
- Draggable bottom sheet
- Tabs: Tafsir | Shani Nuzul
- Formatted text with proper Arabic/Bengali typography
- Share button

### 4.4 Navigation Enhancements

**Create JuzListPage** (`lib/features/quran/pages/juz_list_page.dart`)
- List all 30 Juz with start/end info
- Tap to navigate to Juz start

**Update SurahListPage**
- Add search functionality
- Filter by revelation type (Meccan/Medinan)
- Show Bengali name alongside Arabic/English

### 4.5 Audio Player Bar

**Create AudioPlayerBar** (`lib/core/widgets/audio_player_bar.dart`)
- Mini player at bottom of Quran reader
- Shows: current surah/ayah, play/pause, next/prev, progress
- Expandable to full player with more controls
- Reciter selection
- Speed control
- Repeat options

---

## Phase 5: Settings & Accessibility

### 5.1 Reading Settings

**Update SettingsPage**
- Font size slider (with preview)
- Arabic font selection: Uthmani, IndoPak (Naskh), Scheherazade
- Translation language: English, Bengali, Both, None
- Transliteration: English, Bengali, None
- Tajweed colors: On/Off
- Tajweed learning mode: On/Off

### 5.2 Audio Settings

- Default reciter selection
- Auto-play on page open: On/Off
- Playback speed default
- Download quality: High/Medium/Low

### 5.3 Offline Management

**Create OfflineManagerPage** (`lib/features/settings/pages/offline_manager_page.dart`)
- Show downloaded surahs/juz
- Download all / selected surahs
- Storage usage display
- Clear cache option

---

## Phase 6: Additional Features

### 6.1 Search

**Create SearchPage** (`lib/features/search/pages/search_page.dart`)
- Search in Arabic text
- Search in translations
- Search in transliterations
- Show results with context
- Navigate to ayah on tap

### 6.2 Reading Progress

- Track last read position per surah
- Daily reading statistics
- Reading streaks (optional gamification)

### 6.3 Bookmarks Enhancement

- Categories/folders for bookmarks
- Notes on bookmarks
- Export/import bookmarks

---

## Implementation Order

1. **Phase 1.1-1.2**: Data models and Hive setup (Foundation)
2. **Phase 1.3**: Create sample Quran JSON with Tajweed (Al-Fatihah, first few surahs)
3. **Phase 2**: Tajweed parser and colored text widget
4. **Phase 4.2**: Update ayah display with Tajweed
5. **Phase 3.1-3.2**: Audio playback with highlighting
6. **Phase 4.5**: Audio player bar UI
7. **Phase 4.4**: Juz list page
8. **Phase 4.3**: Tafsir bottom sheet
9. **Phase 5**: Settings updates
10. **Phase 3.3 & 5.3**: Offline audio and management
11. **Phase 6**: Search and enhanced bookmarks

---

## Technical Notes

### Dependencies to Add
```yaml
dependencies:
  hive: ^2.2.3  # Already added
  hive_flutter: ^1.1.0  # Already added
  just_audio: ^0.9.36  # Already added
  audio_service: ^0.18.12  # For background playback
  connectivity_plus: ^5.0.2  # For offline detection
  path_provider: ^2.1.1  # Already added
```

### File Structure
```
lib/
├── core/
│   ├── models/
│   │   ├── ayah.dart (updated)
│   │   ├── tajweed.dart (new)
│   │   └── juz.dart (new)
│   ├── services/
│   │   ├── database_service.dart (new)
│   │   ├── quran_data_service.dart (new)
│   │   ├── tajweed_service.dart (new)
│   │   ├── audio_service.dart (new)
│   │   └── audio_cache_service.dart (new)
│   └── widgets/
│       ├── tajweed_text.dart (new)
│       ├── tajweed_tooltip.dart (new)
│       └── audio_player_bar.dart (new)
├── features/
│   ├── quran/
│   │   ├── pages/
│   │   │   └── juz_list_page.dart (new)
│   │   └── widgets/
│   │       └── tafsir_bottom_sheet.dart (new)
│   ├── search/
│   │   └── pages/
│   │       └── search_page.dart (new)
│   └── settings/
│       └── pages/
│           └── offline_manager_page.dart (new)
└── assets/
    └── data/
        └── quran_full.json (new)
```

---

## Sample Tajweed Colors (Matching Shohoz Quran)

| Rule | Arabic | Color | Hex Code |
|------|--------|-------|----------|
| Ikhfa | إخفاء | Green | #4CAF50 |
| Idgham | إدغام | Red | #E53935 |
| Iqlab | إقلاب | Purple | #9C27B0 |
| Madd | مد | Blue | #2196F3 |
| Qalqalah | قلقلة | Orange | #FF9800 |
| Ghunnah | غنة | Pink | #E91E63 |

---

## Estimated Scope

- **New Files**: ~15-20 files
- **Modified Files**: ~10-15 files
- **New Dependencies**: 2 packages (audio_service, connectivity_plus)

This plan provides a complete roadmap for implementing all Shohoz Quran features while leveraging the existing codebase architecture.
