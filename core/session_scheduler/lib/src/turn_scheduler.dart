import 'dart:async';

import 'package:filesystem_storage/filesystem_storage.dart';
import 'package:llm_client/llm_client.dart';
import 'package:logger/logger.dart';

import 'package:session_scheduler/src/exceptions/scheduler_exception.dart';
import 'package:session_scheduler/src/models/scheduler_config.dart';
import 'package:session_scheduler/src/models/session_state.dart';
import 'package:session_scheduler/src/models/turn_result.dart';
import 'package:session_scheduler/src/request_semaphore.dart';
import 'package:session_scheduler/src/session_scheduler.dart';

/// Stub for LocalExpert - will be implemented in Phase 2
class LocalExpert {
  LocalExpert({
    required this.localId,
    required this.name,
    required this.systemPrompt,
    this.modelOverride,
  });
  final String localId;
  final String name;
  final String systemPrompt;
  final String? modelOverride;
}

/// {@template turn_scheduler}
/// Implementation of [SessionScheduler] for turn-based LLM orchestration.
/// {@endtemplate}
final class TurnScheduler implements SessionScheduler {
  /// {@macro turn_scheduler}
  TurnScheduler({
    required RequestSemaphore semaphore,
    required LLMClient llmClient,
    required FilesystemStorage storage,
    required SchedulerConfig config,
    required String roomId,
    required List<LocalExpert> experts,
    Logger? logger,
  })  : _semaphore = semaphore,
        _llmClient = llmClient,
        _storage = storage,
        _config = config,
        _roomId = roomId,
        _experts = List.unmodifiable(experts),
        _logger = logger {
    _stateController = StreamController<SessionState>.broadcast(
      onListen: () => _stateController.add(_state),
    );
  }

  final RequestSemaphore _semaphore;
  final LLMClient _llmClient;
  final FilesystemStorage _storage;
  final SchedulerConfig _config;
  final String _roomId;
  final List<LocalExpert> _experts;
  final Logger? _logger;

  late final StreamController<SessionState> _stateController;
  SessionState _state = const SessionState(status: SessionStatus.idle);
  CancelToken? _cancelToken;
  bool _isDisposed = false;

  @override
  SessionState get state => _state;

  @override
  Stream<SessionState> get stateStream => _stateController.stream;

  void _updateState(SessionState newState) {
    if (_isDisposed) return;
    _state = newState;
    _stateController.add(_state);
    _logger?.info('Session state: ${newState.status}');
  }

  @override
  Future<void> play() async {
    if (_isDisposed) throw const SchedulerException('Scheduler disposed');
    if (!state.canPlay) {
      _logger?.warn('Cannot play in state: ${state.status}');
      return;
    }

    _updateState(state.copyWith(status: SessionStatus.playing));
    _cancelToken = CancelToken();

    try {
      while (state.isPlaying && !_cancelToken!.isCancelled) {
        // Check max turns
        if (state.currentTurn >= state.maxTurns) {
          _logger?.info('Max turns reached');
          if (_config.autoFinalize) {
            await finalize();
          } else {
            _updateState(state.copyWith(status: SessionStatus.paused));
          }
          break;
        }

        // Execute turn with semaphore
        final result = await _semaphore.acquire(_executeTurn);

        if (!result.success) {
          _updateState(state.copyWith(
            status: SessionStatus.error,
            lastError: result.error,
          ));
          break;
        }

        // Check if finalized
        if (result.isFinalized) {
          _updateState(state.copyWith(
            status: SessionStatus.finalized,
            lastSnapshotSeq: result.snapshotSeq,
          ));
          break;
        }

        // Update state after successful turn
        _updateState(state.copyWith(
          currentTurn: state.currentTurn + 1,
          currentExpertIndex: (state.currentExpertIndex + 1) % _experts.length,
          lastSnapshotSeq: result.snapshotSeq,
        ));

        // Delay before next turn
        if (_config.delayMs > 0 && state.isPlaying) {
          await Future<void>.delayed(
            Duration(milliseconds: _config.delayMs),
          );
        }
      }
    } on SchedulerException {
      rethrow;
    } on Object catch (e) {
      _logger?.error('Error in play loop', error: e);
      _updateState(state.copyWith(
        status: SessionStatus.error,
        lastError: e.toString(),
      ));
    }
  }

  @override
  Future<void> pause() async {
    if (_isDisposed) throw const SchedulerException('Scheduler disposed');
    if (!state.isPlaying) return;

    _cancelToken?.cancel();
    _updateState(state.copyWith(status: SessionStatus.paused));
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) throw const SchedulerException('Scheduler disposed');
    
    _cancelToken?.cancel();
    _updateState(const SessionState(status: SessionStatus.idle));
  }

  @override
  Future<TurnResult> nextTurn() async {
    if (_isDisposed) throw const SchedulerException('Scheduler disposed');
    if (!state.canExecuteTurn) {
      return TurnResult.failure(
        error: 'Cannot execute turn in state: ${state.status}',
      );
    }

    return _semaphore.acquire(_executeTurn);
  }

  Future<TurnResult> _executeTurn() async {
    try {
      // TODO: Implementar lógica de turno completa
      // 1. Obtener documento actual
      // 2. Determinar experto actual
      // 3. Construir prompts
      // 4. Enviar request a LLM
      // 5. Parsear respuesta
      // 6. Validar documento
      // 7. Guardar snapshot
      // 8. Verificar finalización

      _logger?.info('Executing turn ${state.currentTurn + 1}');

      // Placeholder - implementar lógica real
      return TurnResult.success(snapshotSeq: state.currentTurn + 1);
    } on LLMException catch (e) {
      return TurnResult.failure(error: e.message, shouldRetry: true);
    } on Object catch (e) {
      return TurnResult.failure(error: e.toString());
    }
  }

  @override
  bool get canFinalize {
    // TODO: Implementar verificación de items activos
    return state.isPaused || state.isIdle;
  }

  @override
  Future<void> finalize() async {
    if (_isDisposed) throw const SchedulerException('Scheduler disposed');
    if (!canFinalize) {
      throw const SchedulerException('Cannot finalize in current state');
    }

    _updateState(state.copyWith(status: SessionStatus.finalizing));
    
    // TODO: Guardar estado final
    
    _updateState(state.copyWith(status: SessionStatus.finalized));
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    _isDisposed = true;
    _cancelToken?.cancel();
    await _stateController.close();
  }
}