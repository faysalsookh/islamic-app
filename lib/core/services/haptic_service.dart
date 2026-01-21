import 'package:flutter/services.dart';

/// Service to handle haptic feedback throughout the app
class HapticService {
  HapticService._();
  static final HapticService _instance = HapticService._();
  factory HapticService() => _instance;

  /// Light impact - for button taps, selections
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact - for important actions like bookmarking
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for significant events like completing a surah
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - for tab changes, list selections
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate - for error states or important alerts
  Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
