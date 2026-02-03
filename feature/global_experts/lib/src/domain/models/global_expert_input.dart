import 'package:meta/meta.dart';

/// {@template global_expert_input}
/// Input data for creating or updating a global expert.
/// Used to validate user input before creating/updating entities.
/// {@endtemplate}
@immutable
final class GlobalExpertInput {
  /// {@macro global_expert_input}
  const GlobalExpertInput({
    required this.name,
    required this.systemPrompt,
    this.model,
  });

  final String name;
  final String systemPrompt;
  final String? model;

  /// Validates the input and returns a list of validation errors.
  /// Empty list means valid input.
  List<GlobalExpertValidationError> validate() {
    final errors = <GlobalExpertValidationError>[];

    if (name.trim().isEmpty) {
      errors.add(GlobalExpertValidationError.emptyName);
    }

    if (systemPrompt.trim().isEmpty) {
      errors.add(GlobalExpertValidationError.emptyPrompt);
    }

    return errors;
  }

  /// Returns true if the input is valid
  bool get isValid => validate().isEmpty;

  GlobalExpertInput copyWith({
    String? name,
    String? systemPrompt,
    String? model,
  }) =>
      GlobalExpertInput(
        name: name ?? this.name,
        systemPrompt: systemPrompt ?? this.systemPrompt,
        model: model ?? this.model,
      );
}

/// Validation errors for GlobalExpertInput
enum GlobalExpertValidationError {
  emptyName('Name cannot be empty'),
  emptyPrompt('System prompt cannot be empty');

  const GlobalExpertValidationError(this.message);
  final String message;
}
