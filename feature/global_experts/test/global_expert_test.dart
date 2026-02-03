import 'package:flutter_test/flutter_test.dart';
import 'package:global_experts/global_experts.dart';

void main() {
  group('GlobalExpert', () {
    const expert = GlobalExpert(
      expertId: 'test-id',
      name: 'Test Expert',
      systemPrompt: 'Test system prompt',
    );

    test('can be instantiated', () {
      expect(expert, isNotNull);
      expect(expert.expertId, 'test-id');
      expect(expert.name, 'Test Expert');
      expect(expert.systemPrompt, 'Test system prompt');
      expect(expert.model, isNull);
    });

    test('can be instantiated with model', () {
      const expertWithModel = GlobalExpert(
        expertId: 'test-id-2',
        name: 'Test Expert 2',
        systemPrompt: 'Test system prompt 2',
        model: 'openai/gpt-4o',
      );

      expect(expertWithModel.model, 'openai/gpt-4o');
    });

    group('copyWith', () {
      test('returns new instance with same values when no args', () {
        final copied = expert.copyWith();

        expect(copied.expertId, expert.expertId);
        expect(copied.name, expert.name);
        expect(copied.systemPrompt, expert.systemPrompt);
        expect(copied.model, expert.model);
      });

      test('returns new instance with updated name', () {
        final copied = expert.copyWith(name: 'Updated Name');

        expect(copied.expertId, expert.expertId);
        expect(copied.name, 'Updated Name');
        expect(copied.systemPrompt, expert.systemPrompt);
      });

      test('returns new instance with updated model', () {
        final copied = expert.copyWith(model: 'anthropic/claude-3');

        expect(copied.model, 'anthropic/claude-3');
      });

      test('preserves model when not specified in copyWith', () {
        const expertWithModel = GlobalExpert(
          expertId: 'test-id',
          name: 'Test',
          systemPrompt: 'Prompt',
          model: 'openai/gpt-4o',
        );

        final copied = expertWithModel.copyWith(name: 'Updated');

        // Model is preserved when not specified in copyWith
        expect(copied.model, 'openai/gpt-4o');
      });
    });

    group('equality', () {
      test('two experts with same values are equal', () {
        const expert1 = GlobalExpert(
          expertId: 'id-1',
          name: 'Test',
          systemPrompt: 'Prompt',
        );
        const expert2 = GlobalExpert(
          expertId: 'id-1',
          name: 'Test',
          systemPrompt: 'Prompt',
        );

        expect(expert1, equals(expert2));
        expect(expert1.hashCode, equals(expert2.hashCode));
      });

      test('two experts with different ids are not equal', () {
        const expert1 = GlobalExpert(
          expertId: 'id-1',
          name: 'Test',
          systemPrompt: 'Prompt',
        );
        const expert2 = GlobalExpert(
          expertId: 'id-2',
          name: 'Test',
          systemPrompt: 'Prompt',
        );

        expect(expert1, isNot(equals(expert2)));
      });

      test('two experts with different names are not equal', () {
        const expert1 = GlobalExpert(
          expertId: 'id-1',
          name: 'Test 1',
          systemPrompt: 'Prompt',
        );
        const expert2 = GlobalExpert(
          expertId: 'id-1',
          name: 'Test 2',
          systemPrompt: 'Prompt',
        );

        expect(expert1, isNot(equals(expert2)));
      });
    });

    test('toString contains relevant info', () {
      final str = expert.toString();

      expect(str, contains('GlobalExpert'));
      expect(str, contains('test-id'));
      expect(str, contains('Test Expert'));
    });
  });
}
