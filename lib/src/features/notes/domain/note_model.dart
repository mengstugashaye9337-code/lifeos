import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_model.freezed.dart';

@freezed
abstract class NoteModel with _$NoteModel {
  const factory NoteModel({
    required int id,
    required String title,
    required String content,
    required DateTime createdAt,
    required bool isSynced,
  }) = _NoteModel;

  const NoteModel._();

  // Convenience — first 100 chars of content for list preview
  String get preview {
    final cleaned = content.replaceAll('\n', ' ').trim();
    if (cleaned.length <= 100) return cleaned;
    return '${cleaned.substring(0, 100)}...';
  }

  // Is this note empty — no real content written yet
  bool get isEmpty => content.trim().isEmpty;
}
