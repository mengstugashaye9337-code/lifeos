import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/src/core/utils/utils.dart';
import 'package:lifeos/src/features/tasks/application/task_ai_bridge.dart';
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/features/tasks/domain/task_model.dart';
import 'package:lifeos/src/features/tasks/presentation/widgets/task_form_sheet.dart';

class TaskTile extends ConsumerWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = getPriorityColor(task.priority.toDbValue());

    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) =>
            ref.read(tasksStateProvider.notifier).toggleTask(task),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? colorScheme.outline : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.description != null && task.description!.isNotEmpty)
            Text(
              task.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityColor, width: 0.8),
                ),
                child: Text(
                  task.priority.label,
                  style: TextStyle(fontSize: 11, color: priorityColor),
                ),
              ),
              if (task.dueDate != null)
                Text(
                  formatShortDate(task.dueDate!),
                  style: TextStyle(
                    fontSize: 11,
                    color: dueDateColor(
                      dueDate: task.dueDate!,
                      isCompleted: task.isCompleted,
                      context: context,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => showTaskFormSheet(context, ref, task: task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () =>
                ref.read(tasksStateProvider.notifier).deleteTask(task.id),
          ),
        ],
      ),
    );
  }
}

void showTaskFormSheet(
  BuildContext context,
  WidgetRef ref, {
  TaskModel? task,
}) {
  ref.read(taskAiBridgeProvider.notifier).reset();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TaskFormSheet(existingTask: task),
  );
}
