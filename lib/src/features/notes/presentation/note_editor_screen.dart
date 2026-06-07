import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lifeos/src/features/notes/application/note_provider.dart';
import 'package:lifeos/src/features/notes/domain/note_model.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final NoteModel? note; // ← NoteModel, not raw Note row
  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isPreviewMode = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) return;

    final notifier = ref.read(noteProvider.notifier); // ← NoteNotifier

    if (_isEditing) {
      notifier.updateNote(
        widget.note!.copyWith(title: title, content: content),
      );
    } else {
      notifier.addNote(
        NoteModel(
          id: 0,
          title: title,
          content: content,
          createdAt: DateTime.now(),
          isSynced: false,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for mutation errors
    ref.listen<AsyncValue<void>>(noteProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save note: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'New Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isPreviewMode
                  ? Icons.edit_outlined
                  : Icons.remove_red_eye_outlined,
            ),
            tooltip: _isPreviewMode ? 'Edit' : 'Preview',
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isPreviewMode
            ? Markdown(data: _contentController.text)
            : Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Start writing (Markdown supported)...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
