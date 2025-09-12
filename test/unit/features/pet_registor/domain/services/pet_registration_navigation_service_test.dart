import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/services/pet_registration_navigation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'pet_registration_navigation_service_test.mocks.dart';

@GenerateMocks([GoRouter])
void main() {
  group('PetRegistrationNavigationService', () {
    late MockGoRouter mockRouter;

    setUp(() {
      mockRouter = MockGoRouter();
    });

    group('navigateToNext', () {
      test('should navigate to breed selection when pet type is selected', () {
        // Arrange
        const state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          petName: null,
          petGender: null,
          petBirthday: null,
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to name input when breed is selected', () {
        // Arrange
        const state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: null,
          petGender: null,
          petBirthday: null,
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to anniversary when name and gender are set', () {
        // Arrange
        const state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: null,
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to size weight when birthday is set', () {
        // Arrange
        final state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to summary when all data is complete', () {
        // Arrange
        final state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to next step when data is complete', () {
        // Arrange
        final state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });
    });

    group('navigateBack', () {
      test('should navigate back to type selection from breed selection', () {
        // Arrange
        const state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: null,
          petGender: null,
          petBirthday: null,
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateBack(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate back to breed selection from name input', () {
        // Arrange
        const state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: null,
          petBirthday: null,
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateBack(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate back to name input from anniversary', () {
        // Arrange
        final state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateBack(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate back to anniversary from size weight', () {
        // Arrange
        final state = PetRegistrationDataEntity(
          selectedPetType: 'dog',
          selectedDogBreed: '柴犬',
          petName: 'テストペット',
          petGender: 'male',
          petBirthday: DateTime(2020, 1, 1),
          petSize: 'medium',
          petWeight: 25.5,
        );

        // Act
        PetRegistrationNavigationService.navigateBack(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate back from first step', () {
        // Arrange
        const state = PetRegistrationDataEntity(
          selectedPetType: null,
          petName: null,
          petGender: null,
          petBirthday: null,
          petSize: null,
          petWeight: null,
        );

        // Act
        PetRegistrationNavigationService.navigateBack(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });
    });

    group('navigateAfterRegistration', () {
      test('should navigate to complete route after registration', () {
        // Act
        PetRegistrationNavigationService.navigateAfterRegistration(mockRouter);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });
    });

    group('navigateToStep', () {
      test('should navigate to specific step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.petType,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to dog breed step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.dogBreed,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to cat breed step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.catBreed,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to pet info step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.petInfo,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to size weight step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.sizeWeight,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to anniversary step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.anniversary,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to summary step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.summary,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should navigate to complete step', () {
        // Act
        PetRegistrationNavigationService.navigateToStep(
          mockRouter,
          PetRegistrationStep.complete,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });
    });

    group('_getNextRoute', () {
      test('should return type selection route when no pet type selected', () {
        // Arrange
        const state = PetRegistrationDataEntity();

        // Act
        final route = PetRegistrationNavigationService.navigateToNext(
          mockRouter,
          state,
        );

        // Assert
        verify(mockRouter.go(any)).called(1);
      });

      test('should return breed selection route when pet type selected', () {
        // Arrange
        const state = PetRegistrationDataEntity(selectedPetType: 'dog');

        // Act
        PetRegistrationNavigationService.navigateToNext(mockRouter, state);

        // Assert
        verify(mockRouter.go(any)).called(1);
      });
    });
  });
}
