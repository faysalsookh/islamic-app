import '../models/prayer_times_data.dart';
import '../models/ramadan_settings.dart';
import 'notification_service.dart';
import 'package:intl/intl.dart';

/// Service for scheduling Ramadan-specific notifications
class RamadanNotificationScheduler {
  final NotificationService _notificationService = NotificationService();

  /// Schedule all Ramadan notifications for today
  Future<void> scheduleNotificationsForToday({
    required PrayerTimesData prayerTimes,
    required RamadanSettings settings,
    required int ramadanDay,
  }) async {
    // Cancel existing notifications
    await cancelAllRamadanNotifications();

    // Schedule Sehri notification
    if (settings.sehriNotificationEnabled) {
      await _scheduleSehriNotification(
        prayerTimes: prayerTimes,
        minutesBefore: settings.sehriNotificationMinutes,
        ramadanDay: ramadanDay,
      );
    }

    // Schedule Iftar notification
    if (settings.iftarNotificationEnabled) {
      await _scheduleIftarNotification(
        prayerTimes: prayerTimes,
        ramadanDay: ramadanDay,
      );
    }

    // Schedule Taraweeh reminder
    if (settings.taraweehReminderEnabled) {
      await _scheduleTaraweehReminder(
        prayerTimes: prayerTimes,
        ramadanDay: ramadanDay,
      );
    }

    // Schedule Dua reminder (10 minutes before Maghrib)
    await _scheduleDuaReminder(
      prayerTimes: prayerTimes,
      ramadanDay: ramadanDay,
    );
  }

  /// Schedule Sehri (pre-dawn meal) notification
  Future<void> _scheduleSehriNotification({
    required PrayerTimesData prayerTimes,
    required int minutesBefore,
    required int ramadanDay,
  }) async {
    final notificationTime = prayerTimes.fajr.subtract(
      Duration(minutes: minutesBefore),
    );

    // Only schedule if time hasn't passed
    if (notificationTime.isAfter(DateTime.now())) {
      final fajrTime = DateFormat('h:mm a').format(prayerTimes.fajr);
      final timeRemaining = prayerTimes.fajr.difference(notificationTime);
      
      await _notificationService.scheduleNotification(
        id: NotificationIds.sehriAlarm,
        title: '🌙 Time for Sehri!',
        body: 'Sehri ends at $fajrTime - ${timeRemaining.inMinutes} minutes remaining',
        scheduledTime: notificationTime,
        payload: 'sehri_day_$ramadanDay',
      );
    }
  }

  /// Schedule Iftar (breaking fast) notification
  Future<void> _scheduleIftarNotification({
    required PrayerTimesData prayerTimes,
    required int ramadanDay,
  }) async {
    // Schedule exactly at Maghrib time
    if (prayerTimes.maghrib.isAfter(DateTime.now())) {
      final maghribTime = DateFormat('h:mm a').format(prayerTimes.maghrib);
      
      await _notificationService.scheduleNotification(
        id: NotificationIds.iftarAlert,
        title: '🌅 Time to Break Your Fast!',
        body: 'Maghrib has entered at $maghribTime. May Allah accept your fast.',
        scheduledTime: prayerTimes.maghrib,
        payload: 'iftar_day_$ramadanDay',
      );
    }
  }

  /// Schedule Taraweeh reminder (30 minutes after Isha)
  Future<void> _scheduleTaraweehReminder({
    required PrayerTimesData prayerTimes,
    required int ramadanDay,
  }) async {
    final reminderTime = prayerTimes.isha.add(const Duration(minutes: 30));

    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: NotificationIds.taraweehReminder,
        title: '🕌 Time for Taraweeh',
        body: 'Don\'t forget to pray Taraweeh tonight!',
        scheduledTime: reminderTime,
        payload: 'taraweeh_day_$ramadanDay',
      );
    }
  }

  /// Schedule Dua reminder (10 minutes before Maghrib - best time for dua)
  Future<void> _scheduleDuaReminder({
    required PrayerTimesData prayerTimes,
    required int ramadanDay,
  }) async {
    final reminderTime = prayerTimes.maghrib.subtract(
      const Duration(minutes: 10),
    );

    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: NotificationIds.duaReminder,
        title: '🤲 Best Time for Dua',
        body: 'The time before Iftar is special - make your duas now!',
        scheduledTime: reminderTime,
        payload: 'dua_day_$ramadanDay',
      );
    }
  }

  /// Schedule Quran reading reminder
  Future<void> scheduleQuranReadingReminder({
    required int hour,
    required int minute,
    required int pagesRemaining,
  }) async {
    await _notificationService.scheduleDailyNotification(
      id: NotificationIds.quranReadingReminder,
      title: '📖 Time to Read Quran',
      body: 'You have $pagesRemaining pages remaining to reach your goal',
      hour: hour,
      minute: minute,
      payload: 'quran_reading',
    );
  }

  /// Cancel all Ramadan notifications
  Future<void> cancelAllRamadanNotifications() async {
    await _notificationService.cancelNotification(NotificationIds.sehriAlarm);
    await _notificationService.cancelNotification(NotificationIds.iftarAlert);
    await _notificationService.cancelNotification(NotificationIds.taraweehReminder);
    await _notificationService.cancelNotification(NotificationIds.duaReminder);
  }

  /// Cancel Quran reading reminder
  Future<void> cancelQuranReadingReminder() async {
    await _notificationService.cancelNotification(NotificationIds.quranReadingReminder);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Show test notification
  Future<void> showTestNotification() async {
    await _notificationService.showNotification(
      id: 999,
      title: '✅ Notifications Working!',
      body: 'You will receive Ramadan reminders at the scheduled times.',
      payload: 'test',
    );
  }
}
