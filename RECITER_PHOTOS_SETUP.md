# Reciter Photos - Quick Setup Guide

## ✅ What's Already Done

The audio settings UI has been updated to display reciter photos! Here's what's implemented:

1. **Photo Display Logic**
   - Shows reciter photos if available
   - Gracefully falls back to initials if photo not found
   - Maintains the same beautiful UI design

2. **Code Changes**
   - Updated `audio_settings_sheet.dart` to use `Image.asset()`
   - Added `_buildReciterInitialAvatar()` helper method
   - Configured error handling with fallback

## 📸 Adding the Photos

### Option 1: Use the Generated AI Photos (Quick Demo)

I've generated professional AI portraits for all 13 reciters. To use them:

1. The generated images are in the artifacts/brain directory
2. Copy them to your project:
   ```bash
   # From the project root
   cp ~/.gemini/antigravity/brain/*/mishary_alafasy_portrait_*.png assets/images/reciters/mishary_alafasy.jpg
   cp ~/.gemini/antigravity/brain/*/abdul_basit_portrait_*.png assets/images/reciters/abdul_basit.jpg
   cp ~/.gemini/antigravity/brain/*/sudais_portrait_*.png assets/images/reciters/sudais.jpg
   cp ~/.gemini/antigravity/brain/*/maher_muaiqly_portrait_*.png assets/images/reciters/maher_muaiqly.jpg
   cp ~/.gemini/antigravity/brain/*/saad_ghamdi_portrait_*.png assets/images/reciters/saad_ghamdi.jpg
   cp ~/.gemini/antigravity/brain/*/shatri_portrait_*.png assets/images/reciters/shatri.jpg
   cp ~/.gemini/antigravity/brain/*/minshawi_portrait_*.png assets/images/reciters/minshawi.jpg
   cp ~/.gemini/antigravity/brain/*/hani_rifai_portrait_*.png assets/images/reciters/hani_rifai.jpg
   cp ~/.gemini/antigravity/brain/*/hudhaify_portrait_*.png assets/images/reciters/hudhaify.jpg
   cp ~/.gemini/antigravity/brain/*/ahmed_ajmi_portrait_*.png assets/images/reciters/ahmed_ajmi.jpg
   cp ~/.gemini/antigravity/brain/*/ali_jaber_portrait_*.png assets/images/reciters/ali_jaber.jpg
   cp ~/.gemini/antigravity/brain/*/yasser_dosari_portrait_*.png assets/images/reciters/yasser_dosari.jpg
   cp ~/.gemini/antigravity/brain/*/nasser_qatami_portrait_*.png assets/images/reciters/nasser_qatami.jpg
   ```

### Option 2: Use Actual Reciter Photos (Production)

For production, use authentic photos:

1. Find authentic photos from:
   - Official Islamic websites
   - Verified social media accounts
   - Islamic audio platforms (with permission)
   - Public domain Islamic resources

2. Resize to 400x400px square format

3. Save as JPG in `assets/images/reciters/` with these exact names:
   ```
   mishary_alafasy.jpg
   abdul_basit.jpg
   sudais.jpg
   maher_muaiqly.jpg
   saad_ghamdi.jpg
   shatri.jpg
   minshawi.jpg
   hani_rifai.jpg
   hudhaify.jpg
   ahmed_ajmi.jpg
   ali_jaber.jpg
   yasser_dosari.jpg
   nasser_qatami.jpg
   ```

## 🎨 How It Looks

### With Photos:
```
┌─────────────────────────────────────┐
│ [Photo] Mishary Rashid Alafasy  ✓  │
│         مشاري راشد العفاسي         │
├─────────────────────────────────────┤
│ [Photo] Abdul Basit Abdul Samad    │
│         عبد الباسط عبد الصمد       │
└─────────────────────────────────────┘
```

### Without Photos (Fallback):
```
┌─────────────────────────────────────┐
│  [م]   Mishary Rashid Alafasy   ✓  │
│        مشاري راشد العفاسي          │
├─────────────────────────────────────┤
│  [ع]   Abdul Basit Abdul Samad     │
│        عبد الباسط عبد الصمد        │
└─────────────────────────────────────┘
```

## 🔧 Testing

1. **With Photos**: Add at least one photo to test
   ```bash
   # Test with Mishary Alafasy
   cp [source_photo] assets/images/reciters/mishary_alafasy.jpg
   ```

2. **Hot Reload**: The app will automatically show the photo

3. **Fallback Test**: Remove the photo to see the initial fallback

## 📱 UI Features

✅ **56x56px Photo Display** - Perfect size for recognition
✅ **Rounded Corners** - Modern, polished look
✅ **Graceful Fallback** - Shows initials if photo missing
✅ **Selection Indicator** - Check mark for selected reciter
✅ **Responsive** - Works on all screen sizes
✅ **Error Handling** - No crashes if photo fails to load

## 🚀 Next Steps

1. Add reciter photos to `assets/images/reciters/`
2. Run `flutter pub get` (if needed)
3. Hot reload the app
4. Open Audio Settings to see the photos!

## 💡 Tips

- **Photo Quality**: Use high-resolution photos (400x400px minimum)
- **File Size**: Keep under 100KB per photo for fast loading
- **Format**: JPG is recommended for smaller file sizes
- **Consistency**: Use similar photo styles for all reciters
- **Respectful**: Only use dignified, professional photos

## 🎯 Expected Result

When you open the Audio Settings sheet, you'll see:
- Beautiful reciter photos (if available)
- Professional initials (if photos not available)
- Easy visual recognition
- Smooth, polished UI

The system is ready to go! Just add the photos and enjoy the enhanced visual experience.
