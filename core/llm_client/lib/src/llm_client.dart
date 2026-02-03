import 'package:llm_client/llm_client.dart' show LLMException, LLMRetryExhaustedException, LLMTimeoutException;
import 'package:llm_client/src/cancel_token.dart';
import 'package:llm_client/src/exceptions/llm_exception.dart' show LLMException, LLMRetryExhaustedException, LLMTimeoutException;
import 'package:llm_client/src/models/chat_request.dart';
import 'package:llm_client/src/models/chat_response.dart';

/// {@template llm_client}
/// Abstract interface for LLM API clients.
/// 
/// Provides a unified way to interact with different LLM providers.
/// All implementations must support cancellation via [CancelToken].
/// {@endtemplate}
abstract interface class LLMClient {
  /// {@macro llm_client}
  const LLMClient();

  /// Sends a chat completion request.
  /// 
  /// [request] contains the messages and parameters.
  /// [cancelToken] allows cancelling the request.
  /// Returns [ChatResponse] with the completion.
  /// 
  /// Throws:
  /// - [LLMTimeoutException] if the request times out
  /// - [LLMRetryExhaustedException] if all retries fail
  /// - [LLMException] for other errors
  Future<ChatResponse> chatCompletion(
    ChatRequest request, {
    CancelToken? cancelToken,
  });

  /// Checks if the client is ready to make requests.
  /// 
  /// Returns true if API key is configured.
  bool get isConfigured;
}
