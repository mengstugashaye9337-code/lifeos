import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifeos/src/services/notification_provider.dart';

// Key used to track if we've already requested permissions
const _kPermissionAskedKey = 'notification_permission_asked';

/// Call this once from the home screen on first render.
/// Handles both notification permission and exact alarms on Android 12+.
Future<void> requestNotificationPermissionsIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  final prefs = await SharedPreferences.getInstance();

  // Never ask twice
  final alreadyAsked = prefs.getBool(_kPermissionAskedKey) ?? false;
  if (alreadyAsked) return;

  await prefs.setBool(_kPermissionAskedKey, true);

  final notifier = ref.read(notificationProvider.notifier);

  // Step 1 — request basic notification permission
  final granted = await notifier.requestPermissions();
  if (!granted) return; // user denied — don't push further

  // Step 2 — Android 12+ exact alarms check
  final canSchedule = await notifier.canScheduleExactAlarms();
  if (canSchedule) return; // already granted — nothing to do

  // Step 3 — Show explanation dialog before opening settings
  if (!context.mounted) return;

  final shouldOpen = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enable Exact Reminders'),
      content: const Text(
        'To deliver task and habit reminders at the exact right time, '
        'LifeOS needs permission to schedule precise alarms.\n\n'
        'Tap "Allow" to enable this in your device settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Allow'),
        ),
      ],
    ),
  );

  if (shouldOpen == true) {
    await notifier.requestExactAlarmsPermission();
  }
}
