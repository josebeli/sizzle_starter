import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rooms/src/data/datasources/room_local_ds.dart';
import 'package:rooms/src/data/repositories/room_repo.dart';
import 'package:rooms/src/domain/models/room.dart';
import 'package:rooms/src/presentation/bloc/rooms_event.dart';
import 'package:rooms/src/presentation/bloc/rooms_state.dart';

export 'rooms_event.dart';
export 'rooms_state.dart';

/// {@template rooms_bloc}
/// BLoC for managing rooms.
///
/// Handles CRUD operations and emits appropriate states.
/// {@endtemplate}
class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  /// {@macro rooms_bloc}
  RoomsBloc({
    required this.repository,
  }) : super(const RoomsLoading()) {
    on<RoomsLoadRequested>(_onLoadRequested);
    on<RoomCreateRequested>(_onCreateRequested);
    on<RoomRenameRequested>(_onRenameRequested);
    on<RoomDeleteRequested>(_onDeleteRequested);
  }

  final RoomRepository repository;

  Future<void> _onLoadRequested(
    RoomsLoadRequested event,
    Emitter<RoomsState> emit,
  ) async {
    emit(const RoomsLoading());

    try {
      final rooms = await repository.getAllRooms();
      emit(RoomsLoaded(rooms));
    } catch (e) {
      emit(RoomsError('Failed to load rooms: $e'));
    }
  }

  Future<void> _onCreateRequested(
    RoomCreateRequested event,
    Emitter<RoomsState> emit,
  ) async {
    // Validate input
    final errors = event.input.validate();
    if (errors.isNotEmpty) {
      emit(RoomsError(errors.first.message));
      return;
    }

    emit(const RoomsLoading());

    try {
      final room = await repository.createRoom(event.input);
      final rooms = await repository.getAllRooms();
      emit(RoomsOperationSuccess(
        operation: RoomsOperation.created,
        rooms: rooms,
        roomId: room.roomId,
      ));
    } catch (e) {
      emit(RoomsError('Failed to create room: $e'));
    }
  }

  Future<void> _onRenameRequested(
    RoomRenameRequested event,
    Emitter<RoomsState> emit,
  ) async {
    // Validate new name
    if (event.newName.trim().isEmpty) {
      emit(const RoomsError('Room name cannot be empty'));
      return;
    }

    emit(const RoomsLoading());

    try {
      await repository.renameRoom(event.roomId, event.newName);
      final rooms = await repository.getAllRooms();
      emit(RoomsOperationSuccess(
        operation: RoomsOperation.renamed,
        rooms: rooms,
        roomId: event.roomId,
      ));
    } on RoomNotFoundException {
      emit(const RoomsError('Room not found'));
    } catch (e) {
      emit(RoomsError('Failed to rename room: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    RoomDeleteRequested event,
    Emitter<RoomsState> emit,
  ) async {
    emit(const RoomsLoading());

    try {
      await repository.deleteRoom(event.roomId);
      final rooms = await repository.getAllRooms();
      emit(RoomsOperationSuccess(
        operation: RoomsOperation.deleted,
        rooms: rooms,
        roomId: event.roomId,
      ));
    } on RoomNotFoundException {
      emit(const RoomsError('Room not found'));
    } catch (e) {
      emit(RoomsError('Failed to delete room: $e'));
    }
  }
}
