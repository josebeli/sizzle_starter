import 'dart:async';

/// {@template cancel_token}
/// Token that can be used to cancel an in-flight request.
/// {@endtemplate}
class CancelToken {
  final _completer = Completer<void>();

  /// Whether the token has been cancelled.
  bool get isCancelled => _completer.isCompleted;

  /// Future that completes when the token is cancelled.
  Future<void> get onCancel => _completer.future;

  /// Cancels the request.
  void cancel() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}
