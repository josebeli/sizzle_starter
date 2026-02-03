import 'package:flutter_test/flutter_test.dart';
import 'package:rooms/rooms.dart';

void main() {
  group('Room', () {
    final createdAt = DateTime(2026, 1, 1, 12, 0);
    final updatedAt = DateTime(2026, 1, 15, 14, 30);
    const testConfig = RoomConfig(
      maxTurnsDefault: 10,
      maxTurnsCurrent: 10,
      roomDelayMs: 1000,
    );

    final room = Room(
      roomId: 'test-room-id',
      name: 'Test Room',
      createdAt: createdAt,
      updatedAt: updatedAt,
      isFinalized: false,
      roomConfig: testConfig,
    );

    test('can be instantiated', () {
      expect(room, isNotNull);
      expect(room.roomId, 'test-room-id');
      expect(room.name, 'Test Room');
      expect(room.createdAt, createdAt);
      expect(room.updatedAt, updatedAt);
      expect(room.isFinalized, false);
      expect(room.roomConfig, testConfig);
    });

    test('can be instantiated with finalized=true', () {
      final finalizedRoom = Room(
        roomId: 'test-room-id-2',
        name: 'Test Room 2',
        createdAt: createdAt,
        updatedAt: updatedAt,
        isFinalized: true,
        roomConfig: testConfig,
      );

      expect(finalizedRoom.isFinalized, true);
    });

    group('copyWith', () {
      test('returns new instance with same values when no args', () {
        final copied = room.copyWith();

        expect(copied.roomId, room.roomId);
        expect(copied.name, room.name);
        expect(copied.createdAt, room.createdAt);
        expect(copied.updatedAt, room.updatedAt);
        expect(copied.isFinalized, room.isFinalized);
        expect(copied.roomConfig, room.roomConfig);
      });

      test('returns new instance with updated name', () {
        final copied = room.copyWith(name: 'Updated Room Name');

        expect(copied.roomId, room.roomId);
        expect(copied.name, 'Updated Room Name');
        expect(copied.isFinalized, room.isFinalized);
      });

      test('returns new instance with updated isFinalized', () {
        final copied = room.copyWith(isFinalized: true);

        expect(copied.isFinalized, true);
        expect(copied.name, room.name);
      });

      test('returns new instance with updated updatedAt', () {
        final newUpdatedAt = DateTime(2026, 2, 1, 10, 0);
        final copied = room.copyWith(updatedAt: newUpdatedAt);

        expect(copied.updatedAt, newUpdatedAt);
        expect(copied.roomId, room.roomId);
      });
    });

    group('toJson/fromJson', () {
      test('converts to JSON correctly', () {
        final json = room.toJson();

        expect(json['roomId'], 'test-room-id');
        expect(json['name'], 'Test Room');
        expect(json['isFinalized'], false);
        expect(json['roomConfig'], isA<Map<String, dynamic>>());
      });

      test('converts from JSON correctly', () {
        final json = {
          'roomId': 'test-room-id',
          'name': 'Test Room',
          'createdAt': '2026-01-01T12:00:00.000Z',
          'updatedAt': '2026-01-15T14:30:00.000Z',
          'isFinalized': false,
          'roomConfig': {
            'maxTurnsDefault': 10,
            'maxTurnsCurrent': 10,
            'roomDelayMs': 1000,
          },
        };

        final decoded = Room.fromJson(json);

        expect(decoded.roomId, 'test-room-id');
        expect(decoded.name, 'Test Room');
        expect(decoded.isFinalized, false);
        expect(decoded.roomConfig.maxTurnsDefault, 10);
      });
    });
  });

  group('RoomConfig', () {
    test('can be instantiated', () {
      const config = RoomConfig(
        maxTurnsDefault: 10,
        maxTurnsCurrent: 10,
        roomDelayMs: 1000,
        globalModel: 'gpt-4',
      );

      expect(config.maxTurnsDefault, 10);
      expect(config.maxTurnsCurrent, 10);
      expect(config.roomDelayMs, 1000);
      expect(config.globalModel, 'gpt-4');
    });

    test('copyWith works correctly', () {
      const config = RoomConfig(
        maxTurnsDefault: 10,
        maxTurnsCurrent: 10,
        roomDelayMs: 1000,
      );

      final updated = config.copyWith(maxTurnsCurrent: 5);

      expect(updated.maxTurnsDefault, 10);
      expect(updated.maxTurnsCurrent, 5);
    });

    test('toJson/fromJson works correctly', () {
      const config = RoomConfig(
        maxTurnsDefault: 10,
        maxTurnsCurrent: 10,
        roomDelayMs: 1000,
        globalModel: 'gpt-4',
      );

      final json = config.toJson();
      final decoded = RoomConfig.fromJson(json);

      expect(decoded, config);
    });
  });

  group('RoomInput', () {
    test('can be instantiated', () {
      const input = RoomInput(name: 'New Room');

      expect(input.name, 'New Room');
    });

    test('copyWith works correctly', () {
      const input = RoomInput(name: 'Original');
      final updated = input.copyWith(name: 'Updated');

      expect(updated.name, 'Updated');
    });
  });
}
