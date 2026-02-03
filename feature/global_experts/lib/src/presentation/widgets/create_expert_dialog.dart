import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:global_experts/src/domain/models/global_expert_input.dart';
import 'package:global_experts/src/presentation/bloc/global_experts_bloc.dart';

/// {@template create_expert_dialog}
/// Dialog for creating a new global expert.
/// Contains form fields for name, system prompt, and optional model.
/// {@endtemplate}
class CreateExpertDialog extends StatefulWidget {
  /// {@macro create_expert_dialog}
  const CreateExpertDialog({super.key});

  @override
  State<CreateExpertDialog> createState() => _CreateExpertDialogState();
}

class _CreateExpertDialogState extends State<CreateExpertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  final _modelController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Expert'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Product Manager',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model (optional)',
                    hintText: 'e.g., openai/gpt-4o',
                    helperText: 'Leave empty to use room default',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _promptController,
                  decoration: const InputDecoration(
                    labelText: 'System Prompt',
                    hintText: 'Define the expert role and behavior...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'System prompt is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
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

    final input = GlobalExpertInput(
      name: _nameController.text,
      systemPrompt: _promptController.text,
      model: _modelController.text.isEmpty ? null : _modelController.text,
    );

    context.read<GlobalExpertsBloc>().add(
          GlobalExpertCreateRequested(input),
        );

    Navigator.of(context).pop();
  }
}
