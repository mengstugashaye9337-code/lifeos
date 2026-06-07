import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/src/features/habits/application/habit_provider.dart';
import 'package:lifeos/src/features/habits/domain/habit_model.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListStreamProvider);

    // ── Side effect listener — mutation errors surface as snackbar ──────
    ref.listen<AsyncValue<void>>(habitProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: habits.length,
            itemBuilder: (_, index) => _HabitTile(habit: habits[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHabitSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.loop_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text('No habits yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap + to build your first one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habit Tile
// ---------------------------------------------------------------------------

class _HabitTile extends ConsumerWidget {
  final HabitModel habit;
  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = habit.isCompletedToday;
    final streakActive = habit.isStreakActive;
    final notifier = ref.read(habitProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),

        // ── Completion circle ──────────────────────────────────────────
        leading: GestureDetector(
          onTap: () => isDone
              ? notifier.unmarkComplete(habit)
              : notifier.markComplete(habit),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: isDone ? colorScheme.primary : colorScheme.outline,
                width: 2,
              ),
            ),
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    color: colorScheme.onPrimary,
                    size: 22,
                  )
                : null,
          ),
        ),

        // ── Title ──────────────────────────────────────────────────────
        title: Text(
          habit.title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? colorScheme.outline : colorScheme.onSurface,
          ),
        ),

        // ── Frequency chip + streak ────────────────────────────────────
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              // Frequency chip
              _Chip(label: habit.frequency.label),
              const SizedBox(width: 8),

              // Streak badge — only show when streak > 0
              if (habit.streak > 0) ...[
                Text('🔥', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 2),
                Text(
                  '${habit.streak} ${habit.streak == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: streakActive
                        ? Colors.orange.shade700
                        : colorScheme.outline, // grey out broken streak
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Actions ────────────────────────────────────────────────────
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showHabitSheet(context, ref, habit: habit),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: colorScheme.error,
              onPressed: () => _confirmDelete(context, ref, habit),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, HabitModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Delete "${habit.title}" and its entire history?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Frequency chip
// ---------------------------------------------------------------------------

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / Edit bottom sheet — free function, opens the stateful sheet
// ---------------------------------------------------------------------------

void _showHabitSheet(BuildContext context, WidgetRef ref, {HabitModel? habit}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _HabitSheet(existingHabit: habit),
  );
}

// ---------------------------------------------------------------------------
// Add / Edit sheet — ConsumerStatefulWidget owns form state
// ---------------------------------------------------------------------------

class _HabitSheet extends ConsumerStatefulWidget {
  final HabitModel? existingHabit;
  const _HabitSheet({this.existingHabit});

  @override
  ConsumerState<_HabitSheet> createState() => _HabitSheetState();
}

class _HabitSheetState extends ConsumerState<_HabitSheet> {
  late final TextEditingController _titleController;
  late HabitFrequency _frequency;

  bool get _isEditing => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingHabit?.title ?? '',
    );
    _frequency = widget.existingHabit?.frequency ?? HabitFrequency.daily;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(habitProvider.notifier);

    if (_isEditing) {
      // copyWith — never reconstruct the whole model manually
      notifier.updateHabit(
        widget.existingHabit!.copyWith(title: title, frequency: _frequency),
      );
    } else {
      notifier.addHabit(
        HabitModel(
          id: 0, // DB assigns the real id on insert
          title: title,
          frequency: _frequency,
          streak: 0,
          createdAt: DateTime.now(),
          isSynced: false,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                _isEditing ? 'Edit Habit' : 'New Habit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Title field ───────────────────────────────────────────────
          TextField(
            controller: _titleController,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g. Morning run, Read 20 pages...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Frequency selector ────────────────────────────────────────
          Text('Frequency', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<HabitFrequency>(
            segments: HabitFrequency.values
                .map(
                  (f) => ButtonSegment(
                    value: f,
                    label: Text(f.label),
                    icon: Icon(
                      f == HabitFrequency.daily
                          ? Icons.today_outlined
                          : Icons.date_range_outlined,
                    ),
                  ),
                )
                .toList(),
            selected: {_frequency},
            onSelectionChanged: (val) => setState(() => _frequency = val.first),
          ),
          const SizedBox(height: 28),

          // ── Save button ───────────────────────────────────────────────
          FilledButton(
            onPressed: _save,
            child: Text(_isEditing ? 'Update Habit' : 'Add Habit'),
          ),
        ],
      ),
    );
  }
}
