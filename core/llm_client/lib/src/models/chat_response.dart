import 'package:meta/meta.dart';

/// {@template chat_response}
/// Response from chat completion.
/// {@endtemplate}
@immutable
class ChatResponse {
  /// {@macro chat_response}
  const ChatResponse({
    required this.id,
    required this.content,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    this.finishReason,
  });

  /// Unique identifier for the response.
  final String id;

  /// Generated content (the actual response text).
  final String content;

  /// Model used for the completion.
  final String model;

  /// Number of tokens in the prompt.
  final int promptTokens;

  /// Number of tokens in the completion.
  final int completionTokens;

  /// Reason why the completion finished.
  final String? finishReason;

  /// Total tokens used.
  int get totalTokens => promptTokens + completionTokens;

  @override
  String toString() => 
      'ChatResponse(id: $id, model: $model, tokens: $totalTokens)';
}
