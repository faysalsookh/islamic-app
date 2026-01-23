# 🌙 Ramadan Feature Phase 3: Zakat & Audio

## 🎯 Objectives
1.  **Zakat Calculator**: Implement a comprehensive calculator to determine Zakat eligibility and payable amount.
2.  **Audio Integration**: Add audio playback functionality for Ramadan Duas using `just_audio`.
3.  **Final Polish**: Ensure all Ramadan features (Phase 1, 2, & 3) work seamlessly together.

---

## 🏗️ Feature 1: Zakat Calculator

### 1. Data Model (`DailyTrackerData` ... wait, separate simple model)
- Create `ZakatParams` or `ZakatState` model.
- **Fields**:
  - `goldGrams`: double (Weight of gold owned)
  - `silverGrams`: double (Weight of silver owned)
  - `cashInHand`: double
  - `bankBalance`: double
  - `investments`: double (Stocks, bonds, etc.)
  - `inventory`: double (Business merchandise)
  - `liabilities`: double (Debts due immediately)
  - `currency`: String (e.g., USD, BDT - purely for display or conversion if we get ambitious)
  - `nisabStandard`: Enum (Gold/Silver - Silver is safer/more common for caution)

### 2. Logic & Provider (`ZakatProvider`)
- **Constants**:
  - `NISAB_GOLD_GRAMS` = 87.48 (approx)
  - `NISAB_SILVER_GRAMS` = 612.36 (approx)
- **Methods**:
  - `calculateNetAssets()`
  - `calculateNisabThreshold(goldPrice, silverPrice)`
    - *Note*: We might need user input for current Gold/Silver prices per gram as fetching live data might be complex without an API key, or we can use a hardcoded default with an edit option. **Plan: Ask user for current Gold/Silver price.**
  - `isEligible()`: netAssets >= nisab
  - `calculateZakat()`: 2.5% of netAssets

### 3. UI Implementation
- **Page**: `ZakatCalculatorPage`
- **Route**: `/zakat-calculator`
- **Widgets**:
  - Input fields for all assets.
  - Input fields for Current Gold/Silver Price (essential for accurate Nisab).
  - "Calculate" button.
  - Result Card:
    - Total Assets.
    - Nisab Threshold (and if met).
    - **Total Zakat Payable**.

---

## 🔊 Feature 2: Audio Playback

### 1. Service Update
- Enhance `RamadanDuasPage`.
- Use `just_audio` (already in pubspec).
- Add `playDuaAudio(String duaId)` method.
- **Assets**: 
  - Since we can't easily add heavy assets, we will:
    - Option A: Use URL streams if available.
    - Option B: Create the infrastructure and UI (Play buttons) and mock the playback or handle "Asset not found" gracefully.
    - *Decision*: We will implement the UI and logic. If we have URLs, we use them. If not, we'll placeholder it for the user to add assets later.
- **UI Changes**:
  - Add Play/Pause icon button to each Dua card.
  - Show progress indicator when playing.

---

## 📝 Implementation Steps

### Step 1: Zakat Calculator Logic
1. Create `lib/core/models/zakat_data.dart`.
2. Create `lib/core/providers/zakat_provider.dart` with logic.
3. Register provider in `main.dart`.

### Step 2: Zakat Calculator UI
1. Create `lib/features/ramadan/presentation/pages/zakat_calculator_page.dart`.
2. Add route and access point (e.g., from `RamadanCalendarPage` or Home).

### Step 3: Dua Audio
1. Update `RamadanDuasPage` to include `AudioPlayer` logic.
2. Add Play buttons to Dua cards.

---

## ✅ Success Criteria
- [ ] Users can input assets and see correct Zakat amount (2.5%).
- [ ] Users can adjust Gold/Silver prices for accurate Nisab.
- [ ] Zakat result clearly explains *why* (e.g., "Your assets exceed the Nisab threshold").
- [ ] Dua cards have playable audio controls (even if audio is placeholder).
