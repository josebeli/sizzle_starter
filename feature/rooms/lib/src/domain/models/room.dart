import 'package:meta/meta.dart';
import 'package:rooms/src/domain/models/room_config.dart';

/// {@template room}
/// Entity representing a chat room/session.
/// {@endtemplate}
@immutable
final class Room {
  /// {@macro room}
  const Room({
    required this.roomId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isFinalized,
    required this.roomConfig,
  });

  /// Unique identifier for the room (UUID v4).
  final String roomId;

  /// Display name of the room.
  final String name;

  /// When the room was created.
  final DateTime createdAt;

  /// When the room was last updated.
  final DateTime updatedAt;

  /// Whether the room is finalized (archived).
  final bool isFinalized;

  /// Configuration for this room.
  final RoomConfig roomConfig;

  /// Creates a copy of this room with the given fields replaced.
  Room copyWith({
    String? name,
    DateTime? updatedAt,
    bool? isFinalized,
    RoomConfig? roomConfig,
  }) =>
      Room(
        roomId: roomId,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isFinalized: isFinalized ?? this.isFinalized,
        roomConfig: roomConfig ?? this.roomConfig,
      );

  /// Converts this room to a JSON map.
  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'name': name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'isFinalized': isFinalized,
    'roomConfig': roomConfig.toJson(),
  };

  /// Creates a [Room] from a JSON map.
  factory Room.fromJson(Map<String, dynamic> json) => Room(
    roomId: json['roomId'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    isFinalized: json['isFinalized'] as bool,
    roomConfig: RoomConfig.fromJson(json['roomConfig'] as Map<String, dynamic>),
  );

  @override
  String toString() =>
      'Room(roomId: $roomId, name: $name, isFinalized: $isFinalized)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.roomId == roomId;
  }

  @override
  int get hashCode => roomId.hashCode;
}
