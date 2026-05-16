import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lifeos/src/database/app_database.dart';
import 'package:lifeos/src/features/notes/application/note_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note; // If null, we are creating a new note
  const NoteEditorScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  void _saveNote() {
    final repository = ref.read(noteRepositoryProvider);
    if (widget.note == null) {
      repository.addNote(
        NotesCompanion.insert(
          title: _titleController.text,
          content: _contentController.text,
        ),
      );
    } else {
      repository.updateNote(
        widget.note!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.remove_red_eye),
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveNote),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
