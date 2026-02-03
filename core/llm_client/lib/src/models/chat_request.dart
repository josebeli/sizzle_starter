import 'package:llm_client/src/models/chat_message.dart';
import 'package:meta/meta.dart';

/// {@template chat_request}
/// Request for chat completion.
/// {@endtemplate}
@immutable
class ChatRequest {
  /// {@macro chat_request}
  const ChatRequest({
    required this.model,
    required this.messages,
    this.temperature,
    this.maxTokens,
    this.stream = false,
  });

  /// Model identifier (e.g., 'openai/gpt-4o').
  final String model;

  /// List of messages in the conversation.
  final List<ChatMessage> messages;

  /// Sampling temperature (0.0 - 2.0).
  final double? temperature;

  /// Maximum tokens to generate.
  final int? maxTokens;

  /// Whether to stream the response.
  final bool stream;

  /// Converts to JSON for API request.
  Map<String, Object?> toJson() => {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'max_tokens': maxTokens,
        'stream': stream,
      };
}
