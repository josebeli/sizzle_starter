import 'package:meta/meta.dart';

/// {@template room_config}
/// Configuration for a room/session.
///
/// Contains mutable settings that control room behavior like
/// max turns, delays, and default model selection.
/// {@endtemplate}
@immutable
final class RoomConfig {
  /// {@macro room_config}
  const RoomConfig({
    this.maxTurnsDefault = 500,
    this.maxTurnsCurrent = 500,
    this.roomDelayMs = 0,
    this.globalModel,
  })  : assert(maxTurnsDefault >= 1, 'maxTurnsDefault must be >= 1'),
        assert(maxTurnsCurrent >= 1, 'maxTurnsCurrent must be >= 1'),
        assert(roomDelayMs >= 0, 'roomDelayMs must be >= 0');

  /// Default maximum number of turns for the room [1..10000]
  final int maxTurnsDefault;

  /// Current maximum number of turns [1..10000]
  final int maxTurnsCurrent;

  /// Delay between turns in milliseconds [0..60000]
  final int roomDelayMs;

  /// Global model identifier (e.g., "openai/gpt-4o")
  /// Null means use system default
  final String? globalModel;

  /// Creates a copy with modified fields
  RoomConfig copyWith({
    int? maxTurnsDefault,
    int? maxTurnsCurrent,
    int? roomDelayMs,
    String? globalModel,
  }) =>
      RoomConfig(
        maxTurnsDefault: maxTurnsDefault ?? this.maxTurnsDefault,
        maxTurnsCurrent: maxTurnsCurrent ?? this.maxTurnsCurrent,
        roomDelayMs: roomDelayMs ?? this.roomDelayMs,
        globalModel: globalModel ?? this.globalModel,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomConfig &&
        other.maxTurnsDefault == maxTurnsDefault &&
        other.maxTurnsCurrent == maxTurnsCurrent &&
        other.roomDelayMs == roomDelayMs &&
        other.globalModel == globalModel;
  }

  @override
  int get hashCode => Object.hash(
        maxTurnsDefault,
        maxTurnsCurrent,
        roomDelayMs,
        globalModel,
      );

  /// Converts this config to a JSON map.
  Map<String, dynamic> toJson() => {
    'maxTurnsDefault': maxTurnsDefault,
    'maxTurnsCurrent': maxTurnsCurrent,
    'roomDelayMs': roomDelayMs,
    'globalModel': globalModel,
  };

  /// Creates a [RoomConfig] from a JSON map.
  factory RoomConfig.fromJson(Map<String, dynamic> json) => RoomConfig(
    maxTurnsDefault: json['maxTurnsDefault'] as int? ?? 500,
    maxTurnsCurrent: json['maxTurnsCurrent'] as int? ?? 500,
    roomDelayMs: json['roomDelayMs'] as int? ?? 0,
    globalModel: json['globalModel'] as String?,
  );

  @override
  String toString() =>
      'RoomConfig(maxTurnsDefault: $maxTurnsDefault, maxTurnsCurrent: $maxTurnsCurrent, roomDelayMs: $roomDelayMs, globalModel: $globalModel)';
}
