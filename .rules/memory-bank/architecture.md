# Architecture

## System Overview

Workspace-based monorepo following Clean Architecture with feature-based organization.

```
sizzle_starter/
├── app/                      # Main Flutter application
│   └── lib/
│       ├── main.dart         # Entry point
│       └── src/
│           ├── logic/        # Composition, startup
│           ├── model/        # App config, DI container
│           ├── widget/       # Root widgets
│           └── bloc/         # BLoC utilities
├── core/                     # Infrastructure packages
│   ├── common/               # Shared utilities
│   ├── logger/               # Logging library
│   ├── rest_client/          # HTTP client abstraction
│   ├── filesystem_storage/   # File I/O abstraction
│   ├── llm_client/           # LLM API client
│   ├── session_scheduler/    # Turn orchestration
│   └── ui_library/           # Reusable UI components
└── feature/                  # Feature modules
    ├── home/                 # Main navigation shell
    ├── rooms/                # Room management
    ├── global_experts/       # Expert definitions
    └── settings/             # App preferences
```

## Initialization Flow

```
main() → startup()
  ├─ createAppLogger()
  ├─ runZonedGuarded() [error boundary]
  ├─ WidgetsFlutterBinding.ensureInitialized()
  ├─ Setup BLoC (observer, transformer)
  └─ composeDependencies()
       ├─ Phase 1: FilesystemStorage, LLMClient, RequestSemaphore
       ├─ Phase 2: GlobalExpertRepository
       └─ Phase 3: RoomRepository
```

## Dependency Injection

**Pattern**: Service Locator via InheritedWidget

```dart
// Container holds all dependencies
class DependenciesContainer {
  final Logger logger;
  final ApplicationConfig config;
  final FilesystemStorage filesystemStorage;
  final LLMClient llmClient;
  final RequestSemaphore requestSemaphore;
  final GlobalExpertRepository globalExpertRepository;
  final RoomRepository roomRepository;
  final SettingsContainer settingsContainer;
}

// Access anywhere via context
DependenciesScope.of(context).roomRepository
```

## Widget Tree

```
RootContext
└─ DependenciesScope (provides container)
   └─ WindowSizeScope
      └─ MaterialContext
         └─ MultiBlocProvider [RoomsBloc, GlobalExpertsBloc]
            └─ SettingsBuilder (reactive theme/locale)
               └─ MaterialApp
                  └─ HomeScreen (BottomNavigationBar)
                     ├─ RoomsScreen
                     ├─ GlobalExpertsScreen
                     └─ SettingsScreen
```

## State Management

**Pattern**: BLoC with sequential event processing

- `SequentialBlocTransformer`: Prevents race conditions by processing events one at a time
- `AppBlocObserver`: Logs all BLoC transitions for debugging

**Feature BLoCs**:
- `RoomsBloc`: CRUD operations for rooms
- `GlobalExpertsBloc`: CRUD operations for experts
- `SettingsService`: Stream-based reactive settings

## Data Flow

```
UI Widget
    ↓ (add event)
BLoC
    ↓ (call repository)
Repository
    ↓ (delegate to data source)
DataSource (Filesystem)
    ↓ (JSON read/write)
Storage
```

## Storage Structure

```
{app_documents}/
├── rooms/{roomId}/
│   ├── room_meta.json      # Room metadata & config
│   ├── current.json        # Current document state
│   ├── index.json          # Timeline index
│   └── snapshots/          # Version history
└── global_experts/
    └── index.json          # All experts in single file
```

## Key Design Patterns

1. **Repository Pattern**: Abstract data access behind interfaces
2. **BLoC Pattern**: Unidirectional data flow for state management
3. **Composition Root**: All dependencies wired at startup
4. **Platform Channels**: Platform-specific HTTP clients
5. **Error Boundary**: runZonedGuarded captures all errors

## Critical Implementation Paths

- **Room Creation**: `RoomsBloc.add(RoomCreateRequested)` → `RoomRepository.createRoom()` → `RoomFilesystemDataSource.createRoom()` → Write `room_meta.json`
- **Expert Loading**: `GlobalExpertsBloc.add(LoadRequested)` → `GlobalExpertRepository.getAllExperts()` → Read `index.json`
- **Settings Change**: `SettingsService.updateSettings()` → SharedPreferences → emit on stream → `SettingsBuilder` rebuilds
