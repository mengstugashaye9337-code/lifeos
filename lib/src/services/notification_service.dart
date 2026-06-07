// lib/src/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Singleton — one instance for the entire app lifetime
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Must be called before any scheduling
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      // We request permissions manually via requestPermissions()
      // Never request here — gives us control over when the prompt appears
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Requests notification permissions on both platforms.
  /// Call this at a meaningful moment — not on cold launch.
  /// Returns true if granted on either platform.
  Future<bool> requestPermissions() async {
    // Added missing '<' brackets below to fix compilation
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (androidGranted ?? false) || (iosGranted ?? false);
  }

  // ── Scheduling ────────────────────────────────────────────────────────────

  /// Schedules a one-time notification at [scheduledDate].
  /// Silent no-op if [scheduledDate] is in the past — never throws.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Never schedule in the past — would fire immediately or throw
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // absoluteTime means the exact DateTime is used, not relative
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ── Cancellation ──────────────────────────────────────────────────────────

  /// Cancels a single notification by ID.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancels ALL scheduled notifications.
  /// Use on logout or when user disables notifications in settings.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  // ── Channel config ────────────────────────────────────────────────────────

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'lifeos_core_channel',
        'LifeOS Alerts',
        channelDescription: 'Reminders for tasks, habits, and streaks.',
        importance: Importance.max,
        priority: Priority.high,
        // Shows notification immediately even in Do Not Disturb
        // Only use max importance for time-sensitive reminders
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
