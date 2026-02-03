import 'dart:convert';

import 'package:filesystem_storage/filesystem_storage.dart';

import 'package:global_experts/src/data/datasources/global_expert_local_ds.dart';
import 'package:global_experts/src/domain/models/global_expert.dart';

/// {@template global_expert_filesystem_datasource}
/// Filesystem-based implementation of [GlobalExpertLocalDataSource].
///
/// Stores experts in a single JSON file: `global_experts/index.json`
/// Structure:
/// ```json
/// {
///   "version": "1.0",
///   "experts": [
///     {
///       "expertId": "uuid",
///       "name": "Expert Name",
///       "systemPrompt": "...",
///       "model": "openai/gpt-4o"
///     }
///   ]
/// }
/// ```
/// {@endtemplate}
final class GlobalExpertFilesystemDataSource
    implements GlobalExpertLocalDataSource {
  /// {@macro global_expert_filesystem_datasource}
  const GlobalExpertFilesystemDataSource({
    required this.storage,
  });

  final FilesystemStorage storage;

  static const String _indexPath = 'global_experts/index.json';
  static const String _version = '1.0';

  @override
  Future<List<GlobalExpert>> getAll() async {
    final exists = await storage.fileExists(_indexPath);
    if (!exists) return [];

    final content = await storage.readFile(_indexPath);
    final json = jsonDecode(content) as Map<String, dynamic>;
    final expertsJson = json['experts'] as List<dynamic>;

    return expertsJson
        .map((e) => _expertFromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GlobalExpert> getById(String expertId) async {
    final experts = await getAll();
    final expert = experts.where((e) => e.expertId == expertId).firstOrNull;

    if (expert == null) {
      throw ExpertNotFoundException(expertId);
    }

    return expert;
  }

  @override
  Future<void> create(GlobalExpert expert) async {
    if (await exists(expert.expertId)) {
      throw ExpertAlreadyExistsException(expert.expertId);
    }

    final experts = await getAll();
    experts.add(expert);
    await _saveAll(experts);
  }

  @override
  Future<void> update(GlobalExpert expert) async {
    if (!await exists(expert.expertId)) {
      throw ExpertNotFoundException(expert.expertId);
    }

    final experts = await getAll();
    final index = experts.indexWhere((e) => e.expertId == expert.expertId);
    experts[index] = expert;
    await _saveAll(experts);
  }

  @override
  Future<void> delete(String expertId) async {
    if (!await exists(expertId)) {
      throw ExpertNotFoundException(expertId);
    }

    final experts = await getAll();
    experts.removeWhere((e) => e.expertId == expertId);
    await _saveAll(experts);
  }

  @override
  Future<bool> exists(String expertId) async {
    final experts = await getAll();
    return experts.any((e) => e.expertId == expertId);
  }

  Future<void> _saveAll(List<GlobalExpert> experts) async {
    final json = {
      'version': _version,
      'experts': experts.map(_expertToJson).toList(),
    };

    await storage.ensureDirectory('global_experts');
    await storage.writeFile(_indexPath, jsonEncode(json));
  }

  GlobalExpert _expertFromJson(Map<String, dynamic> json) => GlobalExpert(
        expertId: json['expertId'] as String,
        name: json['name'] as String,
        systemPrompt: json['systemPrompt'] as String,
        model: json['model'] as String?,
      );

  Map<String, dynamic> _expertToJson(GlobalExpert expert) => {
        'expertId': expert.expertId,
        'name': expert.name,
        'systemPrompt': expert.systemPrompt,
        if (expert.model != null) 'model': expert.model,
      };
}
