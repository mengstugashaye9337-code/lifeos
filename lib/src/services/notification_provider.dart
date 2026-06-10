// lib/src/services/notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/services/notification_service.dart';

part 'notification_provider.g.dart';

// ---------------------------------------------------------------------------
// NotificationService provider — singleton, keepAlive
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService.instance;
}

// ---------------------------------------------------------------------------
// Notification ID zones — single source of truth
// ---------------------------------------------------------------------------

abstract class NotificationIds {
  static int forTask(int taskId) {
    assert(
      taskId >= 0 && taskId <= 999,
      'Task ID $taskId is out of notification range (0–999)',
    );
    return taskId;
  }

  static int forHabit(int habitId) {
    assert(
      habitId >= 0 && habitId <= 999,
      'Habit ID $habitId is out of notification range (1000–1999)',
    );
    return 1000 + habitId;
  }

  static const int dailyHabitSummary = 9000;
  static const int overdueTaskSummary = 9001;
  static const int streakBreakWarning = 9002;
}

// ---------------------------------------------------------------------------
// NotificationNotifier — reactive bridge for feature controllers
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
class NotificationNotifier extends _$NotificationNotifier {
  @override
  FutureOr<void> build() async {
    await ref.read(notificationServiceProvider).initialize();
  }

  NotificationService get _service => ref.read(notificationServiceProvider);

  // ── Permission ────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    return _service.requestPermissions();
  }

  Future<void> cancelNotificationById(int id) async {
    await _service.cancelNotification(id);
  }

  /// Android 12+ requires a separate exact alarms permission.
  Future<bool> canScheduleExactAlarms() async {
    if (!defaultTargetPlatform.isAndroid) return true;

    final plugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await plugin?.canScheduleExactNotifications() ?? false;
  }

  /// ✅ FIX: Native plugin implementation. No android_intent package required!
  Future<void> requestExactAlarmsPermission() async {
    if (!defaultTargetPlatform.isAndroid) return;

    final plugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // This calls the OS natively to request permission or open settings
    await plugin?.requestExactAlarmsPermission();
  }

  // ── Task notifications ────────────────────────────────────────────────────

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String taskTitle,
    required DateTime? dueDate,
  }) async {
    if (dueDate == null) return;

    final reminderTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9, // 9:00 AM
    );

    await _service.scheduleNotification(
      id: NotificationIds.forTask(taskId),
      title: 'Task due today',
      body: taskTitle,
      scheduledDate: reminderTime,
      payload: 'task:$taskId',
    );
  }

  Future<void> cancelTaskReminder(int taskId) async {
    await _service.cancelNotification(NotificationIds.forTask(taskId));
  }

  // ── Habit notifications ───────────────────────────────────────────────────

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitTitle,
    int hour = 8,
    int minute = 0,
  }) async {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);

    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    await _service.scheduleNotification(
      id: NotificationIds.forHabit(habitId),
      title: 'Habit reminder 🔔',
      body: habitTitle,
      scheduledDate: target,
      payload: 'habit:$habitId',
    );
  }

  Future<void> scheduleStreakWarning({
    required int habitId,
    required String habitTitle,
    required int currentStreak,
  }) async {
    if (currentStreak == 0) return;

    final now = DateTime.now();
    final warning = DateTime(now.year, now.month, now.day, 21); // 9:00 PM

    if (warning.isBefore(now)) return;

    await _service.scheduleNotification(
      id: NotificationIds.streakBreakWarning,
      title: 'Don\'t break your streak 🔥',
      body: '$habitTitle — $currentStreak day streak at risk!',
      scheduledDate: warning,
      payload: 'habit:$habitId',
    );
  }

  Future<void> cancelHabitReminder(int habitId) async {
    await _service.cancelNotification(NotificationIds.forHabit(habitId));
  }

  // ── Global summaries ─────────────────────────────────────────────────────

  Future<void> scheduleDailyHabitSummary({
    required int habitCount,
    int hour = 7,
    int minute = 0,
  }) async {
    if (habitCount == 0) return;

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    await _service.scheduleNotification(
      id: NotificationIds.dailyHabitSummary,
      title: 'Good morning 🌅',
      body:
          'You have $habitCount habit${habitCount == 1 ? '' : 's'} to complete today.',
      scheduledDate: target,
      payload: 'summary:habits',
    );
  }

  Future<void> scheduleOverdueTasksSummary({required int overdueCount}) async {
    if (overdueCount == 0) {
      await _service.cancelNotification(NotificationIds.overdueTaskSummary);
      return;
    }

    final target = DateTime.now().add(const Duration(seconds: 5));

    await _service.scheduleNotification(
      id: NotificationIds.overdueTaskSummary,
      title: 'Overdue tasks ⚠️',
      body:
          'You have $overdueCount overdue task${overdueCount == 1 ? '' : 's'}.',
      scheduledDate: target,
      payload: 'summary:tasks',
    );
  }
}

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
