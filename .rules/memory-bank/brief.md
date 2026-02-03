# Whiteboard Planner

A multiplatform Flutter application for orchestrating multiple Large Language Models (LLMs) in collaborative planning sessions.

## Objective

Enable users to manage AI experts and rooms for coordinating LLM-powered planning activities through an intuitive interface.

## Key Features

- **Rooms**: Create and manage planning sessions for LLM orchestration
- **Global Experts**: Define AI expert personas and configurations
- **Settings**: Theme, locale, and application preferences

## Technology Stack

- **Framework**: Flutter (SDK >=3.35.3), Dart (>=3.9.2)
- **State Management**: flutter_bloc with sequential transformers
- **LLM Integration**: OpenRouter API via custom llm_client package
- **Storage**: Filesystem-based persistence, SharedPreferences for settings
- **Platforms**: Windows, iOS, Android, Web

## Architecture

Workspace-based monorepo with clear separation:
- `app/` - Main application entry
- `core/` - Infrastructure packages (rest_client, llm_client, session_scheduler, filesystem_storage)
- `feature/` - Feature modules (home, rooms, global_experts, settings)

Uses repository pattern, dependency injection via service locator, and reactive UI updates through BLoC.
