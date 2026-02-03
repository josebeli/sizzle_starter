import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rooms/src/domain/models/room_input.dart';
import 'package:rooms/src/presentation/bloc/rooms_bloc.dart';

/// {@template create_room_dialog}
/// Dialog for creating a new room.
/// Contains form field for room name.
/// {@endtemplate}
class CreateRoomDialog extends StatefulWidget {
  /// {@macro create_room_dialog}
  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Room'),
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
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final input = RoomInput(
      name: _nameController.text,
    );

    context.read<RoomsBloc>().add(
          RoomCreateRequested(input),
        );

    Navigator.of(context).pop();
  }
}
