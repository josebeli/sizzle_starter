import 'package:session_scheduler/src/models/session_state.dart';
import 'package:session_scheduler/src/models/turn_result.dart';

/// {@template session_scheduler}
/// Abstract interface for session scheduling.
/// 
/// Manages the lifecycle of a collaborative LLM session including
/// play, pause, stop, and turn execution.
/// {@endtemplate}
abstract interface class SessionScheduler {
  /// {@macro session_scheduler}
  const SessionScheduler();

  /// Gets the current session state.
  SessionState get state;

  /// Stream of state changes.
  Stream<SessionState> get stateStream;

  /// Starts the automatic play loop.
  /// 
  /// Executes turns continuously until:
  /// - Stop is called
  /// - Max turns reached
  /// - No active items remain (completion)
  /// - Error occurs
  /// 
  /// Returns immediately if already playing.
  Future<void> play();

  /// Pauses the session.
  /// 
  /// Current turn completes before pausing.
  /// Can be resumed with [play].
  Future<void> pause();

  /// Stops the session immediately.
  /// 
  /// Cancels any in-flight requests.
  /// State becomes idle.
  Future<void> stop();

  /// Executes a single turn.
  /// 
  /// Returns the result of the turn.
  /// Can be called while paused.
  Future<TurnResult> nextTurn();

  /// Checks if the session can be finalized.
  /// 
  /// Returns true if there are no active items.
  bool get canFinalize;

  /// Finalizes the session.
  /// 
  /// Marks the session as completed.
  /// Can only be called when paused or idle.
  Future<void> finalize();

  /// Disposes the scheduler and releases resources.
  Future<void> dispose();
}