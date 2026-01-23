
class ZakatData {
  // Asset Values
  final double cashInHand;
  final double cashInBank;
  final double goldGrams;
  final double silverGrams;
  final double investments; // Stocks, mutual funds, etc.
  final double propertyForTrade; // Real estate bought for resale
  final double otherSavings;
  
  // Liabilities
  final double liablities; // Debts due immediately

  // Prices (User inputs)
  final double goldPricePerGram;
  final double silverPricePerGram;
  
  // Settings
  final bool useSilverNisab; // Standard: Silver is safer (lower threshold), Gold is optional

  ZakatData({
    this.cashInHand = 0.0,
    this.cashInBank = 0.0,
    this.goldGrams = 0.0,
    this.silverGrams = 0.0,
    this.investments = 0.0,
    this.propertyForTrade = 0.0,
    this.otherSavings = 0.0,
    this.liablities = 0.0,
    this.goldPricePerGram = 0.0,
    this.silverPricePerGram = 0.0,
    this.useSilverNisab = true, 
  });

  // CopyWith for immutability
  ZakatData copyWith({
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
    return ZakatData(
      cashInHand: cashInHand ?? this.cashInHand,
      cashInBank: cashInBank ?? this.cashInBank,
      goldGrams: goldGrams ?? this.goldGrams,
      silverGrams: silverGrams ?? this.silverGrams,
      investments: investments ?? this.investments,
      propertyForTrade: propertyForTrade ?? this.propertyForTrade,
      otherSavings: otherSavings ?? this.otherSavings,
      liablities: liablities ?? this.liablities,
      goldPricePerGram: goldPricePerGram ?? this.goldPricePerGram,
      silverPricePerGram: silverPricePerGram ?? this.silverPricePerGram,
      useSilverNisab: useSilverNisab ?? this.useSilverNisab,
    );
  }

  // To/From JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'cashInHand': cashInHand,
      'cashInBank': cashInBank,
      'goldGrams': goldGrams,
      'silverGrams': silverGrams,
      'investments': investments,
      'propertyForTrade': propertyForTrade,
      'otherSavings': otherSavings,
      'liablities': liablities,
      'goldPricePerGram': goldPricePerGram,
      'silverPricePerGram': silverPricePerGram,
      'useSilverNisab': useSilverNisab,
    };
  }

  factory ZakatData.fromJson(Map<String, dynamic> json) {
    return ZakatData(
      cashInHand: (json['cashInHand'] as num?)?.toDouble() ?? 0.0,
      cashInBank: (json['cashInBank'] as num?)?.toDouble() ?? 0.0,
      goldGrams: (json['goldGrams'] as num?)?.toDouble() ?? 0.0,
      silverGrams: (json['silverGrams'] as num?)?.toDouble() ?? 0.0,
      investments: (json['investments'] as num?)?.toDouble() ?? 0.0,
      propertyForTrade: (json['propertyForTrade'] as num?)?.toDouble() ?? 0.0,
      otherSavings: (json['otherSavings'] as num?)?.toDouble() ?? 0.0,
      liablities: (json['liablities'] as num?)?.toDouble() ?? 0.0,
      goldPricePerGram: (json['goldPricePerGram'] as num?)?.toDouble() ?? 0.0,
      silverPricePerGram: (json['silverPricePerGram'] as num?)?.toDouble() ?? 0.0,
      useSilverNisab: json['useSilverNisab'] as bool? ?? true,
    );
  }
}
