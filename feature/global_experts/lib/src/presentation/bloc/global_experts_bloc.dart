import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:global_experts/src/data/datasources/global_expert_local_ds.dart';
import 'package:global_experts/src/data/repositories/global_expert_repo.dart';
import 'package:global_experts/src/domain/models/global_expert.dart';
import 'package:global_experts/src/presentation/bloc/global_experts_event.dart';
import 'package:global_experts/src/presentation/bloc/global_experts_state.dart';

export 'global_experts_event.dart';
export 'global_experts_state.dart';

/// {@template global_experts_bloc}
/// BLoC for managing global experts.
///
/// Handles CRUD operations and emits appropriate states.
/// {@endtemplate}
class GlobalExpertsBloc extends Bloc<GlobalExpertsEvent, GlobalExpertsState> {
  /// {@macro global_experts_bloc}
  GlobalExpertsBloc({
    required this.repository,
  }) : super(const GlobalExpertsLoading()) {
    on<GlobalExpertsLoadRequested>(_onLoadRequested);
    on<GlobalExpertCreateRequested>(_onCreateRequested);
    on<GlobalExpertUpdateRequested>(_onUpdateRequested);
    on<GlobalExpertDeleteRequested>(_onDeleteRequested);
  }

  final GlobalExpertRepository repository;

  Future<void> _onLoadRequested(
    GlobalExpertsLoadRequested event,
    Emitter<GlobalExpertsState> emit,
  ) async {
    emit(const GlobalExpertsLoading());

    try {
      final experts = await repository.getAllExperts();
      emit(GlobalExpertsLoaded(experts));
    } catch (e) {
      emit(GlobalExpertsError('Failed to load experts: $e'));
    }
  }

  Future<void> _onCreateRequested(
    GlobalExpertCreateRequested event,
    Emitter<GlobalExpertsState> emit,
  ) async {
    // Validate input
    final errors = event.input.validate();
    if (errors.isNotEmpty) {
      emit(GlobalExpertsError(errors.first.message));
      return;
    }

    emit(const GlobalExpertsLoading());

    try {
      await repository.createExpert(event.input);
      final experts = await repository.getAllExperts();
      emit(GlobalExpertsOperationSuccess(
        operation: GlobalExpertOperation.created,
        experts: experts,
      ));
    } catch (e) {
      emit(GlobalExpertsError('Failed to create expert: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    GlobalExpertUpdateRequested event,
    Emitter<GlobalExpertsState> emit,
  ) async {
    // Validate input
    final errors = event.input.validate();
    if (errors.isNotEmpty) {
      emit(GlobalExpertsError(errors.first.message));
      return;
    }

    emit(const GlobalExpertsLoading());

    try {
      await repository.updateExpert(event.expertId, event.input);
      final experts = await repository.getAllExperts();
      emit(GlobalExpertsOperationSuccess(
        operation: GlobalExpertOperation.updated,
        experts: experts,
      ));
    } on ExpertNotFoundException {
      emit(const GlobalExpertsError('Expert not found'));
    } catch (e) {
      emit(GlobalExpertsError('Failed to update expert: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    GlobalExpertDeleteRequested event,
    Emitter<GlobalExpertsState> emit,
  ) async {
    emit(const GlobalExpertsLoading());

    try {
      await repository.deleteExpert(event.expertId);
      final experts = await repository.getAllExperts();
      emit(GlobalExpertsOperationSuccess(
        operation: GlobalExpertOperation.deleted,
        experts: experts,
      ));
    } on ExpertNotFoundException {
      emit(const GlobalExpertsError('Expert not found'));
    } catch (e) {
      emit(GlobalExpertsError('Failed to delete expert: $e'));
    }
  }
}
