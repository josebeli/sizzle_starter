import 'package:meta/meta.dart';

/// {@template global_expert}
/// Entity representing a global expert profile.
///
/// Global experts are reusable templates that can be imported into rooms.
/// They contain the expert's name, system prompt, and preferred model.
/// {@endtemplate}
@immutable
final class GlobalExpert {
  /// {@macro global_expert}
  const GlobalExpert({
    required this.expertId,
    required this.name,
    required this.systemPrompt,
    this.model,
  });

  /// Unique identifier (UUID v4)
  final String expertId;

  /// Display name of the expert
  final String name;

  /// System prompt that defines the expert's behavior
  final String systemPrompt;

  /// OpenRouter model identifier (e.g., "openai/gpt-4o")
  /// Null means use room's default model
  final String? model;

  /// Creates a copy with modified fields
  GlobalExpert copyWith({
    String? expertId,
    String? name,
    String? systemPrompt,
    String? model,
  }) =>
      GlobalExpert(
        expertId: expertId ?? this.expertId,
        name: name ?? this.name,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        model: model ?? this.model,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalExpert &&
        other.expertId == expertId &&
        other.name == name &&
        other.systemPrompt == systemPrompt &&
        other.model == model;
  }

  @override
  int get hashCode => Object.hash(expertId, name, systemPrompt, model);

  @override
  String toString() =>
      'GlobalExpert(expertId: $expertId, name: $name, model: $model)';
}
