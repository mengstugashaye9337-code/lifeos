// lib/src/features/tasks/presentation/widgets/task_form_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value; // Senior namespace isolation
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/features/tasks/application/task_ai_bridge.dart';
import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/database/app_database.dart'; // Exposes TasksCompanion and Task
import 'package:lifeos/src/core/utils/utils.dart'; // Handles formatFullDate

class TaskFormSheet extends ConsumerStatefulWidget {
  final Task?
  existingTask; // If passed, we are in EDIT mode. If null, we are in ADD mode.
  const TaskFormSheet({super.key, this.existingTask});

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late TaskPriority _priority;
  DateTime? _dueDate;

  bool get isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _priority = task != null
        ? priorityFromDb(task.priority)
        : TaskPriority.medium;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final repo = ref.read(taskRepositoryProvider);

    if (isEditing) {
      repo.updateTask(
        widget.existingTask!.id,
        TasksCompanion(
          title: Value(title),
          description: Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          priority: Value(_priority.toDbValue()),
          dueDate: Value(_dueDate),
        ),
      );
    } else {
      repo.addTask(
        TasksCompanion.insert(
          title: title,
          description: Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          priority: Value(_priority.toDbValue()),
          dueDate: Value(_dueDate),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(taskAiBridgeProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title + AI button
          TextField(
            controller: _titleController,
            autofocus: !isEditing,
            decoration: InputDecoration(
              labelText: 'Title',
              border: const OutlineInputBorder(),
              suffixIcon: aiState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Colors.deepPurple,
                      ),
                      tooltip: 'Clean up with AI',
                      onPressed: () async {
                        if (_titleController.text.trim().isEmpty) return;
                        final result = await ref
                            .read(taskAiBridgeProvider.notifier)
                            .cleanUpTask(_titleController.text);
                        if (result != null && mounted) {
                          _titleController.text = result;
                        }
                      },
                    ),
            ),
          ),
          if (aiState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'AI unavailable. You can still save manually.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Priority selector
          Text('Priority', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<TaskPriority>(
            segments: TaskPriority.values
                .map((p) => ButtonSegment(value: p, label: Text(p.label)))
                .toList(),
            selected: {_priority},
            onSelectionChanged: (val) => setState(() => _priority = val.first),
          ),
          const SizedBox(height: 16),

          // Due date
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _dueDate == null ? 'Set due date' : formatFullDate(_dueDate!),
                ),
                onPressed: _pickDate,
              ),
              if (_dueDate != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _dueDate = null),
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Save Button
          FilledButton(
            onPressed: _save,
            child: Text(isEditing ? 'Update Task' : 'Add Task'),
          ),
        ],
      ),
    );
  }
}
