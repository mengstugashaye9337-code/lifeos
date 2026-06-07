// lib/src/features/tasks/presentation/task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/src/features/tasks/application/task_provider.dart';
import 'package:lifeos/src/features/tasks/application/task_ai_bridge.dart';
import 'package:lifeos/src/features/tasks/presentation/widgets/task_tile.dart';
import 'package:lifeos/src/features/tasks/presentation/widgets/task_form_sheet.dart';

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
                    return TaskTile(
                      task: task,
                    ); // ✅ Clean, public extracted widget
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
        onPressed: () {
          ref.read(taskAiBridgeProvider.notifier).reset();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) =>
                const TaskFormSheet(), // ✅ Clean, public extracted sheet
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
