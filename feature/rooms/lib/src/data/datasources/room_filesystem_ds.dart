import 'dart:convert';

import 'package:filesystem_storage/filesystem_storage.dart';

import 'package:rooms/src/data/datasources/room_local_ds.dart';
import 'package:rooms/src/domain/models/room.dart';
import 'package:rooms/src/domain/models/room_config.dart';

/// {@template room_filesystem_datasource}
/// Filesystem-based implementation of [RoomLocalDataSource].
///
/// Each room is stored in its own directory:
/// ```
/// rooms/{roomId}/
/// ├── room_meta.json       # Metadata and config
/// ├── current.json         # Current document (placeholder)
/// ├── index.json           # Timeline index (placeholder)
/// └── snapshots/           # Versioned snapshots
/// ```
/// {@endtemplate}
final class RoomFilesystemDataSource implements RoomLocalDataSource {
  /// {@macro room_filesystem_datasource}
  const RoomFilesystemDataSource({
    required this.storage,
  });

  final FilesystemStorage storage;

  static const String _roomsDir = 'rooms';
  static const String _metaFile = 'room_meta.json';
  static const String _version = '1.0';

  @override
  Future<List<Room>> getAll() async {
    final roomIds = await _getAllRoomIds();
    final rooms = <Room>[];

    for (final roomId in roomIds) {
      try {
        final room = await getById(roomId);
        rooms.add(room);
      } on RoomNotFoundException {
        // Skip corrupted directories - they will be ignored
        continue;
      }
    }

    // Sort by createdAt descending (newest first)
    rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rooms;
  }

  @override
  Future<Room> getById(String roomId) async {
    final metaPath = _getMetaPath(roomId);
    final exists = await storage.fileExists(metaPath);

    if (!exists) {
      throw RoomNotFoundException(roomId);
    }

    final content = await storage.readFile(metaPath);
    final json = jsonDecode(content) as Map<String, dynamic>;
    return _roomFromJson(json);
  }

  @override
  Future<void> create(Room room) async {
    if (await exists(room.roomId)) {
      throw RoomAlreadyExistsException(room.roomId);
    }

    final roomDir = '$_roomsDir/${room.roomId}';

    // Create directory structure
    await storage.ensureDirectory(roomDir);
    await storage.ensureDirectory('$roomDir/snapshots');

    // Write metadata
    final metaPath = _getMetaPath(room.roomId);
    await storage.writeFile(
      metaPath,
      jsonEncode(_roomToJson(room)),
    );

    // Write placeholder files for Phase 4
    await storage.writeFile('$roomDir/current.json', '{}');
    await storage.writeFile('$roomDir/index.json', '{}');
  }

  @override
  Future<void> update(Room room) async {
    if (!await exists(room.roomId)) {
      throw RoomNotFoundException(room.roomId);
    }

    final updatedRoom = room.copyWith(
      updatedAt: DateTime.now().toUtc(),
    );

    final metaPath = _getMetaPath(room.roomId);
    await storage.writeFile(
      metaPath,
      jsonEncode(_roomToJson(updatedRoom)),
    );
  }

  @override
  Future<void> delete(String roomId) async {
    if (!await exists(roomId)) {
      throw RoomNotFoundException(roomId);
    }

    final roomDir = '$_roomsDir/$roomId';
    await storage.deleteDirectory(roomDir, recursive: true);
  }

  @override
  Future<void> rename(String roomId, String newName) async {
    final room = await getById(roomId);
    final updatedRoom = room.copyWith(
      name: newName.trim(),
      updatedAt: DateTime.now().toUtc(),
    );
    await update(updatedRoom);
  }

  @override
  Future<bool> exists(String roomId) async {
    final roomDir = '$_roomsDir/$roomId';
    final metaPath = '$roomDir/$_metaFile';
    return storage.fileExists(metaPath);
  }

  /// Gets all room IDs by listing directories in rooms/
  Future<List<String>> _getAllRoomIds() async {
    try {
      final rootDirs = await storage.listDirectories('');
      if (!rootDirs.contains(_roomsDir)) return [];

      final roomDirs = await storage.listDirectories(_roomsDir);
      // Extract room IDs from directory paths
      return roomDirs
          .map((path) => path.split('/').last)
          .where((id) => id.isNotEmpty)
          .toList();
    } on DirectoryNotFoundException {
      // Base directory doesn't exist yet - no rooms
      return [];
    } catch (_) {
      return [];
    }
  }

  String _getMetaPath(String roomId) => '$_roomsDir/$roomId/$_metaFile';

  Room _roomFromJson(Map<String, dynamic> json) {
    final configJson = json['config'] as Map<String, dynamic>?;

    return Room(
      roomId: json['room_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isFinalized: json['is_finalized'] as bool? ?? false,
      roomConfig: configJson != null
          ? RoomConfig(
              maxTurnsDefault: configJson['max_turns_default'] as int? ?? 500,
              maxTurnsCurrent: configJson['max_turns_current'] as int? ?? 500,
              roomDelayMs: configJson['room_delay_ms'] as int? ?? 0,
              globalModel: configJson['global_model'] as String?,
            )
          : const RoomConfig(),
    );
  }

  Map<String, dynamic> _roomToJson(Room room) => {
        'schema_version': _version,
        'room_id': room.roomId,
        'name': room.name,
        'created_at': room.createdAt.toIso8601String(),
        'updated_at': room.updatedAt.toIso8601String(),
        'is_finalized': room.isFinalized,
        'config': {
          'max_turns_default': room.roomConfig.maxTurnsDefault,
          'max_turns_current': room.roomConfig.maxTurnsCurrent,
          'room_delay_ms': room.roomConfig.roomDelayMs,
          if (room.roomConfig.globalModel != null)
            'global_model': room.roomConfig.globalModel,
        },
      };
}
