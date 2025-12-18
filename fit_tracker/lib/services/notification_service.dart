import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart';
import '../models/workout_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    initializeTimeZones();

    String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      timeZoneName = 'Asia/Almaty';
    }

    try {
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
    } catch (e) {
      try {
        final location = tz.getLocation('Asia/Almaty');
        tz.setLocalLocation(location);
      } catch (e2) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleWorkoutReminder(Workout workout) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (workout.isCompleted) return;

    try {
      final workoutTime = tz.TZDateTime.from(workout.date, tz.local);
      final reminderTime = workoutTime.subtract(const Duration(minutes: 30));

      final now = tz.TZDateTime.now(tz.local);
      if (reminderTime.isBefore(now)) {
        return;
      }

      final int notificationId = 50000 + (workout.id.hashCode % 49999).abs();

      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '💪 Workout Reminder',
        '${workout.name} starts in 30 minutes!',
        reminderTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_channel',
            'Workout Reminders',
            channelDescription: 'Reminders for scheduled workouts',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Error scheduling notification
    }
  }

  Future<void> scheduleDailyMotivation() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        8,
        0,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        99999,
        '🔥 Good Morning!',
        'Time to crush your fitness goals today!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'motivation_channel',
            'Daily Motivation',
            channelDescription: 'Daily motivational messages',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Error scheduling daily notification
    }
  }
}