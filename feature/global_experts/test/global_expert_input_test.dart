import 'package:flutter_test/flutter_test.dart';
import 'package:global_experts/global_experts.dart';

void main() {
  group('GlobalExpertInput', () {
    group('validation', () {
      test('returns empty list for valid input', () {
        const input = GlobalExpertInput(
          name: 'Test Expert',
          systemPrompt: 'Test prompt',
        );

        expect(input.validate(), isEmpty);
        expect(input.isValid, isTrue);
      });

      test('returns emptyName error for empty name', () {
        const input = GlobalExpertInput(
          name: '',
          systemPrompt: 'Test prompt',
        );

        final errors = input.validate();
        expect(errors.length, 1);
        expect(errors.first, GlobalExpertValidationError.emptyName);
        expect(input.isValid, isFalse);
      });

      test('returns emptyName error for whitespace-only name', () {
        const input = GlobalExpertInput(
          name: '   ',
          systemPrompt: 'Test prompt',
        );

        final errors = input.validate();
        expect(errors.length, 1);
        expect(errors.first, GlobalExpertValidationError.emptyName);
      });

      test('returns emptyPrompt error for empty prompt', () {
        const input = GlobalExpertInput(
          name: 'Test Expert',
          systemPrompt: '',
        );

        final errors = input.validate();
        expect(errors.length, 1);
        expect(errors.first, GlobalExpertValidationError.emptyPrompt);
        expect(input.isValid, isFalse);
      });

      test('returns both errors for empty name and prompt', () {
        const input = GlobalExpertInput(
          name: '',
          systemPrompt: '',
        );

        final errors = input.validate();
        expect(errors.length, 2);
        expect(errors, contains(GlobalExpertValidationError.emptyName));
        expect(errors, contains(GlobalExpertValidationError.emptyPrompt));
      });
    });

    group('copyWith', () {
      test('returns new instance with updated values', () {
        const input = GlobalExpertInput(
          name: 'Original',
          systemPrompt: 'Original prompt',
        );

        final updated = input.copyWith(name: 'Updated');

        expect(updated.name, 'Updated');
        expect(updated.systemPrompt, 'Original prompt');
      });

      test('preserves null model when not specified', () {
        const input = GlobalExpertInput(
          name: 'Test',
          systemPrompt: 'Prompt',
        );

        final updated = input.copyWith(name: 'Updated');

        expect(updated.model, isNull);
      });

      test('updates model when specified', () {
        const input = GlobalExpertInput(
          name: 'Test',
          systemPrompt: 'Prompt',
        );

        final updated = input.copyWith(model: 'openai/gpt-4o');

        expect(updated.model, 'openai/gpt-4o');
      });
    });
  });

  group('GlobalExpertValidationError', () {
    test('has correct message for emptyName', () {
      expect(
        GlobalExpertValidationError.emptyName.message,
        'Name cannot be empty',
      );
    });

    test('has correct message for emptyPrompt', () {
      expect(
        GlobalExpertValidationError.emptyPrompt.message,
        'System prompt cannot be empty',
      );
    });
  });
}
