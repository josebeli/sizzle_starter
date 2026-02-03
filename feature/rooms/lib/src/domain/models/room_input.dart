import 'package:meta/meta.dart';

/// {@template room_input}
/// Input data for creating a new room.
///
/// Contains validation logic to ensure data integrity
/// before creating a room.
/// {@endtemplate}
@immutable
final class RoomInput {
  /// {@macro room_input}
  const RoomInput({
    required this.name,
  });

  /// Room name provided by the user
  final String name;

  /// Validates the input and returns list of errors
  List<RoomValidationError> validate() {
    final errors = <RoomValidationError>[];

    if (name.trim().isEmpty) {
      errors.add(RoomValidationError.emptyName);
    }

    return errors;
  }

  /// Returns true if the input is valid
  bool get isValid => validate().isEmpty;

  /// Creates a copy with modified fields
  RoomInput copyWith({
    String? name,
  }) =>
      RoomInput(
        name: name ?? this.name,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomInput && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'RoomInput(name: $name)';
}

/// Validation errors for room input
enum RoomValidationError {
  /// Room name cannot be empty
  emptyName('Room name cannot be empty');

  /// Human-readable error message
  final String message;

  const RoomValidationError(this.message);
}
