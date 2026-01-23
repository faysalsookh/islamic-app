import 'package:adhan/adhan.dart';

/// Ramadan-specific settings model
class RamadanSettings {
  // Ramadan dates
  final DateTime? ramadanStartDate;
  final bool autoDetectRamadan;

  // Prayer calculation
  final String calculationMethod; // 'muslim_world_league', 'egyptian', etc.
  final String madhab; // 'hanafi' or 'shafi'
  final Map<String, int> prayerAdjustments; // Prayer name -> minutes adjustment

  // Notifications
  final bool sehriNotificationEnabled;
  final int sehriNotificationMinutes; // Minutes before Fajr
  final bool iftarNotificationEnabled;
  final bool taraweehReminderEnabled;
  final String notificationSound;

  // Display
  final bool use24HourFormat;
  final String translationLanguage; // 'en' or 'bn'
  final bool alwaysShowCountdown;

  // Tracker
  final bool dailyTrackerEnabled;
  final bool quranPlannerEnabled;
  final int quranReadingGoalDays; // 15, 20, or 30 days

  RamadanSettings({
    this.ramadanStartDate,
    this.autoDetectRamadan = false,
    this.calculationMethod = 'muslim_world_league',
    this.madhab = 'hanafi',
    Map<String, int>? prayerAdjustments,
    this.sehriNotificationEnabled = true,
    this.sehriNotificationMinutes = 30,
    this.iftarNotificationEnabled = true,
    this.taraweehReminderEnabled = false,
    this.notificationSound = 'default',
    this.use24HourFormat = false,
    this.translationLanguage = 'en',
    this.alwaysShowCountdown = false,
    this.dailyTrackerEnabled = true,
    this.quranPlannerEnabled = true,
    this.quranReadingGoalDays = 30,
  }) : prayerAdjustments = prayerAdjustments ?? {
          'fajr': 0,
          'dhuhr': 0,
          'asr': 0,
          'maghrib': 0,
          'isha': 0,
        };

  /// Default settings
  factory RamadanSettings.defaults() {
    return RamadanSettings(
      ramadanStartDate: DateTime(2026, 2, 17),
    );
  }

  /// Create from JSON
  factory RamadanSettings.fromJson(Map<String, dynamic> json) {
    return RamadanSettings(
      ramadanStartDate: json['ramadanStartDate'] != null
          ? DateTime.parse(json['ramadanStartDate'])
          : null,
      autoDetectRamadan: json['autoDetectRamadan'] ?? false,
      calculationMethod: json['calculationMethod'] ?? 'muslim_world_league',
      madhab: json['madhab'] ?? 'hanafi',
      prayerAdjustments: json['prayerAdjustments'] != null
          ? Map<String, int>.from(json['prayerAdjustments'])
          : null,
      sehriNotificationEnabled: json['sehriNotificationEnabled'] ?? true,
      sehriNotificationMinutes: json['sehriNotificationMinutes'] ?? 30,
      iftarNotificationEnabled: json['iftarNotificationEnabled'] ?? true,
      taraweehReminderEnabled: json['taraweehReminderEnabled'] ?? false,
      notificationSound: json['notificationSound'] ?? 'default',
      use24HourFormat: json['use24HourFormat'] ?? false,
      translationLanguage: json['translationLanguage'] ?? 'en',
      alwaysShowCountdown: json['alwaysShowCountdown'] ?? false,
      dailyTrackerEnabled: json['dailyTrackerEnabled'] ?? true,
      quranPlannerEnabled: json['quranPlannerEnabled'] ?? true,
      quranReadingGoalDays: json['quranReadingGoalDays'] ?? 30,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'ramadanStartDate': ramadanStartDate?.toIso8601String(),
      'autoDetectRamadan': autoDetectRamadan,
      'calculationMethod': calculationMethod,
      'madhab': madhab,
      'prayerAdjustments': prayerAdjustments,
      'sehriNotificationEnabled': sehriNotificationEnabled,
      'sehriNotificationMinutes': sehriNotificationMinutes,
      'iftarNotificationEnabled': iftarNotificationEnabled,
      'taraweehReminderEnabled': taraweehReminderEnabled,
      'notificationSound': notificationSound,
      'use24HourFormat': use24HourFormat,
      'translationLanguage': translationLanguage,
      'alwaysShowCountdown': alwaysShowCountdown,
      'dailyTrackerEnabled': dailyTrackerEnabled,
      'quranPlannerEnabled': quranPlannerEnabled,
      'quranReadingGoalDays': quranReadingGoalDays,
    };
  }

  /// Copy with modifications
  RamadanSettings copyWith({
    DateTime? ramadanStartDate,
    bool? autoDetectRamadan,
    String? calculationMethod,
    String? madhab,
    Map<String, int>? prayerAdjustments,
    bool? sehriNotificationEnabled,
    int? sehriNotificationMinutes,
    bool? iftarNotificationEnabled,
    bool? taraweehReminderEnabled,
    String? notificationSound,
    bool? use24HourFormat,
    String? translationLanguage,
    bool? alwaysShowCountdown,
    bool? dailyTrackerEnabled,
    bool? quranPlannerEnabled,
    int? quranReadingGoalDays,
  }) {
    return RamadanSettings(
      ramadanStartDate: ramadanStartDate ?? this.ramadanStartDate,
      autoDetectRamadan: autoDetectRamadan ?? this.autoDetectRamadan,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      prayerAdjustments: prayerAdjustments ?? this.prayerAdjustments,
      sehriNotificationEnabled: sehriNotificationEnabled ?? this.sehriNotificationEnabled,
      sehriNotificationMinutes: sehriNotificationMinutes ?? this.sehriNotificationMinutes,
      iftarNotificationEnabled: iftarNotificationEnabled ?? this.iftarNotificationEnabled,
      taraweehReminderEnabled: taraweehReminderEnabled ?? this.taraweehReminderEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      alwaysShowCountdown: alwaysShowCountdown ?? this.alwaysShowCountdown,
      dailyTrackerEnabled: dailyTrackerEnabled ?? this.dailyTrackerEnabled,
      quranPlannerEnabled: quranPlannerEnabled ?? this.quranPlannerEnabled,
      quranReadingGoalDays: quranReadingGoalDays ?? this.quranReadingGoalDays,
    );
  }

  /// Get Adhan CalculationMethod from string
  CalculationMethod getCalculationMethod() {
    switch (calculationMethod) {
      case 'egyptian':
        return CalculationMethod.egyptian;
      case 'karachi':
        return CalculationMethod.karachi;
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura;
      case 'dubai':
        return CalculationMethod.dubai;
      case 'moon_sighting_committee':
        return CalculationMethod.moon_sighting_committee;
      case 'north_america':
        return CalculationMethod.north_america;
      case 'kuwait':
        return CalculationMethod.kuwait;
      case 'qatar':
        return CalculationMethod.qatar;
      case 'singapore':
        return CalculationMethod.singapore;
      case 'muslim_world_league':
      default:
        return CalculationMethod.muslim_world_league;
    }
  }

  /// Get Adhan Madhab from string
  Madhab getMadhab() {
    return madhab == 'shafi' ? Madhab.shafi : Madhab.hanafi;
  }
}

/// Available calculation methods with display names
class CalculationMethods {
  static const Map<String, String> methods = {
    'muslim_world_league': 'Muslim World League',
    'egyptian': 'Egyptian General Authority',
    'karachi': 'University of Islamic Sciences, Karachi',
    'umm_al_qura': 'Umm Al-Qura University, Makkah',
    'dubai': 'Dubai',
    'moon_sighting_committee': 'Moonsighting Committee',
    'north_america': 'Islamic Society of North America',
    'kuwait': 'Kuwait',
    'qatar': 'Qatar',
    'singapore': 'Singapore',
  };

  static String getDisplayName(String key) {
    return methods[key] ?? key;
  }
}
