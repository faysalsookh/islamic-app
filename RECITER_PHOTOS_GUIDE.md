# Reciter Photos Implementation Guide

## Overview
This guide explains how to add and display reciter photos in the Islamic app for easy visual recognition.

## ✅ What's Already Done

1. **Photo URL Property Added**
   - Added `photoUrl` getter to `ReciterExtension` in `audio_service.dart`
   - Each reciter has a designated photo path

2. **Assets Directory Created**
   - Created `assets/images/reciters/` directory
   - Added README with photo guidelines

3. **Assets Configuration**
   - `pubspec.yaml` already includes `assets/images/` directory

## 📋 Next Steps

### Step 1: Add Actual Reciter Photos

Add high-quality photos (400x400px) to `assets/images/reciters/`:

```
assets/images/reciters/
├── mishary_alafasy.jpg
├── abdul_basit.jpg
├── sudais.jpg
├── maher_muaiqly.jpg
├── saad_ghamdi.jpg
├── shatri.jpg
├── minshawi.jpg
├── hani_rifai.jpg
├── hudhaify.jpg
├── ahmed_ajmi.jpg
├── ali_jaber.jpg
├── yasser_dosari.jpg
└── nasser_qatami.jpg
```

**Where to find photos:**
- Official Islamic websites
- Verified social media accounts
- Islamic audio platforms (with permission)
- Public domain Islamic resources

### Step 2: Update Audio Settings UI

Modify `audio_settings_sheet.dart` to display reciter photos:

```dart
// In _buildReciterCard method, add photo display:

Widget _buildReciterCard(Reciter reciter, bool isSelected, bool isDark, ThemeData theme) {
  return GestureDetector(
    onTap: () {
      _audioService.setReciter(reciter);
      setState(() {});
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : (isDark ? AppColors.dividerDark : AppColors.divider),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Reciter Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: reciter.photoUrl != null
                ? Image.asset(
                    reciter.photoUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to initial if photo not found
                      return _buildReciterInitial(reciter, isSelected, theme);
                    },
                  )
                : _buildReciterInitial(reciter, isSelected, theme),
          ),
          const SizedBox(width: 12),
          
          // Reciter Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reciter.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reciter.displayNameArabic,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Amiri',
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reciter.recitationStyle.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reciter.audioQuality,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Selection indicator
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
        ],
      ),
    ),
  );
}

Widget _buildReciterInitial(Reciter reciter, bool isSelected, ThemeData theme) {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        _getReciterInitials(reciter),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Amiri',
          color: isSelected ? Colors.white : theme.colorScheme.primary,
        ),
      ),
    ),
  );
}
```

### Step 3: Add Photo Preview in Player Bar

Update `audio_player_bar.dart` to show current reciter photo:

```dart
// Add reciter photo to the player bar
Row(
  children: [
    // Reciter Photo (small)
    if (_audioService.currentReciter.photoUrl != null)
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          _audioService.currentReciter.photoUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.person_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            );
          },
        ),
      ),
    const SizedBox(width: 12),
    
    // Reciter name and surah info
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _audioService.currentReciter.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            'Surah ${_audioService.currentSurah} : ${_audioService.currentAyah}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  ],
)
```

## 🎨 UI Enhancements

### Reciter Grid View (Alternative Layout)

For a more visual experience, consider a grid layout:

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.85,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: Reciter.values.length,
  itemBuilder: (context, index) {
    final reciter = Reciter.values[index];
    final isSelected = _audioService.currentReciter == reciter;
    
    return GestureDetector(
      onTap: () => _audioService.setReciter(reciter),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large reciter photo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: reciter.photoUrl != null
                  ? Image.asset(
                      reciter.photoUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            
            // Name
            Text(
              reciter.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            
            // Arabic name
            Text(
              reciter.displayNameArabic,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Amiri',
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  },
)
```

## 📱 Responsive Design

For tablets, use a 3 or 4-column grid:

```dart
final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 2;
```

## ✨ Benefits

1. **Visual Recognition** - Users can quickly identify their favorite reciters
2. **Professional Look** - Adds authenticity and trust
3. **Better UX** - Easier to browse and select reciters
4. **Cultural Connection** - Users feel more connected to the reciters

## 🔒 Important Notes

- Always use respectful, authentic photos
- Ensure you have rights to use the photos
- Maintain consistent photo quality and style
- Test fallback UI when photos are missing
- Consider adding a "loading" state for network images

## 🚀 Future Enhancements

- Add reciter biography/details page
- Include sample audio clips
- Show reciter's most popular surahs
- Add user ratings/favorites
- Implement reciter search/filter
