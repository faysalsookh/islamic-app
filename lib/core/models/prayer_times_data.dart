import 'package:adhan/adhan.dart';

/// Model to hold prayer times for a single day
class PrayerTimesData {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final Coordinates coordinates;

  PrayerTimesData({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.coordinates,
  });

  /// Create from Adhan PrayerTimes object
  factory PrayerTimesData.fromAdhan(PrayerTimes prayerTimes, DateTime date, Coordinates coords) {
    return PrayerTimesData(
      date: date,
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      coordinates: coords,
    );
  }

  /// Get the next prayer time from now
  DateTime? getNextPrayerTime() {
    final now = DateTime.now();
    final prayers = [fajr, sunrise, dhuhr, asr, maghrib, isha];
    
    for (final prayer in prayers) {
      if (prayer.isAfter(now)) {
        return prayer;
      }
    }
    return null; // All prayers have passed for today
  }

  /// Get the name of the next prayer
  String? getNextPrayerName() {
    final now = DateTime.now();
    if (fajr.isAfter(now)) return 'Fajr';
    if (sunrise.isAfter(now)) return 'Sunrise';
    if (dhuhr.isAfter(now)) return 'Dhuhr';
    if (asr.isAfter(now)) return 'Asr';
    if (maghrib.isAfter(now)) return 'Maghrib';
    if (isha.isAfter(now)) return 'Isha';
    return null;
  }

  /// Check if currently in Ramadan fasting period (between Fajr and Maghrib)
  bool isCurrentlyFasting() {
    final now = DateTime.now();
    return now.isAfter(fajr) && now.isBefore(maghrib);
  }

  /// Get time until Sehri ends (Fajr time)
  Duration? getTimeUntilSehriEnds() {
    final now = DateTime.now();
    if (now.isBefore(fajr)) {
      return fajr.difference(now);
    }
    return null;
  }

  /// Get time until Iftar (Maghrib time)
  Duration? getTimeUntilIftar() {
    final now = DateTime.now();
    if (now.isBefore(maghrib)) {
      return maghrib.difference(now);
    }
    return null;
  }
}
