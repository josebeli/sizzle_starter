import 'package:meta/meta.dart';

import 'package:global_experts/src/domain/models/global_expert_input.dart';

/// {@template global_experts_event}
/// Base class for all GlobalExpertsBloc events.
/// {@endtemplate}
@immutable
sealed class GlobalExpertsEvent {
  const GlobalExpertsEvent();
}

/// Load all global experts
final class GlobalExpertsLoadRequested extends GlobalExpertsEvent {
  const GlobalExpertsLoadRequested();
}

/// Create a new expert
final class GlobalExpertCreateRequested extends GlobalExpertsEvent {
  const GlobalExpertCreateRequested(this.input);

  final GlobalExpertInput input;
}

/// Update an existing expert
final class GlobalExpertUpdateRequested extends GlobalExpertsEvent {
  const GlobalExpertUpdateRequested({
    required this.expertId,
    required this.input,
  });

  final String expertId;
  final GlobalExpertInput input;
}

/// Delete an expert
final class GlobalExpertDeleteRequested extends GlobalExpertsEvent {
  const GlobalExpertDeleteRequested(this.expertId);

  final String expertId;
}
