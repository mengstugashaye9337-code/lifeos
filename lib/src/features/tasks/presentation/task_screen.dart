// lib/src/features/tasks/presentation/task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/features/tasks/application/task_ai_bridge.dart';
import 'package:lifeos/src/features/tasks/data/task_repository.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/core/utils/utils.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to our unified master view state notifier
    final viewStateAsync = ref.watch(tasksStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Column(
        children: [
          // ── Filter bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: viewStateAsync.when(
              data: (state) => SegmentedButton<TaskFilter>(
                segments: const [
                  ButtonSegment(value: TaskFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: TaskFilter.pending,
                    label: Text('Pending'),
                  ),
                  ButtonSegment(
                    value: TaskFilter.completed,
                    label: Text('Done'),
                  ),
                ],
                selected: {state.filter},
                onSelectionChanged: (val) =>
                    ref.read(tasksStateProvider.notifier).setFilter(val.first),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          // ── Task list ──
          Expanded(
            child: viewStateAsync.when(
              data: (state) {
                final tasks =
                    state.filteredTasks; // Synchronous computed array mapping

                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks here.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskTile(task: task);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskSheet(context, ref, task: null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task Tile — #4 fixed (priority badge + due date)
// ---------------------------------------------------------------------------

class _TaskTile extends ConsumerWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priority = priorityFromDb(task.priority);
    final colorScheme = Theme.of(context).colorScheme;

    final priorityColor = switch (priority) {
      TaskPriority.high => Colors.red.shade400,
      TaskPriority.medium => Colors.orange.shade400,
      TaskPriority.low => Colors.green.shade400,
    };

    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => ref.read(taskRepositoryProvider).toggleTask(task),
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
              // Priority badge
              Container(
                margin: const EdgeInsets.only(top: 4, right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityColor, width: 0.8),
                ),
                child: Text(
                  priority.label,
                  style: TextStyle(fontSize: 11, color: priorityColor),
                ),
              ),
              // Due date
              if (task.dueDate != null)
                Text(
                  formatShortDate(task.dueDate!),
                  style: TextStyle(
                    fontSize: 11,
                    color: _dueDateColor(
                      task.dueDate!,
                      task.isCompleted,
                      context,
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
          // Edit button — #3 fixed
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _showTaskSheet(context, ref, task: task),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () =>
                ref.read(taskRepositoryProvider).deleteTask(task.id),
          ),
        ],
      ),
    );
  }

  Color _dueDateColor(DateTime due, bool isCompleted, BuildContext context) {
    if (isCompleted) return Theme.of(context).colorScheme.outline;
    final now = DateTime.now();
    if (due.isBefore(now)) return Colors.red.shade400;
    if (due.difference(now).inDays <= 1) return Colors.orange.shade400;
    return Theme.of(context).colorScheme.outline;
  }
}

// ---------------------------------------------------------------------------
// Add / Edit bottom sheet — #1 & #3 fixed
// ---------------------------------------------------------------------------

void _showTaskSheet(BuildContext context, WidgetRef ref, {Task? task}) {
  ref.read(taskAiBridgeProvider.notifier).reset();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _TaskSheet(existingTask: task),
  );
}

class _TaskSheet extends ConsumerStatefulWidget {
  final Task? existingTask;
  const _TaskSheet({this.existingTask});

  @override
  ConsumerState<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<_TaskSheet> {
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
          title: drift.Value(title),
          description: drift.Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          priority: drift.Value(_priority.toDbValue()),
          dueDate: drift.Value(_dueDate),
        ),
      );
    } else {
      repo.addTask(
        TasksCompanion.insert(
          title: title,
          description: drift.Value(
            _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          ),
          priority: drift.Value(_priority.toDbValue()),
          dueDate: drift.Value(_dueDate),
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
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _dueDate == null ? 'Set due date' : formatFullDate(_dueDate!),
            ),
            onPressed: _pickDate,
          ),
          if (_dueDate != null)
            TextButton(
              onPressed: () => setState(() => _dueDate = null),
              child: const Text('Clear due date'),
            ),
          const SizedBox(height: 20),

          // Save
          FilledButton(
            onPressed: _save,
            child: Text(isEditing ? 'Update Task' : 'Add Task'),
          ),
        ],
      ),
    );
  }
}
