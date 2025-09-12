import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/onboarding/domain/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    test('should create state with default values', () {
      // Act
      const state = OnboardingState();

      // Assert
      expect(state.currentPage, equals(0));
      expect(state.isCompleted, isFalse);
      expect(state.viewCount, equals(0));
      expect(state.hasSeenOnboardingBefore, isFalse);
    });

    test('should create state with provided values', () {
      // Act
      const state = OnboardingState(
        currentPage: 2,
        isCompleted: true,
        viewCount: 3,
      );

      // Assert
      expect(state.currentPage, equals(2));
      expect(state.isCompleted, isTrue);
      expect(state.viewCount, equals(3));
      expect(state.hasSeenOnboardingBefore, isTrue);
    });

    test('copyWith should update only provided fields', () {
      // Arrange
      const originalState = OnboardingState(
        currentPage: 1,
        isCompleted: false,
        viewCount: 2,
      );

      // Act
      final updatedState = originalState.copyWith(
        currentPage: 3,
        isCompleted: true,
      );

      // Assert
      expect(updatedState.currentPage, equals(3));
      expect(updatedState.isCompleted, isTrue);
      expect(updatedState.viewCount, equals(2)); // unchanged
    });

    test('copyWith should keep original values when null provided', () {
      // Arrange
      const originalState = OnboardingState(
        currentPage: 2,
        isCompleted: true,
        viewCount: 1,
      );

      // Act
      final updatedState = originalState.copyWith();

      // Assert
      expect(updatedState.currentPage, equals(2));
      expect(updatedState.isCompleted, isTrue);
      expect(updatedState.viewCount, equals(1));
    });

    test('hasSeenOnboardingBefore should return true when viewCount > 0', () {
      // Arrange
      const state1 = OnboardingState(viewCount: 1);
      const state2 = OnboardingState(viewCount: 5);
      const state3 = OnboardingState(viewCount: 0);

      // Assert
      expect(state1.hasSeenOnboardingBefore, isTrue);
      expect(state2.hasSeenOnboardingBefore, isTrue);
      expect(state3.hasSeenOnboardingBefore, isFalse);
    });

    test('equality should work correctly', () {
      // Arrange
      const state1 = OnboardingState(
        currentPage: 1,
        isCompleted: true,
        viewCount: 2,
      );
      const state2 = OnboardingState(
        currentPage: 1,
        isCompleted: true,
        viewCount: 2,
      );
      const state3 = OnboardingState(
        currentPage: 2,
        isCompleted: true,
        viewCount: 2,
      );

      // Assert
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
      expect(state1.hashCode, equals(state2.hashCode));
      expect(state1.hashCode, isNot(equals(state3.hashCode)));
    });

    test('should handle edge cases', () {
      // Test with negative values
      const negativeState = OnboardingState(currentPage: -1, viewCount: -1);

      expect(negativeState.currentPage, equals(-1));
      expect(negativeState.viewCount, equals(-1));
      expect(negativeState.hasSeenOnboardingBefore, isFalse);

      // Test with large values
      const largeState = OnboardingState(currentPage: 999, viewCount: 1000);

      expect(largeState.currentPage, equals(999));
      expect(largeState.viewCount, equals(1000));
      expect(largeState.hasSeenOnboardingBefore, isTrue);
    });

    test('should handle boolean edge cases', () {
      // Test with explicit false values
      const falseState = OnboardingState(
        currentPage: 0,
        isCompleted: false,
        viewCount: 0,
      );

      expect(falseState.isCompleted, isFalse);
      expect(falseState.hasSeenOnboardingBefore, isFalse);

      // Test with explicit true values
      const trueState = OnboardingState(
        currentPage: 0,
        isCompleted: true,
        viewCount: 1,
      );

      expect(trueState.isCompleted, isTrue);
      expect(trueState.hasSeenOnboardingBefore, isTrue);
    });

    test('should handle copyWith with explicit null values', () {
      // Arrange
      const originalState = OnboardingState(
        currentPage: 2,
        isCompleted: true,
        viewCount: 3,
      );

      // Act
      final updatedState = originalState.copyWith(
        currentPage: null,
        isCompleted: null,
        viewCount: null,
      );

      // Assert
      expect(updatedState.currentPage, equals(2));
      expect(updatedState.isCompleted, isTrue);
      expect(updatedState.viewCount, equals(3));
    });

    test('should handle partial updates', () {
      // Arrange
      const originalState = OnboardingState(
        currentPage: 0,
        isCompleted: false,
        viewCount: 0,
      );

      // Act - Update only currentPage
      final pageUpdated = originalState.copyWith(currentPage: 1);
      expect(pageUpdated.currentPage, equals(1));
      expect(pageUpdated.isCompleted, isFalse);
      expect(pageUpdated.viewCount, equals(0));

      // Act - Update only isCompleted
      final completedUpdated = originalState.copyWith(isCompleted: true);
      expect(completedUpdated.currentPage, equals(0));
      expect(completedUpdated.isCompleted, isTrue);
      expect(completedUpdated.viewCount, equals(0));

      // Act - Update only viewCount
      final viewCountUpdated = originalState.copyWith(viewCount: 1);
      expect(viewCountUpdated.currentPage, equals(0));
      expect(viewCountUpdated.isCompleted, isFalse);
      expect(viewCountUpdated.viewCount, equals(1));
    });
  });
}
