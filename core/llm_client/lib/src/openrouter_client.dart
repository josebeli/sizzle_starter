import 'dart:async';

import 'package:llm_client/src/cancel_token.dart';
import 'package:llm_client/src/exceptions/llm_exception.dart';
import 'package:llm_client/src/llm_client.dart';
import 'package:llm_client/src/models/chat_request.dart';
import 'package:llm_client/src/models/chat_response.dart';
import 'package:llm_client/src/models/llm_settings.dart';
import 'package:logger/logger.dart';
import 'package:rest_client/rest_client.dart';

/// {@template openrouter_client}
/// LLM client implementation for OpenRouter API.
/// 
/// Uses [RestClient] for HTTP operations.
/// Implements retry logic with exponential backoff.
/// Supports request cancellation via [CancelToken].
/// {@endtemplate}
final class OpenRouterClient implements LLMClient {
  /// {@macro openrouter_client}
  OpenRouterClient({
    required RestClient restClient,
    required LLMSettings settings,
    Logger? logger,
  })  : _restClient = restClient,
        _settings = settings,
        _logger = logger;

  final RestClient _restClient;
  LLMSettings _settings;
  final Logger? _logger;

  static const _maxRetries = 3;
  static const _baseDelayMs = 1000;

  @override
  bool get isConfigured => _settings.apiKey.isNotEmpty;

  /// Updates the settings.
  void updateSettings(LLMSettings settings) {
    _settings = settings;
  }

  @override
  Future<ChatResponse> chatCompletion(
    ChatRequest request, {
    CancelToken? cancelToken,
  }) async {
    if (!isConfigured) {
      throw const LLMOperationFailedException(message: 'API key not configured');
    }

    _logger?.info('Sending chat completion request: ${request.model}');

    var lastError = Exception('Unknown error');
    
    for (var attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await _sendRequest(request, cancelToken: cancelToken);
      } on LLMException {
        rethrow;
      } on Object catch (e) {
        lastError = Exception(e.toString());
        _logger?.warn('Request attempt $attempt failed: $e');

        if (attempt < _maxRetries) {
          // Check cancellation before retry
          if (cancelToken?.isCancelled ?? false) {
            throw const LLMOperationFailedException(message: 'Request cancelled');
          }

          // Exponential backoff: 1s, 2s
          final delayMs = _baseDelayMs * attempt;
          _logger?.debug('Retrying in ${delayMs}ms...');
          await Future<void>.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    throw LLMRetryExhaustedException(
      message: 'All retry attempts failed',
      attempts: _maxRetries,
      lastError: lastError,
    );
  }

  Future<ChatResponse> _sendRequest(
    ChatRequest request, {
    CancelToken? cancelToken,
  }) async {
    final timeout = Duration(seconds: _settings.requestTimeoutSeconds);

    // Create a timeout future
    final timeoutFuture = Future<void>.delayed(timeout);
    
    // Create the request future
    final requestFuture = _restClient.post(
      '/chat/completions',
      body: request.toJson(),
      headers: {
        'Authorization': 'Bearer ${_settings.apiKey}',
        'Content-Type': 'application/json',
      },
    );

    // Race between request and timeout/cancellation
    final responseFuture = requestFuture.then<Map<String, Object?>?>((data) => data);

    // Check for cancellation
    final cancelFuture = cancelToken?.onCancel ?? Completer<void>().future;

    final result = await Future.any<Object?>([
      responseFuture,
      timeoutFuture.then((_) => throw LLMTimeoutException(
            message: 'Request timed out after $timeout',
            timeoutSeconds: _settings.requestTimeoutSeconds,
          )),
      cancelFuture.then((_) => throw const LLMOperationFailedException(message: 'Request cancelled')),
    ]);

    if (result == null) {
      throw const LLMOperationFailedException(message: 'Empty response from API');
    }

    return _parseResponse(result as Map<String, Object?>);
  }

  ChatResponse _parseResponse(Map<String, Object?> json) {
    try {
      final choices = json['choices']! as List<Object?>;
      if (choices.isEmpty) {
        throw const LLMOperationFailedException(message: 'No choices in response');
      }

      final firstChoice = choices.first! as Map<String, Object?>;
      final message = firstChoice['message']! as Map<String, Object?>;
      
      final usage = json['usage'] as Map<String, Object?>?;

      return ChatResponse(
        id: json['id'] as String? ?? 'unknown',
        content: message['content'] as String? ?? '',
        model: json['model'] as String? ?? 'unknown',
        promptTokens: usage?['prompt_tokens'] as int? ?? 0,
        completionTokens: usage?['completion_tokens'] as int? ?? 0,
        finishReason: firstChoice['finish_reason'] as String?,
      );
    } on LLMException {
      rethrow;
    } on Object catch (e) {
      throw LLMOperationFailedException(message: 'Failed to parse response', cause: e);
    }
  }
}
