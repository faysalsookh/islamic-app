import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart';
import '../models/prayer_times_data.dart';
import '../models/ramadan_settings.dart';
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
  Future<PrayerTimesData?> getTodayPrayerTimes({RamadanSettings? settings}) async {
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
      settings: settings,
    );

    if (prayerTimes != null) {
      _cachedPrayerTimes = prayerTimes;
      _cacheDate = today;
    }

    return prayerTimes;
  }

  /// Get prayer times for a specific date
  Future<PrayerTimesData?> getPrayerTimesForDate(DateTime date, {RamadanSettings? settings}) async {
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
      settings: settings,
    );
  }

  /// Generate Ramadan calendar (30 days of prayer times)
  /// Starting from the given Ramadan start date
  Future<List<PrayerTimesData>> getRamadanCalendar(
    DateTime ramadanStartDate, {
    RamadanSettings? settings,
  }) async {
    final locationResult = await _locationService.getCurrentPosition();
    
    if (locationResult.result != LocationResult.success || 
        locationResult.position == null) {
      return [];
    }

    final position = locationResult.position!;
    
    // Try fetching from API first
    try {
      final apiCalendar = await _fetchRamadanCalendarFromApi(
        latitude: position.latitude,
        longitude: position.longitude,
        ramadanStartDate: ramadanStartDate,
        settings: settings,
      );
      
      if (apiCalendar.isNotEmpty) {
        return apiCalendar;
      }
    } catch (e) {
      print('API fetch failed, falling back to local calculation: $e');
    }

    // Fallback to local calculation
    final calendar = <PrayerTimesData>[];

    // Generate 30 days
    for (int i = 0; i < 30; i++) {
        // ... (existing logic)
      final date = ramadanStartDate.add(Duration(days: i));
      final prayerTimes = _calculatePrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        date: date,
        settings: settings,
      );
      
      if (prayerTimes != null) {
        calendar.add(prayerTimes);
      }
    }

    return calendar;
  }

  /// Fetch Ramadan calendar from Aladhan API
  Future<List<PrayerTimesData>> _fetchRamadanCalendarFromApi({
    required double latitude,
    required double longitude,
    required DateTime ramadanStartDate,
    RamadanSettings? settings,
  }) async {
    final methodId = _getApiMethodId(settings?.calculationMethod);
    final month = ramadanStartDate.month;
    final year = ramadanStartDate.year;
    
    // Note: If Ramadan spans two months (which it usually does), 
    // we strictly need to fetch next month too or handle date ranges.
    // Simplifying: Fetch current month of start date. Data might be incomplete if Ramadan starts late in month.
    // Better strategy: Fetch for the specific dates involved. 
    // API allows `calendar` by month.
    
    // Fetch month 1
    final url1 = Uri.parse('http://api.aladhan.com/v1/calendar?latitude=$latitude&longitude=$longitude&method=$methodId&month=$month&year=$year');
    final response1 = await http.get(url1);
    
    List<PrayerTimesData> results = [];
    
    if (response1.statusCode == 200) {
      results.addAll(_parseApiResponse(response1.body, ramadanStartDate, latitude, longitude));
    }

    // Check if we need next month
    final ramadanEndDate = ramadanStartDate.add(const Duration(days: 30));
    if (ramadanEndDate.month != ramadanStartDate.month) {
       final url2 = Uri.parse('http://api.aladhan.com/v1/calendar?latitude=$latitude&longitude=$longitude&method=$methodId&month=${ramadanEndDate.month}&year=${ramadanEndDate.year}');
       final response2 = await http.get(url2);
       if (response2.statusCode == 200) {
         results.addAll(_parseApiResponse(response2.body, ramadanStartDate, latitude, longitude));
       }
    }

    // Filter relevant days (Ramadan only) which starts from ramadanStartDate for 30 days
    final filtered = results.where((p) => 
      !p.date.isBefore(DateUtils.dateOnly(ramadanStartDate)) && 
      p.date.isBefore(DateUtils.dateOnly(ramadanEndDate.add(const Duration(days: 1)))) 
    ).toList();
    
    // Sort to be safe
    filtered.sort((a, b) => a.date.compareTo(b.date));
    
    // If we have enough data (at least 28 days?) return it. 
    // If very few, maybe fallback or return what we have.
    // Limit to 30 days
    return filtered.take(30).toList();
  }

  List<PrayerTimesData> _parseApiResponse(String responseBody, DateTime ramadanStartDate, double lat, double lng) {
    final data = json.decode(responseBody);
    final List<dynamic> days = data['data'];
    final List<PrayerTimesData> list = [];

    for (var day in days) {
      final dateMeta = day['date'];
      final dateStr = dateMeta['gregorian']['date']; // DD-MM-YYYY
      final dateParts = dateStr.split('-');
      final date = DateTime(
        int.parse(dateParts[2]), 
        int.parse(dateParts[1]), 
        int.parse(dateParts[0])
      );

      final timings = day['timings'];
      // Parse times (e.g. "04:55 (BST)") - remove parenthesis
      DateTime parseTime(String timeStr) {
        final clean = timeStr.split(' ')[0];
        final parts = clean.split(':');
        return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
      }

      list.add(PrayerTimesData(
        date: date,
        fajr: parseTime(timings['Fajr']),
        sunrise: parseTime(timings['Sunrise']),
        dhuhr: parseTime(timings['Dhuhr']),
        asr: parseTime(timings['Asr']),
        maghrib: parseTime(timings['Maghrib']),
        isha: parseTime(timings['Isha']),
        coordinates: Coordinates(lat, lng),
      ));
    }
    return list;
  }

  int _getApiMethodId(String? methodKey) {
    switch (methodKey) {
      case 'karachi': return 1;
      case 'north_america': return 2;
      case 'muslim_world_league': return 3;
      case 'umm_al_qura': return 4;
      case 'egyptian': return 5;
      case 'dubai': return 16;
      case 'kuwait': return 9;
      case 'qatar': return 10;
      case 'singapore': return 11;
      case 'moon_sighting_committee': return 15;
      default: return 3; // Default to MWL
    }
  }

  /// Calculate prayer times for a specific location and date
  PrayerTimesData? _calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    RamadanSettings? settings,
  }) {
    try {
      final coordinates = Coordinates(latitude, longitude);
      
      // Determine calculation method (default: Muslim World League)
      final method = settings?.getCalculationMethod() ?? CalculationMethod.muslim_world_league;
      final params = method.getParameters();
      
      // Determine Madhab (default: Hanafi)
      params.madhab = settings?.getMadhab() ?? Madhab.hanafi;
      
      // Apply Adjustments if settings exist
      if (settings != null) {
        params.adjustments.fajr = settings.prayerAdjustments['fajr'] ?? 0;
        params.adjustments.dhuhr = settings.prayerAdjustments['dhuhr'] ?? 0;
        params.adjustments.asr = settings.prayerAdjustments['asr'] ?? 0;
        params.adjustments.maghrib = settings.prayerAdjustments['maghrib'] ?? 0;
        params.adjustments.isha = settings.prayerAdjustments['isha'] ?? 0;
      }
      
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
