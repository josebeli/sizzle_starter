import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rooms/src/data/datasources/room_local_ds.dart';
import 'package:rooms/src/data/repositories/room_repo.dart';
import 'package:rooms/src/domain/models/room.dart';
import 'package:rooms/src/domain/models/room_config.dart';
import 'package:rooms/src/domain/models/room_input.dart';
import 'package:rooms/src/presentation/bloc/rooms_bloc.dart';

class MockRoomRepository extends Mock implements RoomRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const RoomInput(name: ''));
    registerFallbackValue(Room(
      roomId: '',
      name: '',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      isFinalized: false,
      roomConfig: const RoomConfig(),
    ));
  });

  group('RoomsBloc', () {
    late RoomRepository repository;
    late RoomsBloc bloc;

    final testRoom = Room(
      roomId: 'test-id',
      name: 'Test Room',
      createdAt: DateTime.utc(2026, 1),
      updatedAt: DateTime.utc(2026, 1),
      isFinalized: false,
      roomConfig: const RoomConfig(),
    );

    setUp(() {
      repository = MockRoomRepository();
      bloc = RoomsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    group('constructor', () {
      test('initial state is RoomsLoading', () {
        expect(bloc.state, isA<RoomsLoading>());
      });
    });

    group('RoomsLoadRequested', () {
      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsLoaded when repository returns rooms',
        setUp: () {
          when(() => repository.getAllRooms())
              .thenAnswer((_) async => [testRoom]);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const RoomsLoadRequested()),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsLoaded>().having(
            (s) => s.rooms,
            'rooms',
            [testRoom],
          ),
        ],
        verify: (_) {
          verify(() => repository.getAllRooms()).called(1);
        },
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsLoaded with empty list when no rooms exist',
        setUp: () {
          when(() => repository.getAllRooms())
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const RoomsLoadRequested()),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsLoaded>().having(
            (s) => s.rooms,
            'rooms',
            isEmpty,
          ),
        ],
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when repository throws',
        setUp: () {
          when(() => repository.getAllRooms())
              .thenThrow(Exception('Load error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const RoomsLoadRequested()),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            contains('Failed to load rooms'),
          ),
        ],
      );
    });

    group('RoomCreateRequested', () {
      blocTest<RoomsBloc, RoomsState>(
        'creates room and emits RoomsOperationSuccess',
        setUp: () {
          when(() => repository.createRoom(any()))
              .thenAnswer((_) async => testRoom);
          when(() => repository.getAllRooms())
              .thenAnswer((_) async => [testRoom]);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomCreateRequested(RoomInput(name: 'New Room')),
        ),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsOperationSuccess>().having(
            (s) => s.operation,
            'operation',
            RoomsOperation.created,
          ),
        ],
        verify: (_) {
          verify(() => repository.createRoom(any())).called(1);
          verify(() => repository.getAllRooms()).called(1);
        },
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when name is empty',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomCreateRequested(RoomInput(name: '')),
        ),
        // No skip - validation error is emitted immediately without loading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            'Room name cannot be empty',
          ),
        ],
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when repository throws',
        setUp: () {
          when(() => repository.createRoom(any()))
              .thenThrow(Exception('Create error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomCreateRequested(RoomInput(name: 'New Room')),
        ),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            contains('Failed to create room'),
          ),
        ],
      );
    });

    group('RoomDeleteRequested', () {
      blocTest<RoomsBloc, RoomsState>(
        'deletes room and emits RoomsOperationSuccess',
        setUp: () {
          when(() => repository.deleteRoom('room-id'))
              .thenAnswer((_) async {});
          when(() => repository.getAllRooms())
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const RoomDeleteRequested('room-id')),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsOperationSuccess>().having(
            (s) => s.operation,
            'operation',
            RoomsOperation.deleted,
          ),
        ],
        verify: (_) {
          verify(() => repository.deleteRoom('room-id')).called(1);
          verify(() => repository.getAllRooms()).called(1);
        },
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when repository throws',
        setUp: () {
          when(() => repository.deleteRoom('room-id'))
              .thenThrow(Exception('Delete error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const RoomDeleteRequested('room-id')),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            contains('Failed to delete room'),
          ),
        ],
      );
    });

    group('RoomRenameRequested', () {
      blocTest<RoomsBloc, RoomsState>(
        'renames room and emits RoomsOperationSuccess',
        setUp: () {
          final renamedRoom = testRoom.copyWith(name: 'Renamed Room');
          when(() => repository.renameRoom('test-id', 'Renamed Room'))
              .thenAnswer((_) async {});
          when(() => repository.getAllRooms())
              .thenAnswer((_) async => [renamedRoom]);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomRenameRequested(roomId: 'test-id', newName: 'Renamed Room'),
        ),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsOperationSuccess>().having(
            (s) => s.operation,
            'operation',
            RoomsOperation.renamed,
          ),
        ],
        verify: (_) {
          verify(() => repository.renameRoom('test-id', 'Renamed Room')).called(1);
          verify(() => repository.getAllRooms()).called(1);
        },
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when new name is empty',
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomRenameRequested(roomId: 'test-id', newName: ''),
        ),
        // No skip - validation error is emitted immediately without loading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            'Room name cannot be empty',
          ),
        ],
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when room not found',
        setUp: () {
          when(() => repository.renameRoom('test-id', 'Renamed Room'))
              .thenThrow(const RoomNotFoundException('test-id'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomRenameRequested(roomId: 'test-id', newName: 'Renamed Room'),
        ),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            contains('Room not found'),
          ),
        ],
      );

      blocTest<RoomsBloc, RoomsState>(
        'emits RoomsError when repository throws',
        setUp: () {
          when(() => repository.renameRoom('test-id', 'Renamed Room'))
              .thenThrow(Exception('Rename error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          const RoomRenameRequested(roomId: 'test-id', newName: 'Renamed Room'),
        ),
        skip: 1, // Skip RoomsLoading
        expect: () => [
          isA<RoomsError>().having(
            (s) => s.message,
            'message',
            contains('Failed to rename room'),
          ),
        ],
      );
    });
  });
}
