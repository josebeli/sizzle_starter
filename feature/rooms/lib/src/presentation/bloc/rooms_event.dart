import 'package:meta/meta.dart';

import 'package:rooms/src/domain/models/room_input.dart';

/// {@template rooms_event}
/// Base class for all RoomsBloc events.
/// {@endtemplate}
@immutable
sealed class RoomsEvent {
  const RoomsEvent();
}

/// Load all rooms
final class RoomsLoadRequested extends RoomsEvent {
  const RoomsLoadRequested();
}

/// Create a new room
final class RoomCreateRequested extends RoomsEvent {
  const RoomCreateRequested(this.input);

  final RoomInput input;
}

/// Rename an existing room
final class RoomRenameRequested extends RoomsEvent {
  const RoomRenameRequested({
    required this.roomId,
    required this.newName,
  });

  final String roomId;
  final String newName;
}

/// Delete a room
final class RoomDeleteRequested extends RoomsEvent {
  const RoomDeleteRequested(this.roomId);

  final String roomId;
}
