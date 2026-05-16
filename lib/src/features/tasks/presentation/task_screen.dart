import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/ai_assistant/application/ai_controller.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: tasksAsync.when(
        data: (tasks) => ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) =>
                    ref.read(taskRepositoryProvider).toggleTask(task),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    ref.read(taskRepositoryProvider).deleteTask(task.id),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        // We watch the AI state to show a loader inside the dialog
        final aiState = ref.watch(aIControllerProvider);

        return AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter task or messy note...',
                  suffixIcon: aiState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.auto_awesome,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () async {
                            if (controller.text.isNotEmpty) {
                              await ref
                                  .read(aIControllerProvider.notifier)
                                  .cleanUpTask(controller.text);
                              final result = ref
                                  .read(aIControllerProvider)
                                  .value;
                              if (result != null) controller.text = result;
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(taskRepositoryProvider)
                      .addTask(TasksCompanion.insert(title: controller.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
