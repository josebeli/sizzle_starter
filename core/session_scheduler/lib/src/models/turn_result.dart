import 'package:meta/meta.dart';

/// {@template turn_result}
/// Result of executing a single turn.
/// {@endtemplate}
@immutable
class TurnResult {
  /// {@macro turn_result}
  const TurnResult({
    required this.success,
    this.snapshotSeq,
    this.error,
    this.shouldRetry = false,
    this.isFinalized = false,
  });

  /// Whether the turn executed successfully.
  final bool success;

  /// Sequence number of the saved snapshot (if successful).
  final int? snapshotSeq;

  /// Error message if failed.
  final String? error;

  /// Whether the turn should be retried.
  final bool shouldRetry;

  /// Whether the session should be finalized after this turn.
  final bool isFinalized;

  /// Creates a successful result.
  factory TurnResult.success({
    required int snapshotSeq,
    bool isFinalized = false,
  }) =>
      TurnResult(
        success: true,
        snapshotSeq: snapshotSeq,
        isFinalized: isFinalized,
      );

  /// Creates a failure result.
  factory TurnResult.failure({
    required String error,
    bool shouldRetry = false,
  }) =>
      TurnResult(
        success: false,
        error: error,
        shouldRetry: shouldRetry,
      );

  @override
  String toString() => 
      'TurnResult(success: $success, seq: $snapshotSeq)';
}