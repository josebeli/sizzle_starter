import 'package:global_experts/src/domain/models/global_expert.dart';

/// {@template global_expert_local_datasource}
/// Interface for local storage of global experts.
/// Abstracts the persistence mechanism from the repository.
/// {@endtemplate}
abstract interface class GlobalExpertLocalDataSource {
  /// {@macro global_expert_local_datasource}
  const GlobalExpertLocalDataSource();

  /// Gets all global experts
  Future<List<GlobalExpert>> getAll();

  /// Gets a single expert by ID
  /// Throws [ExpertNotFoundException] if not found
  Future<GlobalExpert> getById(String expertId);

  /// Saves a new expert
  /// Throws [ExpertAlreadyExistsException] if ID already exists
  Future<void> create(GlobalExpert expert);

  /// Updates an existing expert
  /// Throws [ExpertNotFoundException] if not found
  Future<void> update(GlobalExpert expert);

  /// Deletes an expert by ID
  /// Throws [ExpertNotFoundException] if not found
  Future<void> delete(String expertId);

  /// Checks if an expert with the given ID exists
  Future<bool> exists(String expertId);
}

/// Exception thrown when an expert is not found
final class ExpertNotFoundException implements Exception {
  const ExpertNotFoundException(this.expertId);
  final String expertId;

  @override
  String toString() => 'ExpertNotFoundException: Expert $expertId not found';
}

/// Exception thrown when trying to create an expert with duplicate ID
final class ExpertAlreadyExistsException implements Exception {
  const ExpertAlreadyExistsException(this.expertId);
  final String expertId;

  @override
  String toString() =>
      'ExpertAlreadyExistsException: Expert $expertId already exists';
}
