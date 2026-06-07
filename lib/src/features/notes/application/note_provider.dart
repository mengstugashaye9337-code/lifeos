import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/src/database/database_provider.dart';
import 'package:lifeos/src/features/notes/data/note_repository.dart';
import 'package:lifeos/src/features/notes/domain/note_model.dart';

part 'note_provider.g.dart';

// ---------------------------------------------------------------------------
// Repository provider — depends on interface, not concrete class
// ---------------------------------------------------------------------------

@riverpod
INoteRepository noteRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return NoteRepository(db);
}

// ---------------------------------------------------------------------------
// Notes stream — reactive list of domain models, newest first
// ---------------------------------------------------------------------------

@riverpod
Stream<List<NoteModel>> noteListStream(Ref ref) {
  return ref.watch(noteRepositoryProvider).watchNotes();
}

// ---------------------------------------------------------------------------
// Note mutations — AsyncNotifier owns loading + error per action
// ---------------------------------------------------------------------------

@riverpod
class NoteNotifier extends _$NoteNotifier {
  Timer? _deleteTimer;
  NoteModel? _pendingDelete; // held in memory during undo window

  @override
  FutureOr<void> build() {
    // Clean up timer if provider is disposed mid-countdown
    ref.onDispose(() {
      _deleteTimer?.cancel();
      // If provider disposed while delete pending — commit it immediately
      if (_pendingDelete != null) {
        ref.read(noteRepositoryProvider).deleteNote(_pendingDelete!.id);
      }
    });
  }

  INoteRepository get _repo => ref.read(noteRepositoryProvider);

  Future<void> addNote(NoteModel note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addNote(note));
  }

  Future<void> updateNote(NoteModel note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateNote(note));
  }

  // ── Optimistic delete with undo support ──────────────────────────────────

  void softDelete(NoteModel note) {
    // Cancel any previous pending delete first
    _deleteTimer?.cancel();

    // Hold the note — do NOT touch the DB yet
    _pendingDelete = note;

    // Start 4-second countdown to commit
    _deleteTimer = Timer(const Duration(seconds: 4), _commitDelete);
  }

  void undoDelete() {
    // Cancel the countdown — note stays in DB untouched
    _deleteTimer?.cancel();
    _deleteTimer = null;
    _pendingDelete = null;
    // Stream auto-refreshes — note reappears immediately
  }

  Future<void> _commitDelete() async {
    if (_pendingDelete == null) return;
    final note = _pendingDelete!;
    _pendingDelete = null;
    _deleteTimer = null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteNote(note.id));
  }

  // Hard delete — no undo, used internally if needed
  Future<void> deleteNote(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteNote(id));
  }
}
