import 'package:clock/clock.dart';
import 'package:filesystem_storage/filesystem_storage.dart';
import 'package:global_experts/global_experts.dart';
import 'package:llm_client/llm_client.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_client/rest_client.dart';
import 'package:rooms/rooms.dart';
import 'package:session_scheduler/session_scheduler.dart';
import 'package:settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whiteboard_planner/src/model/application_config.dart';
import 'package:whiteboard_planner/src/model/dependencies_container.dart';

/// A place where Application-Wide dependencies are initialized.
///
/// Application-Wide dependencies are dependencies that have a global scope,
/// used in the entire application and have a lifetime that is the same as the application.
/// Composes dependencies and returns the result of composition.
Future<CompositionResult> composeDependencies({
  required ApplicationConfig config,
  required Logger logger,
}) async {
  final stopwatch = clock.stopwatch()..start();

  logger.info('Initializing dependencies...');

  // Create the dependencies container using functions.
  final dependencies = await createDependenciesContainer(config, logger);

  stopwatch.stop();
  logger.info('Dependencies initialized successfully in ${stopwatch.elapsedMilliseconds} ms.');

  return CompositionResult(
    dependencies: dependencies,
    millisecondsSpent: stopwatch.elapsedMilliseconds,
  );
}

final class CompositionResult {
  const CompositionResult({required this.dependencies, required this.millisecondsSpent});

  final DependenciesContainer dependencies;
  final int millisecondsSpent;

  @override
  String toString() =>
      'CompositionResult('
      'dependencies: $dependencies, '
      'millisecondsSpent: $millisecondsSpent'
      ')';
}

/// Creates the initialized [DependenciesContainer].
Future<DependenciesContainer> createDependenciesContainer(
  ApplicationConfig config,
  Logger logger,
) async {
  // Create or obtain the shared preferences instance.
  final sharedPreferences = SharedPreferencesAsync();

  // Get package info.
  final packageInfo = await PackageInfo.fromPlatform();
  final settingsContainer = await SettingsContainer.create(sharedPreferences: sharedPreferences);

  // FASE 1: Filesystem Storage
  final pathResolver = await PathResolver.initialize();
  final filesystemStorage = IOFilesystemStorage(
    pathResolver: pathResolver,
    logger: logger,
  );

  // Ensure base directory exists (required for first run)
  await filesystemStorage.ensureDirectory('');

  // FASE 1: LLM Client
  final restClient = RestClientHttp(
    baseUrl: 'https://openrouter.ai/api/v1',
  );

  // Get LLM settings from settings container (defaults for now)
  const llmSettings = LLMSettings();

  final llmClient = OpenRouterClient(
    restClient: restClient,
    settings: llmSettings,
    logger: logger,
  );

  // FASE 1: Request Semaphore (singleton global)
  final requestSemaphore = RequestSemaphore(
    maxConcurrent: llmSettings.maxConcurrentRequests,
  );

  // FASE 2: Global Experts
  final globalExpertDataSource = GlobalExpertFilesystemDataSource(
    storage: filesystemStorage,
  );
  final globalExpertRepository = GlobalExpertRepositoryImpl(
    localDataSource: globalExpertDataSource,
  );

  // FASE 3: Rooms
  final roomDataSource = RoomFilesystemDataSource(
    storage: filesystemStorage,
  );
  final roomRepository = RoomRepositoryImpl(
    localDataSource: roomDataSource,
  );

  return DependenciesContainer(
    logger: logger,
    config: config,
    packageInfo: packageInfo,
    settingsContainer: settingsContainer,
    pathResolver: pathResolver,
    filesystemStorage: filesystemStorage,
    llmClient: llmClient,
    requestSemaphore: requestSemaphore,
    globalExpertRepository: globalExpertRepository,
    roomRepository: roomRepository,
  );
}

/// Creates the [Logger] instance and attaches any provided observers.
Logger createAppLogger({List<LogObserver> observers = const []}) {
  final logger = Logger();

  for (final observer in observers) {
    logger.addObserver(observer);
  }

  return logger;
}
