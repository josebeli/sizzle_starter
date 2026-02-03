import 'package:clock/clock.dart';
import 'package:uuid/uuid.dart';

import 'package:rooms/src/data/datasources/room_local_ds.dart';
import 'package:rooms/src/domain/models/room.dart';
import 'package:rooms/src/domain/models/room_config.dart';
import 'package:rooms/src/domain/models/room_input.dart';

/// {@template room_repository}
/// Repository for managing rooms.
///
/// Acts as an abstraction layer between the domain and data layers,
/// handling UUID generation, timestamps, and coordinating data source operations.
/// {@endtemplate}
abstract class RoomRepository {
  /// Gets all rooms
  Future<List<Room>> getAllRooms();

  /// Gets a single room by ID
  Future<Room?> getRoomById(String roomId);

  /// Creates a new room from input data
  Future<Room> createRoom(RoomInput input);

  /// Updates an existing room
  Future<void> updateRoom(Room room);

  /// Deletes a room
  Future<void> deleteRoom(String roomId);

  /// Renames a room
  Future<void> renameRoom(String roomId, String newName);
}

/// {@macro room_repository}
final class RoomRepositoryImpl implements RoomRepository {
  /// {@macro room_repository}
  const RoomRepositoryImpl({
    required this.localDataSource,
    this.uuid = const Uuid(),
    this.clock = const Clock(),
  });

  final RoomLocalDataSource localDataSource;
  final Uuid uuid;
  final Clock clock;

  @override
  Future<List<Room>> getAllRooms() => localDataSource.getAll();

  @override
  Future<Room?> getRoomById(String roomId) async {
    try {
      return await localDataSource.getById(roomId);
    } on RoomNotFoundException {
      return null;
    }
  }

  @override
  Future<Room> createRoom(RoomInput input) async {
    final now = clock.now().toUtc();
    final room = Room(
      roomId: uuid.v4(),
      name: input.name.trim(),
      createdAt: now,
      updatedAt: now,
      isFinalized: false,
      roomConfig: const RoomConfig(),
    );

    await localDataSource.create(room);
    return room;
  }

  @override
  Future<void> updateRoom(Room room) async {
    final updated = room.copyWith(updatedAt: clock.now().toUtc());
    await localDataSource.update(updated);
  }

  @override
  Future<void> deleteRoom(String roomId) =>
      localDataSource.delete(roomId);

  @override
  Future<void> renameRoom(String roomId, String newName) async {
    await localDataSource.rename(roomId, newName.trim());
  }
}
