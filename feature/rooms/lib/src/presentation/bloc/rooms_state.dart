import 'package:meta/meta.dart';
import 'package:rooms/src/domain/models/room.dart';

/// Types of room operations.
enum RoomsOperation {
  /// Room was created.
  created,

  /// Room was renamed.
  renamed,

  /// Room was deleted.
  deleted,
}

/// {@template rooms_state}
/// Base class for rooms BLoC states.
/// {@endtemplate}
@immutable
sealed class RoomsState {
  /// {@macro rooms_state}
  const RoomsState();

  /// Initial state factory
  const factory RoomsState.initial() = RoomsInitial;
}

/// {@template rooms_initial}
/// Initial state before any operation.
/// {@endtemplate}
final class RoomsInitial extends RoomsState {
  /// {@macro rooms_initial}
  const RoomsInitial();
}

/// {@template rooms_loading}
/// State emitted when loading rooms.
/// {@endtemplate}
final class RoomsLoading extends RoomsState {
  /// {@macro rooms_loading}
  const RoomsLoading();
}

/// {@template rooms_loaded}
/// State emitted when rooms are loaded.
/// {@endtemplate}
final class RoomsLoaded extends RoomsState {
  /// {@macro rooms_loaded}
  const RoomsLoaded(this.rooms);

  /// List of all rooms.
  final List<Room> rooms;
}

/// {@template rooms_error}
/// State emitted when an error occurs.
/// {@endtemplate}
final class RoomsError extends RoomsState {
  /// {@macro rooms_error}
  const RoomsError(this.message);

  /// Error message.
  final String message;
}

/// {@template rooms_operation_success}
/// State emitted when an operation succeeds.
/// {@endtemplate}
final class RoomsOperationSuccess extends RoomsState {
  /// {@macro rooms_operation_success}
  const RoomsOperationSuccess({
    required this.operation,
    required this.rooms,
    this.roomId,
  });

  /// The operation that succeeded.
  final RoomsOperation operation;

  /// Updated list of all rooms.
  final List<Room> rooms;

  /// ID of the affected room (if applicable).
  final String? roomId;

  /// Returns a user-friendly message for the operation.
  String get message => switch (operation) {
        RoomsOperation.created => 'Room created successfully',
        RoomsOperation.renamed => 'Room renamed successfully',
        RoomsOperation.deleted => 'Room deleted successfully',
      };
}
