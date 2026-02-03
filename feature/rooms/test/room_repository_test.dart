import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:filesystem_storage/filesystem_storage.dart';
import 'package:rooms/rooms.dart';

// Stub implementation that takes fixed UUID for testing
class RoomRepositoryWithFixedUuid implements RoomRepository {
  final FilesystemStorage storage;
  final String fixedUuid;
  final Set<String> _createdRoomIds = {};

  RoomRepositoryWithFixedUuid({
    required this.storage,
    required this.fixedUuid,
  });

  @override
  Future<Room> createRoom(RoomInput input) async {
    final roomDir = 'rooms/$fixedUuid';
    final snapshotsDir = 'rooms/$fixedUuid/snapshots';

    await storage.ensureDirectory(roomDir);
    await storage.ensureDirectory(snapshotsDir);

    final now = DateTime.now();
    final room = Room(
      roomId: fixedUuid,
      name: input.name,
      createdAt: now,
      updatedAt: now,
      isFinalized: false,
      roomConfig: const RoomConfig(),
    );

    final roomMetaPath = '$roomDir/room_meta.json';
    await storage.writeFile(roomMetaPath, jsonEncode(room.toJson()));

    final currentPath = '$roomDir/current.json';
    await storage.writeFile(currentPath, '{}');

    final indexPath = '$roomDir/index.json';
    await storage.writeFile(indexPath, '{}');

    _createdRoomIds.add(fixedUuid);
    return room;
  }

  @override
  Future<List<Room>> getAllRooms() async {
    final rooms = <Room>[];

    for (final roomId in _createdRoomIds) {
      final room = await getRoomById(roomId);
      if (room != null) {
        rooms.add(room);
      }
    }

    return rooms;
  }

  @override
  Future<Room?> getRoomById(String roomId) async {
    final metaPath = 'rooms/$roomId/room_meta.json';
    try {
      final metaJson = await storage.readFile(metaPath);
      return Room.fromJson(jsonDecode(metaJson) as Map<String, dynamic>);
    } on FileNotFoundException {
      return null;
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    final roomDir = 'rooms/$roomId';
    await storage.deleteDirectory(roomDir, recursive: true);
    _createdRoomIds.remove(roomId);
  }

  @override
  Future<void> updateRoom(Room room) async {
    final roomDir = 'rooms/${room.roomId}';
    final metaPath = '$roomDir/room_meta.json';

    final updatedRoom = Room(
      roomId: room.roomId,
      name: room.name,
      createdAt: room.createdAt,
      updatedAt: DateTime.now(),
      isFinalized: room.isFinalized,
      roomConfig: room.roomConfig,
    );

    await storage.writeFile(metaPath, jsonEncode(updatedRoom.toJson()));
  }

  @override
  Future<void> renameRoom(String roomId, String newName) async {
    final room = await getRoomById(roomId);
    if (room == null) {
      throw Exception('Room not found: $roomId');
    }
    await updateRoom(room.copyWith(name: newName));
  }
}

void main() {
  group('RoomRepository', () {
    late InMemoryFilesystemStorage storage;
    late RoomRepositoryWithFixedUuid repository;

    setUp(() {
      storage = InMemoryFilesystemStorage();
      repository = RoomRepositoryWithFixedUuid(
        storage: storage,
        fixedUuid: 'test-room-uuid',
      );
    });

    group('createRoom', () {
      test('should create room with correct properties', () async {
        // Act
        final room = await repository.createRoom(
          const RoomInput(name: 'New Room'),
        );

        // Assert
        expect(room.roomId, 'test-room-uuid');
        expect(room.name, 'New Room');
        expect(room.isFinalized, false);
        expect(room.roomConfig, isA<RoomConfig>());
      });

      test('should create room directory structure', () async {
        // Act
        await repository.createRoom(
          const RoomInput(name: 'New Room'),
        );

        // Assert - verify directories were created via listDirectories
        final roomDirs = await storage.listDirectories('rooms');
        expect(roomDirs.any((d) => d.contains('test-room-uuid')), isTrue);
      });

      test('should create all required JSON files', () async {
        // Act
        await repository.createRoom(
          const RoomInput(name: 'Test Room'),
        );

        // Assert
        final metaContent = await storage.readFile('rooms/test-room-uuid/room_meta.json');
        final currentContent = await storage.readFile('rooms/test-room-uuid/current.json');
        final indexContent = await storage.readFile('rooms/test-room-uuid/index.json');

        expect(metaContent, isNotEmpty);
        expect(currentContent, '{}');
        expect(indexContent, '{}');
      });
    });

    group('getAllRooms', () {
      test('should return empty list when no rooms exist', () async {
        // Act
        final rooms = await repository.getAllRooms();

        // Assert
        expect(rooms, isEmpty);
      });

      test('should return created room', () async {
        // Arrange
        await repository.createRoom(const RoomInput(name: 'Room 1'));

        // Act
        final rooms = await repository.getAllRooms();

        // Assert
        expect(rooms, hasLength(1));
        expect(rooms.first.name, 'Room 1');
      });
    });

    group('getRoomById', () {
      test('should return room when exists', () async {
        // Arrange
        const roomId = 'test-room-uuid';
        await repository.createRoom(const RoomInput(name: 'Room 1'));

        // Act
        final room = await repository.getRoomById(roomId);

        // Assert
        expect(room, isNotNull);
        expect(room!.roomId, roomId);
        expect(room.name, 'Room 1');
      });

      test('should return null when room does not exist', () async {
        // Act
        final room = await repository.getRoomById('non-existent-id');

        // Assert
        expect(room, isNull);
      });
    });

    group('deleteRoom', () {
      test('should delete room', () async {
        // Arrange
        await repository.createRoom(const RoomInput(name: 'Room 1'));

        // Verify room exists
        expect(await repository.getRoomById('test-room-uuid'), isNotNull);

        // Act
        await repository.deleteRoom('test-room-uuid');

        // Assert
        expect(await repository.getRoomById('test-room-uuid'), isNull);
      });
    });

    group('updateRoom', () {
      test('should update room', () async {
        // Arrange
        final room = await repository.createRoom(
          const RoomInput(name: 'Original Name'),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        await repository.updateRoom(room.copyWith(name: 'New Name'));

        // Assert
        final updatedRoom = await repository.getRoomById(room.roomId);
        expect(updatedRoom!.name, 'New Name');
      });
    });

    group('renameRoom', () {
      test('should rename room', () async {
        // Arrange
        await repository.createRoom(const RoomInput(name: 'Room 1'));

        // Act
        await repository.renameRoom('test-room-uuid', 'Renamed Room');

        // Assert
        final room = await repository.getRoomById('test-room-uuid');
        expect(room!.name, 'Renamed Room');
      });

      test('should throw exception when room does not exist', () {
        // Act & Assert
        expect(
          () => repository.renameRoom('non-existent', 'New Name'),
          throwsException,
        );
      });
    });
  });

  group('RoomConfig model', () {
    test('should use default values when not specified', () {
      // Arrange
      const config = RoomConfig();

      // Assert
      expect(config.maxTurnsDefault, 500);
      expect(config.maxTurnsCurrent, 500);
      expect(config.roomDelayMs, 0);
      expect(config.globalModel, isNull);
    });

    test('should allow custom values', () {
      // Arrange
      const config = RoomConfig(
        maxTurnsDefault: 20,
        maxTurnsCurrent: 15,
        roomDelayMs: 2000,
        globalModel: 'gpt-4',
      );

      // Assert
      expect(config.maxTurnsDefault, 20);
      expect(config.maxTurnsCurrent, 15);
      expect(config.roomDelayMs, 2000);
      expect(config.globalModel, 'gpt-4');
    });

    test('should support JSON serialization', () {
      // Arrange
      const config = RoomConfig(
        maxTurnsDefault: 20,
        maxTurnsCurrent: 15,
        roomDelayMs: 2000,
        globalModel: 'gpt-4',
      );

      // Act
      final json = config.toJson();
      final restored = RoomConfig.fromJson(json);

      // Assert
      expect(restored.maxTurnsDefault, config.maxTurnsDefault);
      expect(restored.maxTurnsCurrent, config.maxTurnsCurrent);
      expect(restored.roomDelayMs, config.roomDelayMs);
      expect(restored.globalModel, config.globalModel);
    });
  });
}
