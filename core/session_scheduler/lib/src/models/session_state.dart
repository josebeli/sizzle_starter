import 'package:meta/meta.dart';

/// States of a session lifecycle.
enum SessionStatus {
  /// No active session.
  idle,

  /// Session active but paused.
  paused,

  /// Automatic execution in progress.
  playing,

  /// Checking completion conditions.
  finalizing,

  /// Session completed successfully.
  finalized,

  /// Error occurred during execution.
  error,
}

/// {@template session_state}
/// Represents the current state of a session.
/// {@endtemplate}
@immutable
class SessionState {
  /// {@macro session_state}
  const SessionState({
    required this.status,
    this.currentTurn = 0,
    this.maxTurns = 500,
    this.currentExpertIndex = 0,
    this.totalExperts = 0,
    this.lastError,
    this.lastSnapshotSeq,
  });

  /// Current status of the session.
  final SessionStatus status;

  /// Current turn number (0 = not started).
  final int currentTurn;

  /// Maximum number of turns allowed.
  final int maxTurns;

  /// Index of the current expert in the rotation.
  final int currentExpertIndex;

  /// Total number of experts in the session.
  final int totalExperts;

  /// Last error message if status is error.
  final String? lastError;

  /// Sequence number of the last saved snapshot.
  final int? lastSnapshotSeq;

  /// Whether the session is idle.
  bool get isIdle => status == SessionStatus.idle;

  /// Whether the session is paused.
  bool get isPaused => status == SessionStatus.paused;

  /// Whether the session is playing.
  bool get isPlaying => status == SessionStatus.playing;

  /// Whether the session is finalized.
  bool get isFinalized => status == SessionStatus.finalized;

  /// Whether the session has an error.
  bool get hasError => status == SessionStatus.error;

  /// Whether a turn can be executed.
  bool get canExecuteTurn => 
      status == SessionStatus.idle || 
      status == SessionStatus.paused;

  /// Whether play can be started.
  bool get canPlay => 
      status == SessionStatus.idle || 
      status == SessionStatus.paused;

  /// Progress as a value between 0.0 and 1.0.
  double get progress => maxTurns > 0 ? currentTurn / maxTurns : 0.0;

  /// Creates a copy with modified fields.
  SessionState copyWith({
    SessionStatus? status,
    int? currentTurn,
    int? maxTurns,
    int? currentExpertIndex,
    int? totalExperts,
    String? lastError,
    int? lastSnapshotSeq,
  }) =>
      SessionState(
        status: status ?? this.status,
        currentTurn: currentTurn ?? this.currentTurn,
        maxTurns: maxTurns ?? this.maxTurns,
        currentExpertIndex: currentExpertIndex ?? this.currentExpertIndex,
        totalExperts: totalExperts ?? this.totalExperts,
        lastError: lastError ?? this.lastError,
        lastSnapshotSeq: lastSnapshotSeq ?? this.lastSnapshotSeq,
      );

  @override
  String toString() => 
      'SessionState(status: $status, turn: $currentTurn/$maxTurns)';
}