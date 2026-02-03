import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_experts/global_experts.dart';
import 'package:rooms/rooms.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.meeting_room_outlined),
      selectedIcon: Icon(Icons.meeting_room),
      label: 'Salas',
    ),
    NavigationDestination(
      icon: Icon(Icons.psychology_outlined),
      selectedIcon: Icon(Icons.psychology),
      label: 'Expertos',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Configuracion',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _RoomsTab(),
          _ExpertsTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}

class _RoomsTab extends StatelessWidget {
  const _RoomsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salas')),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RoomsLoaded) {
            return _RoomsList(rooms: state.rooms);
          }

          if (state is RoomsOperationSuccess) {
            return _RoomsList(rooms: state.rooms);
          }

          if (state is RoomsError) {
            return _RoomsErrorState(message: state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRoomDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Sala'),
      ),
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
}

class _RoomsList extends StatelessWidget {
  const _RoomsList({required this.rooms});

  final List<Room> rooms;

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
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
              'Sin salas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera sala para comenzar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
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
            context.read<RoomsBloc>().add(RoomDeleteRequested(room.roomId));
          },
          onRename: () => _showRenameRoomDialog(context, room),
        );
      },
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

class _RoomsErrorState extends StatelessWidget {
  const _RoomsErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
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
            'Error al cargar salas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.read<RoomsBloc>().add(const RoomsLoadRequested());
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _ExpertsTab extends StatelessWidget {
  const _ExpertsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expertos Globales')),
      body: BlocConsumer<GlobalExpertsBloc, GlobalExpertsState>(
        listener: (context, state) {
          if (state is GlobalExpertsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is GlobalExpertsOperationSuccess) {
            final message = switch (state.operation) {
              GlobalExpertOperation.created => 'Experto creado',
              GlobalExpertOperation.updated => 'Experto actualizado',
              GlobalExpertOperation.deleted => 'Experto eliminado',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            GlobalExpertsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            GlobalExpertsLoaded(experts: final experts) => _ExpertsList(
                experts: experts,
              ),
            GlobalExpertsOperationSuccess(experts: final experts) =>
              _ExpertsList(
                experts: experts,
              ),
            GlobalExpertsError() => const _ExpertsEmptyState(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<GlobalExpertsBloc>(),
        child: const CreateExpertDialog(),
      ),
    );
  }
}

class _ExpertsList extends StatelessWidget {
  const _ExpertsList({required this.experts});

  final List<GlobalExpert> experts;

  @override
  Widget build(BuildContext context) {
    if (experts.isEmpty) {
      return const _ExpertsEmptyState();
    }

    return ListView.builder(
      itemCount: experts.length,
      itemBuilder: (context, index) {
        final expert = experts[index];
        return GlobalExpertListTile(
          expert: expert,
          onEdit: () => _showEditDialog(context, expert),
          onDelete: () => _confirmDelete(context, expert),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, GlobalExpert expert) {
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<GlobalExpertsBloc>(),
        child: EditExpertDialog(expert: expert),
      ),
    );
  }

  void _confirmDelete(BuildContext context, GlobalExpert expert) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Experto'),
        content: Text('Estas seguro de eliminar "${expert.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GlobalExpertsBloc>().add(
                    GlobalExpertDeleteRequested(expert.expertId),
                  );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ExpertsEmptyState extends StatelessWidget {
  const _ExpertsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin expertos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer experto para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            subtitle: const Text('Informacion de la aplicacion'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Whiteboard Planner',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
