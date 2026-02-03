import 'package:filesystem_storage/filesystem_storage.dart';
import 'package:global_experts/global_experts.dart';
import 'package:llm_client/llm_client.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rooms/rooms.dart';
import 'package:session_scheduler/session_scheduler.dart';
import 'package:settings/settings.dart';
import 'package:whiteboard_planner/src/model/application_config.dart';

/// Container for global dependencies.
class DependenciesContainer {
  const DependenciesContainer({
    required this.logger,
    required this.config,
    required this.packageInfo,
    required this.settingsContainer,
    required this.pathResolver,
    required this.filesystemStorage,
    required this.llmClient,
    required this.requestSemaphore,
    required this.globalExpertRepository,
    required this.roomRepository,
  });

  final Logger logger;
  final ApplicationConfig config;
  final PackageInfo packageInfo;
  final SettingsContainer settingsContainer;

  // Fase 1: Core packages
  final PathResolver pathResolver;
  final FilesystemStorage filesystemStorage;
  final LLMClient llmClient;
  final RequestSemaphore requestSemaphore;

  // Fase 2: Global Experts
  final GlobalExpertRepository globalExpertRepository;

  // Fase 3: Rooms
  final RoomRepository roomRepository;
}

/// A special version of [DependenciesContainer] that is used in tests.
///
/// In order to use [DependenciesContainer] in tests, it is needed to
/// extend this class and provide the dependencies that are needed for the test.
base class TestDependenciesContainer implements DependenciesContainer {
  const TestDependenciesContainer();

  @override
  Object noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'The test tries to access ${invocation.memberName} dependency, but '
      'it was not provided. Please provide the dependency in the test. '
      'You can do it by extending this class and providing the dependency.',
    );
  }
}
