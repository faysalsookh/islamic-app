import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zakat_data.dart';

class ZakatProvider with ChangeNotifier {
  static const String _storageKey = 'zakat_data_v1';
  
  // Standard Nisab Thresholds (Grams)
  static const double NISAB_GOLD_GRAMS = 87.48;
  static const double NISAB_SILVER_GRAMS = 612.36;

  ZakatData _data = ZakatData();
  bool _isLoading = true;

  ZakatData get data => _data;
  bool get isLoading => _isLoading;

  // Calculators
  double get totalGoldValue => _data.goldGrams * _data.goldPricePerGram;
  double get totalSilverValue => _data.silverGrams * _data.silverPricePerGram;
  
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
    double? goldGrams,
    double? silverGrams,
    double? investments,
    double? propertyForTrade,
    double? otherSavings,
    double? liablities,
    double? goldPricePerGram,
    double? silverPricePerGram,
    bool? useSilverNisab,
  }) {
    _data = _data.copyWith(
      cashInHand: cashInHand,
      cashInBank: cashInBank,
      goldGrams: goldGrams,
      silverGrams: silverGrams,
      investments: investments,
      propertyForTrade: propertyForTrade,
      otherSavings: otherSavings,
      liablities: liablities,
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
      useSilverNisab: useSilverNisab,
    );
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
