import 'package:uuid/uuid.dart';

import 'package:global_experts/src/data/datasources/global_expert_local_ds.dart';
import 'package:global_experts/src/domain/models/global_expert.dart';
import 'package:global_experts/src/domain/models/global_expert_input.dart';

/// {@template global_expert_repository}
/// Repository for managing global experts.
///
/// Acts as an abstraction layer between the domain and data layers,
/// handling UUID generation and coordinating data source operations.
/// {@endtemplate}
abstract interface class GlobalExpertRepository {
  /// Gets all global experts
  Future<List<GlobalExpert>> getAllExperts();

  /// Gets a single expert by ID
  Future<GlobalExpert?> getExpert(String expertId);

  /// Creates a new expert from input data
  /// Returns the created expert with generated UUID
  Future<GlobalExpert> createExpert(GlobalExpertInput input);

  /// Updates an existing expert
  Future<void> updateExpert(String expertId, GlobalExpertInput input);

  /// Deletes an expert
  Future<void> deleteExpert(String expertId);

  /// Checks if an expert exists
  Future<bool> expertExists(String expertId);
}

/// {@macro global_expert_repository}
final class GlobalExpertRepositoryImpl implements GlobalExpertRepository {
  /// {@macro global_expert_repository}
  const GlobalExpertRepositoryImpl({
    required this.localDataSource,
    this.uuid = const Uuid(),
  });

  final GlobalExpertLocalDataSource localDataSource;
  final Uuid uuid;

  @override
  Future<List<GlobalExpert>> getAllExperts() => localDataSource.getAll();

  @override
  Future<GlobalExpert?> getExpert(String expertId) async {
    try {
      return await localDataSource.getById(expertId);
    } on ExpertNotFoundException {
      return null;
    }
  }

  @override
  Future<GlobalExpert> createExpert(GlobalExpertInput input) async {
    final expert = GlobalExpert(
      expertId: uuid.v4(),
      name: input.name.trim(),
      systemPrompt: input.systemPrompt.trim(),
      model: input.model?.trim(),
    );

    await localDataSource.create(expert);
    return expert;
  }

  @override
  Future<void> updateExpert(String expertId, GlobalExpertInput input) async {
    final existing = await localDataSource.getById(expertId);

    final updated = existing.copyWith(
      name: input.name.trim(),
      systemPrompt: input.systemPrompt.trim(),
      model: input.model?.trim(),
    );

    await localDataSource.update(updated);
  }

  @override
  Future<void> deleteExpert(String expertId) =>
      localDataSource.delete(expertId);

  @override
  Future<bool> expertExists(String expertId) => localDataSource.exists(expertId);
}
