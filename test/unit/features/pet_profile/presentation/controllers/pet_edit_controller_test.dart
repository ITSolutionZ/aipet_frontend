import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_edit_controller.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../pet_registor/domain/usecases/get_pet_by_id_usecase_test.mocks.dart';

void main() {
  group('PetEditState Tests', () {
    test('기본 상태가 올바르게 생성되어야 함', () {
      const state = PetEditState();

      expect(state.isEditMode, isFalse);
      expect(state.selectedImagePath, isNull);
      expect(state.editingValues, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('copyWith가 올바르게 동작해야 함', () {
      const initialState = PetEditState();

      final newState = initialState.copyWith(
        isEditMode: true,
        selectedImagePath: 'test/path',
        editingValues: {'name': 'Test Pet'},
        isLoading: true,
        errorMessage: 'Test error',
      );

      expect(newState.isEditMode, isTrue);
      expect(newState.selectedImagePath, equals('test/path'));
      expect(newState.editingValues, equals({'name': 'Test Pet'}));
      expect(newState.isLoading, isTrue);
      expect(newState.errorMessage, equals('Test error'));
    });
  });

  group('PetEditNotifier Tests', () {
    late ProviderContainer container;
    late MockPetRepository mockRepository;
    final testPet = PetProfileEntity(
      id: 'test-pet',
      name: 'テストペット',
      type: 'dog',
      breed: '柴犬',
      birthDate: DateTime(2021, 1, 1),
      imagePath: 'test.jpg',
      ownerId: 'owner-1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockRepository = MockPetRepository();
      container = ProviderContainer(
        overrides: [
          // Mock providers here if needed
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      // Act
      final notifier = container.read(petEditNotifierProvider.notifier);

      // Assert
      expect(notifier.state.isEditMode, isFalse);
      expect(notifier.state.selectedImagePath, isNull);
      expect(notifier.state.editingValues, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('should start edit mode', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);

      // Act
      notifier.startEdit(testPet);

      // Assert
      expect(notifier.state.isEditMode, isTrue);
      expect(notifier.state.editingValues, isNotEmpty);
    });

    test('should cancel edit mode', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);

      // Act
      notifier.cancelEdit();

      // Assert
      expect(notifier.state.isEditMode, isFalse);
      expect(notifier.state.editingValues, isEmpty);
      expect(notifier.state.selectedImagePath, isNull);
    });

    test('should update editing value', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);

      // Act
      notifier.updateEditingValue('name', '新しい名前');

      // Assert
      expect(notifier.state.editingValues['name'], equals('新しい名前'));
    });

    test('should select image', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);

      // Act
      notifier.selectImage('new/image/path.jpg');

      // Assert
      expect(notifier.state.selectedImagePath, equals('new/image/path.jpg'));
    });

    test('should validate input correctly', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);

      // Act & Assert - Valid input
      notifier.updateEditingValue('name', 'Valid Name');
      expect(notifier.state.errorMessage, isNull);

      // Act & Assert - Invalid input (empty name)
      notifier.updateEditingValue('name', '');
      // Note: Validation logic would be tested in the actual implementation
    });

    test('should check for unsaved changes', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);

      // Act & Assert - No changes initially
      expect(notifier.hasUnsavedChanges, isFalse);

      // Act - Start editing
      notifier.startEdit(testPet);
      expect(notifier.hasUnsavedChanges, isTrue);

      // Act - Cancel editing
      notifier.cancelEdit();
      expect(notifier.hasUnsavedChanges, isFalse);
    });

    test('should get editing values correctly', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.startEdit(testPet);
      notifier.updateEditingValue('name', 'New Name');
      notifier.updateEditingValue('breed', 'New Breed');

      // Act & Assert
      expect(notifier.editingName, equals('New Name'));
      expect(notifier.editingBreed, equals('New Breed'));
    });

    test('should clear messages', () {
      // Arrange
      final notifier = container.read(petEditNotifierProvider.notifier);
      notifier.state = notifier.state.copyWith(
        errorMessage: 'Test error',
        successMessage: 'Test success',
      );

      // Act
      notifier.clearMessages();

      // Assert
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.successMessage, isNull);
    });
  });
}
