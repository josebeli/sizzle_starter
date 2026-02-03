import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:global_experts/src/domain/models/global_expert.dart';
import 'package:global_experts/src/presentation/bloc/global_experts_bloc.dart';
import 'package:global_experts/src/presentation/widgets/create_expert_dialog.dart';
import 'package:global_experts/src/presentation/widgets/edit_expert_dialog.dart';
import 'package:global_experts/src/presentation/widgets/global_expert_list_tile.dart';

/// {@template global_experts_screen}
/// Screen for managing global experts.
/// Displays a list of all experts with options to create, edit, and delete.
/// {@endtemplate}
class GlobalExpertsScreen extends StatelessWidget {
  /// {@macro global_experts_screen}
  const GlobalExpertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Experts'),
      ),
      body: BlocConsumer<GlobalExpertsBloc, GlobalExpertsState>(
        listener: (context, state) {
          if (state is GlobalExpertsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is GlobalExpertsOperationSuccess) {
            final message = switch (state.operation) {
              GlobalExpertOperation.created => 'Expert created successfully',
              GlobalExpertOperation.updated => 'Expert updated successfully',
              GlobalExpertOperation.deleted => 'Expert deleted successfully',
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
            GlobalExpertsOperationSuccess(experts: final experts) => _ExpertsList(
                experts: experts,
              ),
            GlobalExpertsError() => const _EmptyState(),
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
      return const _EmptyState();
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Expert'),
        content: Text('Are you sure you want to delete "${expert.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GlobalExpertsBloc>().add(
                    GlobalExpertDeleteRequested(expert.expertId),
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
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
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No experts yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expert to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
