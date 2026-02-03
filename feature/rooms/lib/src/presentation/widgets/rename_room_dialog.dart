import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rooms/src/domain/models/room.dart';
import 'package:rooms/src/presentation/bloc/rooms_bloc.dart';

/// {@template rename_room_dialog}
/// Dialog for renaming an existing room.
/// {@endtemplate}
class RenameRoomDialog extends StatefulWidget {
  /// {@macro rename_room_dialog}
  const RenameRoomDialog({
    required this.room,
    super.key,
  });

  final Room room;

  @override
  State<RenameRoomDialog> createState() => _RenameRoomDialogState();
}

class _RenameRoomDialogState extends State<RenameRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Room'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g., Project Planning',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Room name is required';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RoomsBloc>().add(
          RoomRenameRequested(
            roomId: widget.room.roomId,
            newName: _nameController.text,
          ),
        );

    Navigator.of(context).pop();
  }
}
