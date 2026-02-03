import 'package:meta/meta.dart';

/// {@template llm_settings}
/// Configuration settings for LLM client.
/// {@endtemplate}
@immutable
class LLMSettings {
  /// {@macro llm_settings}
  const LLMSettings({
    this.apiKey = '',
    this.maxConcurrentRequests = 3,
    this.requestTimeoutSeconds = 60,
    this.globalDelayMs = 0,
  }) : assert(maxConcurrentRequests >= 1 && maxConcurrentRequests <= 10),
       assert(requestTimeoutSeconds > 0);

  /// OpenRouter API key.
  final String apiKey;

  /// Maximum concurrent requests (1-10).
  final int maxConcurrentRequests;

  /// Request timeout in seconds.
  final int requestTimeoutSeconds;

  /// Global delay between requests in milliseconds.
  final int globalDelayMs;

  /// Creates a copy with modified fields.
  LLMSettings copyWith({
    String? apiKey,
    int? maxConcurrentRequests,
    int? requestTimeoutSeconds,
    int? globalDelayMs,
  }) =>
      LLMSettings(
        apiKey: apiKey ?? this.apiKey,
        maxConcurrentRequests: maxConcurrentRequests ?? this.maxConcurrentRequests,
        requestTimeoutSeconds: requestTimeoutSeconds ?? this.requestTimeoutSeconds,
        globalDelayMs: globalDelayMs ?? this.globalDelayMs,
      );
}
