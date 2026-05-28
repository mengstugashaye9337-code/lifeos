// Utility functions
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Date Formatting
// ---------------------------------------------------------------------------

/// Returns a format like "Oct 24"
String formatShortDate(DateTime date) => DateFormat('MMM d').format(date);

/// Returns a format like "Thu, Oct 24 2026"
String formatFullDate(DateTime date) =>
    DateFormat('EEE, MMM d yyyy').format(date);

// ---------------------------------------------------------------------------
// Due Date Status Colors
// ---------------------------------------------------------------------------

Color dueDateColor({
  required DateTime dueDate,
  required bool isCompleted,
  required BuildContext context,
}) {
  if (isCompleted) return Theme.of(context).colorScheme.outline;

  final now = DateTime.now();
  // Normalize dates to midnight to prevent hourly calculation bugs
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

  if (targetDate.isBefore(today)) {
    return Colors.red.shade400; // Overdue
  }
  if (targetDate.isAtSameMomentAs(today) ||
      targetDate.difference(today).inDays == 1) {
    return Colors.orange.shade400; // Today or Tomorrow urgent window
  }

  return Theme.of(context).colorScheme.outline; // Future task
}

// ---------------------------------------------------------------------------
// Task Priority Styling Helper
// ---------------------------------------------------------------------------

/// Maps database priority integers directly to Material Colors
Color getPriorityColor(int priority) {
  switch (priority) {
    case 3: // High Priority
      return Colors.red.shade400;
    case 2: // Medium Priority
      return Colors.amber.shade600;
    case 1: // Low Priority
      return Colors.blue.shade400;
    default:
      return Colors.grey.shade400;
  }
}
