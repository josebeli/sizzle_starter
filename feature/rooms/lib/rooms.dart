/// Rooms Feature - Whiteboard Planning
///
/// This package provides room management functionality for the
/// Whiteboard Planner application.
///
/// ## Usage
///
/// ```dart
/// import 'package:rooms/rooms.dart';
///
/// // Create repository
/// final repository = RoomRepositoryImpl(
///   localDataSource: RoomFilesystemDataSource(storage: storage),
/// );
///
/// // Use BLoC
/// final bloc = RoomsBloc(repository: repository);
/// ```
library;

// Domain
export 'src/domain/models/room.dart';
export 'src/domain/models/room_config.dart';
export 'src/domain/models/room_input.dart';

// Data
export 'src/data/datasources/room_local_ds.dart';
export 'src/data/datasources/room_filesystem_ds.dart';
export 'src/data/repositories/room_repo.dart';

// Presentation
export 'src/presentation/bloc/rooms_bloc.dart';
export 'src/presentation/widgets/rooms_screen.dart';
export 'src/presentation/widgets/room_list_tile.dart';
export 'src/presentation/widgets/create_room_dialog.dart';
export 'src/presentation/widgets/rename_room_dialog.dart';
