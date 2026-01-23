import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zakat_data.dart';

class ZakatProvider with ChangeNotifier {
  static const String _storageKey = 'zakat_data_v2';

  // Standard Nisab Thresholds (Grams)
  static const double NISAB_GOLD_GRAMS = 87.48;
  static const double NISAB_SILVER_GRAMS = 612.36;

  ZakatData _data = ZakatData();
  bool _isLoading = true;

  ZakatData get data => _data;
  bool get isLoading => _isLoading;

  // Currency helper
  String get currencySymbol => _data.currency.symbol;
  ZakatCurrency get currency => _data.currency;

  // Weight unit helper
  WeightUnit get weightUnit => _data.weightUnit;
  String get weightUnitSymbol => _data.weightUnit.symbol;

  // Calculators (using grams internally via ZakatData getters)
  double get totalGoldValue => _data.goldWeight * _data.goldPricePerUnit;
  double get totalSilverValue => _data.silverWeight * _data.silverPricePerUnit;
  
  double get totalCashAssets => 
      _data.cashInHand + 
      _data.cashInBank + 
      _data.investments + 
      _data.propertyForTrade + 
      _data.otherSavings;

  double get totalAssetsValue => totalCashAssets + totalGoldValue + totalSilverValue;
  
  double get netAssetsValue => totalAssetsValue - _data.liablities;

  double get nisabThreshold {
    if (_data.useSilverNisab) {
      return NISAB_SILVER_GRAMS * _data.silverPricePerGram;
    } else {
      return NISAB_GOLD_GRAMS * _data.goldPricePerGram;
    }
  }

  bool get isEligible {
    // If prices are 0, we can't calculate properly, consider eligible if net assets > 0 as a fallback or return false?
    // Better: If prices are 0, Nisab is 0, so any assets make you eligible. 
    // Ideally user MUST enter prices.
    if (nisabThreshold <= 0) return false;
    return netAssetsValue >= nisabThreshold;
  }

  double get zakatPayable {
    if (!isEligible) return 0.0;
    return netAssetsValue * 0.025;
  }

  // Initialization
  Future<void> initialize() async {
    await _loadData();
  }

  // Methods to Update Data
  void updateData({
    double? cashInHand,
    double? cashInBank,
    double? goldWeight,
    double? silverWeight,
    double? investments,
    double? propertyForTrade,
    double? otherSavings,
    double? liablities,
    double? goldPricePerUnit,
    double? silverPricePerUnit,
    bool? useSilverNisab,
    ZakatCurrency? currency,
    WeightUnit? weightUnit,
  }) {
    _data = _data.copyWith(
      cashInHand: cashInHand,
      cashInBank: cashInBank,
      goldWeight: goldWeight,
      silverWeight: silverWeight,
      investments: investments,
      propertyForTrade: propertyForTrade,
      otherSavings: otherSavings,
      liablities: liablities,
      goldPricePerUnit: goldPricePerUnit,
      silverPricePerUnit: silverPricePerUnit,
      useSilverNisab: useSilverNisab,
      currency: currency,
      weightUnit: weightUnit,
    );
    notifyListeners();
    _saveData();
  }

  // Update currency only
  void setCurrency(ZakatCurrency currency) {
    _data = _data.copyWith(currency: currency);
    notifyListeners();
    _saveData();
  }

  // Update weight unit only
  void setWeightUnit(WeightUnit unit) {
    _data = _data.copyWith(weightUnit: unit);
    notifyListeners();
    _saveData();
  }

  // Persistence
  Future<void> _loadData() async {
    _isLoading = true;
    // notifyListeners(); // Avoid rebuilds during init if possible, or move carefully
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        _data = ZakatData.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('Error loading Zakat data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = json.encode(_data.toJson());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving Zakat data: $e');
    }
  }

  // Reset
  Future<void> resetData() async {
    _data = ZakatData(); // Reset to defaults
    await _saveData();
    notifyListeners();
  }
}
