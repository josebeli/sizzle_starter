import 'package:meta/meta.dart';

import 'package:global_experts/src/domain/models/global_expert.dart';

/// {@template global_experts_state}
/// Base class for all GlobalExpertsBloc states.
/// {@endtemplate}
@immutable
sealed class GlobalExpertsState {
  const GlobalExpertsState();
}

/// Initial/loading state
final class GlobalExpertsLoading extends GlobalExpertsState {
  const GlobalExpertsLoading();
}

/// Loaded state with list of experts
final class GlobalExpertsLoaded extends GlobalExpertsState {
  const GlobalExpertsLoaded(this.experts);

  final List<GlobalExpert> experts;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalExpertsLoaded &&
        other.experts.length == experts.length &&
        other.experts.every(experts.contains);
  }

  @override
  int get hashCode => Object.hashAll(experts);
}

/// Error state
final class GlobalExpertsError extends GlobalExpertsState {
  const GlobalExpertsError(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GlobalExpertsError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Success state after operation
final class GlobalExpertsOperationSuccess extends GlobalExpertsState {
  const GlobalExpertsOperationSuccess({
    required this.operation,
    required this.experts,
  });

  final GlobalExpertOperation operation;
  final List<GlobalExpert> experts;
}

enum GlobalExpertOperation {
  created,
  updated,
  deleted,
}
