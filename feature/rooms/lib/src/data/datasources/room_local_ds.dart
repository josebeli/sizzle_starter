import 'package:rooms/src/domain/models/room.dart';

/// {@template room_local_datasource}
/// Interface for local storage of rooms.
/// Abstracts the persistence mechanism from the repository.
/// {@endtemplate}
abstract interface class RoomLocalDataSource {
  /// {@macro room_local_datasource}
  const RoomLocalDataSource();

  /// Gets all rooms metadata
  Future<List<Room>> getAll();

  /// Gets a single room by ID
  /// Throws [RoomNotFoundException] if not found
  Future<Room> getById(String roomId);

  /// Creates a new room with directory structure
  /// Throws [RoomAlreadyExistsException] if ID already exists
  Future<void> create(Room room);

  /// Updates room metadata
  /// Throws [RoomNotFoundException] if not found
  Future<void> update(Room room);

  /// Deletes a room and all its contents
  /// Throws [RoomNotFoundException] if not found
  Future<void> delete(String roomId);

  /// Renames a room
  /// Throws [RoomNotFoundException] if not found
  Future<void> rename(String roomId, String newName);

  /// Checks if a room exists
  Future<bool> exists(String roomId);
}

/// Exception thrown when a room is not found
final class RoomNotFoundException implements Exception {
  const RoomNotFoundException(this.roomId);
  final String roomId;

  @override
  String toString() => 'RoomNotFoundException: Room $roomId not found';
}

/// Exception thrown when trying to create a room with duplicate ID
final class RoomAlreadyExistsException implements Exception {
  const RoomAlreadyExistsException(this.roomId);
  final String roomId;

  @override
  String toString() => 'RoomAlreadyExistsException: Room $roomId already exists';
}
