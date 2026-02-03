# Technology Stack

## Core Framework

- **Flutter**: >=3.35.3 <4.0.0
- **Dart**: >=3.9.2 <4.0.0

## State Management

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | 9.1.1 | BLoC pattern implementation |
| bloc_test | 10.0.0 | BLoC testing utilities |

## Storage & Persistence

| Package | Version | Purpose |
|---------|---------|---------|
| shared_preferences | ^2.5.4 | Key-value settings storage |
| path_provider | (via filesystem_storage) | Platform document paths |

**Custom Packages**:
- `filesystem_storage`: File I/O abstraction with platform-specific paths

## Networking

| Package | Purpose |
|---------|---------|
| http | Base HTTP client |
| cronet_http | Android-optimized HTTP |
| cupertino_http | iOS/macOS-optimized HTTP |

**Custom Packages**:
- `rest_client`: Platform-aware HTTP client abstraction
- `llm_client`: OpenRouter API client

## LLM Integration

- **Provider**: OpenRouter API
- **Base URL**: `https://openrouter.ai/api/v1`
- **Endpoint**: `POST /chat/completions`
- **Auth**: Bearer token
- **Retry**: 3 attempts with exponential backoff (1s, 2s)
- **Timeout**: Configurable (default 60s)

## Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| clock | 1.1.2 | Time utilities, test mocking |
| uuid | (latest) | UUID v4 generation |
| intl | 0.20.2 | Internationalization |
| package_info_plus | ^9.0.0 | App version info |

## Logging

**Custom Packages**:
- `logger`: Logging with observers

## Testing

| Package | Version | Purpose |
|---------|---------|---------|
| mocktail | 1.0.0 | Mocking library |
| bloc_test | 10.0.0 | BLoC testing |

## Development Setup

### Prerequisites
- Flutter SDK >=3.35.3
- Dart SDK >=3.9.2

### Environment Variables
```
ENVIRONMENT=DEV|STAGING|PROD    # App environment (default: PROD in release)
```

### Build Commands
```bash
# Get dependencies (workspace-aware)
flutter pub get

# Run app
flutter run

# Run tests
flutter test
```

### Platform Storage Paths
- **Windows**: `%USERPROFILE%/Documents/WhiteboardPlanner`
- **iOS/Android**: App private documents directory
- **macOS/Linux**: Application documents directory

## Technical Constraints

1. **Concurrency**: Max 3 concurrent LLM requests (configurable 1-10)
2. **Timeouts**: 60s default request timeout
3. **Storage**: Local filesystem only (no cloud sync)
4. **Offline**: Full offline support for UI, online required for LLM calls

## Dependencies Graph

```
app
├── core/common
├── core/logger
├── core/rest_client
├── core/filesystem_storage
├── core/llm_client
├── core/session_scheduler
├── core/ui_library
├── feature/home
├── feature/rooms
├── feature/global_experts
└── feature/settings
```
