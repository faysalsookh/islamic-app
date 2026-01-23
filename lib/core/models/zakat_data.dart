/// Supported currencies for Zakat calculation
enum ZakatCurrency {
  usd('USD', '\$', 'US Dollar'),
  bdt('BDT', '৳', 'Bangladeshi Taka'),
  sar('SAR', '﷼', 'Saudi Riyal'),
  aed('AED', 'د.إ', 'UAE Dirham'),
  gbp('GBP', '£', 'British Pound'),
  eur('EUR', '€', 'Euro'),
  inr('INR', '₹', 'Indian Rupee'),
  pkr('PKR', '₨', 'Pakistani Rupee'),
  myr('MYR', 'RM', 'Malaysian Ringgit'),
  idr('IDR', 'Rp', 'Indonesian Rupiah');

  final String code;
  final String symbol;
  final String name;

  const ZakatCurrency(this.code, this.symbol, this.name);

  static ZakatCurrency fromCode(String code) {
    return ZakatCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => ZakatCurrency.usd,
    );
  }
}

/// Supported weight units for gold/silver measurement
enum WeightUnit {
  gram('g', 'Gram', 'গ্রাম', 1.0),
  bhori('ভরি', 'Bhori', 'ভরি', 11.664); // 1 Bhori = 11.664 grams

  final String symbol;
  final String name;
  final String nameBangla;
  final double toGramsFactor; // Multiply by this to convert to grams

  const WeightUnit(this.symbol, this.name, this.nameBangla, this.toGramsFactor);

  /// Convert a value from this unit to grams
  double toGrams(double value) => value * toGramsFactor;

  /// Convert a value from grams to this unit
  double fromGrams(double grams) => grams / toGramsFactor;

  static WeightUnit fromName(String name) {
    return WeightUnit.values.firstWhere(
      (u) => u.name == name,
      orElse: () => WeightUnit.gram,
    );
  }
}

class ZakatData {
  // Asset Values
  final double cashInHand;
  final double cashInBank;
  final double goldWeight; // In selected weight unit (gram or bhori)
  final double silverWeight; // In selected weight unit (gram or bhori)
  final double investments; // Stocks, mutual funds, etc.
  final double propertyForTrade; // Real estate bought for resale
  final double otherSavings;

  // Liabilities
  final double liablities; // Debts due immediately

  // Prices (User inputs) - per selected weight unit
  final double goldPricePerUnit;
  final double silverPricePerUnit;

  // Settings
  final bool useSilverNisab; // Standard: Silver is safer (lower threshold), Gold is optional
  final ZakatCurrency currency; // Selected currency
  final WeightUnit weightUnit; // Selected weight unit (gram or bhori)

  ZakatData({
    this.cashInHand = 0.0,
    this.cashInBank = 0.0,
    this.goldWeight = 0.0,
    this.silverWeight = 0.0,
    this.investments = 0.0,
    this.propertyForTrade = 0.0,
    this.otherSavings = 0.0,
    this.liablities = 0.0,
    this.goldPricePerUnit = 0.0,
    this.silverPricePerUnit = 0.0,
    this.useSilverNisab = true,
    this.currency = ZakatCurrency.usd,
    this.weightUnit = WeightUnit.gram,
  });

  // Helper getters for calculations (always in grams)
  double get goldGrams => weightUnit.toGrams(goldWeight);
  double get silverGrams => weightUnit.toGrams(silverWeight);
  double get goldPricePerGram => goldPricePerUnit / weightUnit.toGramsFactor;
  double get silverPricePerGram => silverPricePerUnit / weightUnit.toGramsFactor;

  // CopyWith for immutability
  ZakatData copyWith({
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
    return ZakatData(
      cashInHand: cashInHand ?? this.cashInHand,
      cashInBank: cashInBank ?? this.cashInBank,
      goldWeight: goldWeight ?? this.goldWeight,
      silverWeight: silverWeight ?? this.silverWeight,
      investments: investments ?? this.investments,
      propertyForTrade: propertyForTrade ?? this.propertyForTrade,
      otherSavings: otherSavings ?? this.otherSavings,
      liablities: liablities ?? this.liablities,
      goldPricePerUnit: goldPricePerUnit ?? this.goldPricePerUnit,
      silverPricePerUnit: silverPricePerUnit ?? this.silverPricePerUnit,
      useSilverNisab: useSilverNisab ?? this.useSilverNisab,
      currency: currency ?? this.currency,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  // To/From JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'cashInHand': cashInHand,
      'cashInBank': cashInBank,
      'goldWeight': goldWeight,
      'silverWeight': silverWeight,
      'investments': investments,
      'propertyForTrade': propertyForTrade,
      'otherSavings': otherSavings,
      'liablities': liablities,
      'goldPricePerUnit': goldPricePerUnit,
      'silverPricePerUnit': silverPricePerUnit,
      'useSilverNisab': useSilverNisab,
      'currency': currency.code,
      'weightUnit': weightUnit.name,
    };
  }

  factory ZakatData.fromJson(Map<String, dynamic> json) {
    return ZakatData(
      cashInHand: (json['cashInHand'] as num?)?.toDouble() ?? 0.0,
      cashInBank: (json['cashInBank'] as num?)?.toDouble() ?? 0.0,
      goldWeight: (json['goldWeight'] as num?)?.toDouble() ??
          (json['goldGrams'] as num?)?.toDouble() ?? 0.0, // Backward compat
      silverWeight: (json['silverWeight'] as num?)?.toDouble() ??
          (json['silverGrams'] as num?)?.toDouble() ?? 0.0, // Backward compat
      investments: (json['investments'] as num?)?.toDouble() ?? 0.0,
      propertyForTrade: (json['propertyForTrade'] as num?)?.toDouble() ?? 0.0,
      otherSavings: (json['otherSavings'] as num?)?.toDouble() ?? 0.0,
      liablities: (json['liablities'] as num?)?.toDouble() ?? 0.0,
      goldPricePerUnit: (json['goldPricePerUnit'] as num?)?.toDouble() ??
          (json['goldPricePerGram'] as num?)?.toDouble() ?? 0.0, // Backward compat
      silverPricePerUnit: (json['silverPricePerUnit'] as num?)?.toDouble() ??
          (json['silverPricePerGram'] as num?)?.toDouble() ?? 0.0, // Backward compat
      useSilverNisab: json['useSilverNisab'] as bool? ?? true,
      currency: ZakatCurrency.fromCode(json['currency'] as String? ?? 'USD'),
      weightUnit: WeightUnit.fromName(json['weightUnit'] as String? ?? 'Gram'),
    );
  }
}
