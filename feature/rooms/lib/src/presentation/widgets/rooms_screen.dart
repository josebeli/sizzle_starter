import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rooms/src/domain/models/room.dart';
import 'package:rooms/src/presentation/bloc/rooms_bloc.dart';
import 'package:rooms/src/presentation/bloc/rooms_state.dart';
import 'package:rooms/src/presentation/widgets/room_list_tile.dart';
import 'package:rooms/src/presentation/widgets/create_room_dialog.dart';
import 'package:rooms/src/presentation/widgets/rename_room_dialog.dart';

/// {@template rooms_screen}
/// Screen that displays the list of rooms.
/// {@endtemplate}
class RoomsScreen extends StatelessWidget {
  /// {@macro rooms_screen}
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: BlocConsumer<RoomsBloc, RoomsState>(
        listener: (context, state) {
          if (state is RoomsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RoomsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RoomsInitial || state is RoomsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle RoomsLoaded state
          if (state is RoomsLoaded) {
            return _buildRoomsList(context, state.rooms);
          }

          // Handle RoomsOperationSuccess state - show the updated rooms list
          if (state is RoomsOperationSuccess) {
            return _buildRoomsList(context, state.rooms);
          }

          // For RoomsError, show empty state with retry option
          if (state is RoomsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading rooms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<RoomsBloc>().add(const RoomsLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Fallback
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRoomDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Room'),
      ),
    );
  }

  Widget _buildRoomsList(BuildContext context, List<Room> rooms) {
    if (rooms.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return RoomListTile(
          room: room,
          onTap: () {
            // TODO: Navigate to room detail
          },
          onDelete: () {
            context.read<RoomsBloc>().add(
                  RoomDeleteRequested(room.roomId),
                );
          },
          onRename: () => _showRenameRoomDialog(context, room),
        );
      },
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<RoomsBloc>(),
        child: const CreateRoomDialog(),
      ),
    );
  }

  void _showRenameRoomDialog(BuildContext context, Room room) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<RoomsBloc>(),
        child: RenameRoomDialog(room: room),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No rooms yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first room to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
