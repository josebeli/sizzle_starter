import 'package:meta/meta.dart';

/// {@template chat_message}
/// A single message in a chat conversation.
/// {@endtemplate}
@immutable
class ChatMessage {
  /// {@macro chat_message}
  const ChatMessage({
    required this.role,
    required this.content,
  });

  /// Creates from JSON.
  factory ChatMessage.fromJson(Map<String, Object?> json) =>
      ChatMessage(
        role: json['role']! as String,
        content: json['content']! as String,
      );

  /// Role of the message sender: 'system', 'user', or 'assistant'.
  final String role;

  /// Content of the message.
  final String content;

  /// Converts to JSON.
  Map<String, Object?> toJson() => {
        'role': role,
        'content': content,
      };

  @override
  String toString() => 'ChatMessage(role: $role, content: ${content.length} chars)';
}
