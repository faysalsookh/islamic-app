import 'package:adhan/adhan.dart';
import '../models/prayer_times_data.dart';
import 'location_service.dart';

/// Service for calculating accurate Islamic prayer times
/// Uses the Adhan package with Muslim World League calculation method
class PrayerTimeService {
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  final LocationService _locationService = LocationService();
  
  // Cache for prayer times
  PrayerTimesData? _cachedPrayerTimes;
  DateTime? _cacheDate;

  /// Get prayer times for today
  /// Returns cached data if available and still valid
  Future<PrayerTimesData?> getTodayPrayerTimes() async {
    final today = DateTime.now();
    
    // Return cached data if it's for today
    if (_cachedPrayerTimes != null && 
        _cacheDate != null && 
        _isSameDay(_cacheDate!, today)) {
      return _cachedPrayerTimes;
    }

    // Get location
    final locationResult = await _locationService.getCurrentPosition();
    
    if (locationResult.result != LocationResult.success || 
        locationResult.position == null) {
      return null;
    }

    final position = locationResult.position!;
    
    // Calculate prayer times
    final prayerTimes = _calculatePrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      date: today,
    );

    if (prayerTimes != null) {
      _cachedPrayerTimes = prayerTimes;
      _cacheDate = today;
    }

    return prayerTimes;
  }

  /// Get prayer times for a specific date
  Future<PrayerTimesData?> getPrayerTimesForDate(DateTime date) async {
    final locationResult = await _locationService.getCurrentPosition();
    
    if (locationResult.result != LocationResult.success || 
        locationResult.position == null) {
      return null;
    }

    final position = locationResult.position!;
    
    return _calculatePrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      date: date,
    );
  }

  /// Generate Ramadan calendar (30 days of prayer times)
  /// Starting from the given Ramadan start date
  Future<List<PrayerTimesData>> getRamadanCalendar(DateTime ramadanStartDate) async {
    final locationResult = await _locationService.getCurrentPosition();
    
    if (locationResult.result != LocationResult.success || 
        locationResult.position == null) {
      return [];
    }

    final position = locationResult.position!;
    final calendar = <PrayerTimesData>[];

    // Generate 30 days
    for (int i = 0; i < 30; i++) {
      final date = ramadanStartDate.add(Duration(days: i));
      final prayerTimes = _calculatePrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        date: date,
      );
      
      if (prayerTimes != null) {
        calendar.add(prayerTimes);
      }
    }

    return calendar;
  }

  /// Calculate prayer times for a specific location and date
  PrayerTimesData? _calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    try {
      final coordinates = Coordinates(latitude, longitude);
      
      // Use Muslim World League calculation method
      // This is widely accepted and used in most Muslim countries
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.hanafi; // You can make this configurable
      
      final prayerTimes = PrayerTimes.today(coordinates, params);
      
      return PrayerTimesData.fromAdhan(prayerTimes, date, coordinates);
    } catch (e) {
      print('Error calculating prayer times: $e');
      return null;
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Clear cache (useful when location changes)
  void clearCache() {
    _cachedPrayerTimes = null;
    _cacheDate = null;
  }

  /// Get Qibla direction (already available in location, but included for completeness)
  /// Returns the direction in degrees from North
  double? getQiblaDirection(double latitude, double longitude) {
    try {
      final coordinates = Coordinates(latitude, longitude);
      return Qibla(coordinates).direction;
    } catch (e) {
      print('Error calculating Qibla direction: $e');
      return null;
    }
  }
}
