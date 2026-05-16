import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
  }) = _AIMessage;

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
}
