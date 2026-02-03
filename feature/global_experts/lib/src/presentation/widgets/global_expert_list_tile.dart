import 'package:flutter/material.dart';

import 'package:global_experts/src/domain/models/global_expert.dart';

/// {@template global_expert_list_tile}
/// List tile widget for displaying a global expert.
/// Shows name, model (if set), and a preview of the system prompt.
/// {@endtemplate}
class GlobalExpertListTile extends StatelessWidget {
  /// {@macro global_expert_list_tile}
  const GlobalExpertListTile({
    required this.expert,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final GlobalExpert expert;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(expert.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expert.model != null)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  expert.model!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            Text(
              _truncatePrompt(expert.systemPrompt),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncatePrompt(String prompt) {
    const maxLength = 100;
    if (prompt.length <= maxLength) return prompt;
    return '${prompt.substring(0, maxLength)}...';
  }
}
