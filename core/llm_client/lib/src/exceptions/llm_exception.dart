/// {@template llm_exception}
/// Base class for all LLM client exceptions.
/// {@endtemplate}
sealed class LLMException implements Exception {
  /// {@macro llm_exception}
  const LLMException({
    required this.message,
    this.cause,
  });

  final String message;
  final Object? cause;

  @override
  String toString() => 'LLMException: $message (cause: $cause)';
}

/// {@template llm_timeout_exception}
/// Thrown when an LLM request times out.
/// {@endtemplate}
final class LLMTimeoutException extends LLMException {
  /// {@macro llm_timeout_exception}
  const LLMTimeoutException({
    required super.message,
    required this.timeoutSeconds,
    super.cause,
  });

  /// Timeout duration in seconds.
  final int timeoutSeconds;

  @override
  String toString() => 
      'LLMTimeoutException: $message (timeout: ${timeoutSeconds}s)';
}

/// {@template llm_retry_exhausted_exception}
/// Thrown when all retry attempts have been exhausted.
/// {@endtemplate}
final class LLMRetryExhaustedException extends LLMException {
  /// {@macro llm_retry_exhausted_exception}
  const LLMRetryExhaustedException({
    required super.message,
    required this.attempts,
    required this.lastError,
  });

  /// Number of attempts made.
  final int attempts;

  /// The last error that caused the retry to fail.
  final Object lastError;

  @override
  String toString() => 
      'LLMRetryExhaustedException: $message (attempts: $attempts)';
}

/// {@template llm_rate_limit_exception}
/// Thrown when rate limit is exceeded.
/// {@endtemplate}
final class LLMRateLimitException extends LLMException {
  const LLMRateLimitException({
    required super.message,
    this.retryAfter,
  });

  /// Seconds to wait before retrying.
  final int? retryAfter;
}

/// {@template llm_authentication_exception}
/// Thrown when API key is invalid.
/// {@endtemplate}
final class LLMAuthenticationException extends LLMException {
  const LLMAuthenticationException({required super.message});
}

/// {@template llm_operation_failed_exception}
/// Thrown when a generic LLM operation fails.
/// {@endtemplate}
final class LLMOperationFailedException extends LLMException {
  const LLMOperationFailedException({
    required super.message,
    super.cause,
  });
}
