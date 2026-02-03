import 'package:flutter/material.dart';

import 'package:rooms/src/domain/models/room.dart';

/// {@template room_list_tile}
/// List tile widget for displaying a room.
/// Shows name, creation date, and status chip.
/// {@endtemplate}
class RoomListTile extends StatelessWidget {
  /// {@macro room_list_tile}
  const RoomListTile({
    required this.room,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
    super.key,
  });

  final Room room;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.meeting_room,
          color: room.isFinalized ? colorScheme.outline : colorScheme.primary,
        ),
        title: Text(room.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Created: ${_formatDate(room.createdAt)}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (room.isFinalized)
              Chip(
                label: const Text('Finalized'),
                backgroundColor: colorScheme.surfaceContainerHighest,
                labelStyle: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    onRename();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Rename'),
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
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
