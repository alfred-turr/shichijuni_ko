import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../models/micro_season.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    debugPrint('NOTIFICATION SERVICE INIT START');
    tz.initializeTimeZones();

    final String currentTimeZone =
        await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(currentTimeZone),
    );

     debugPrint('TZ LOCAL AFTER SET: ${tz.local.name}');

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    await _requestPermissions();
  }

    Future<void> showScheduledTestNotification() async {
      debugPrint('TEST SCHEDULE START');

      final scheduledDate = tz.TZDateTime.now(tz.local).add(
        const Duration(minutes: 1),
      );

      debugPrint('NOW: ${tz.TZDateTime.now(tz.local)}');
      debugPrint('SCHEDULED FOR: $scheduledDate');

      const androidDetails = AndroidNotificationDetails(
        'micro_seasons_channel',
        'Micro seasons',
        channelDescription: 'Notifications for Japanese micro-season changes',
        importance: Importance.high,
        priority: Priority.high,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.zonedSchedule(

        
        998,
        'Scheduled test',
        'This notification was scheduled 1 minute ago.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled test notification at: $scheduledDate');
    }

    

  Future<void> showTestNotification() async {
    debugPrint('TEST SCHEDULE START');
    const androidDetails = AndroidNotificationDetails(
      'micro_seasons_channel',
      'Micro seasons',
      channelDescription: 'Notifications for Japanese micro-season changes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'Test notification',
      'Japanese micro-season notification is working.',
      details,
    );
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    }

    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> rescheduleAll(List<MicroSeason> seasons) async {
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool('notificationsEnabled') ?? true;
    final hour = prefs.getInt('notificationHour') ?? 8;
    final minute = prefs.getInt('notificationMinute') ?? 0;

    await _notifications.cancelAll();

    if (!enabled) return;

    for (final season in seasons) {
      final scheduledDate = _nextDateForMmdd(
        season.startDate,
        hour,
        minute,
      );

      await _scheduleSeasonNotification(
        id: season.id,
        date: scheduledDate,
        season: season,
      );
    }
  }

  Future<void> _scheduleSeasonNotification({
    required int id,
    required tz.TZDateTime date,
    required MicroSeason season,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'micro_seasons_channel',
      'Micro seasons',
      channelDescription: 'Notifications for Japanese micro-season changes',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'New micro-season: ${season.englishName}',
      '${season.japaneseName} · ${season.romaji}',
      date,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: season.id.toString(),
    );
  }

  tz.TZDateTime _nextDateForMmdd(
    String mmdd,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);

    final month = int.parse(mmdd.substring(0, 2));
    final day = int.parse(mmdd.substring(2, 4));

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      month,
      day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year + 1,
        month,
        day,
        hour,
        minute,
      );
    }

    return scheduled;
  }

  Future<void> disableNotifications() async {
    await _notifications.cancelAll();
  }
}