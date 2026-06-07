import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/src/core/utils/utils.dart';
import 'package:lifeos/src/features/notes/application/note_provider.dart';
import 'package:lifeos/src/features/notes/domain/note_model.dart';
import 'package:lifeos/src/features/notes/presentation/note_editor_screen.dart';

class NoteListScreen extends ConsumerWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteListStreamProvider);

    // ── Mutation error listener ──────────────────────────────────────────
    ref.listen<AsyncValue<void>>(noteProvider, (_, next) {
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
      appBar: AppBar(title: const Text('My Notes')),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notes.length,
            itemBuilder: (_, index) => _NoteTile(note: notes[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, note: null),
        child: const Icon(Icons.edit_outlined),
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
            Icons.notes_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text('No notes yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Tap + to capture your first thought',
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
// Note tile
// ---------------------------------------------------------------------------

class _NoteTile extends ConsumerWidget {
  final NoteModel note;
  const _NoteTile({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      // ── Content ─────────────────────────────────────────────────────────
      title: Text(
        note.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!note.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                note.preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            formatFullDate(note.createdAt),
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
          ),
        ],
      ),

      // ── Actions ──────────────────────────────────────────────────────────
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _openEditor(context, note: note),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: colorScheme.error,
            ),
            onPressed: () => _softDelete(context, ref, note),
          ),
        ],
      ),

      onTap: () => _openEditor(context, note: note),
    );
  }

  // ── Optimistic delete + undo snackbar ────────────────────────────────────
  void _softDelete(BuildContext context, WidgetRef ref, NoteModel note) {
    // Trigger soft delete — DB untouched for 4 seconds
    ref.read(noteProvider.notifier).softDelete(note);

    // Cancel any existing snackbar first
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.title}" deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.read(noteProvider.notifier).undoDelete(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation helper
// ---------------------------------------------------------------------------

void _openEditor(BuildContext context, {NoteModel? note}) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
  );
}
