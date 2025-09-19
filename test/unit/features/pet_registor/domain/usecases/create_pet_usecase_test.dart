import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/create_pet_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'create_pet_usecase_test.mocks.dart';

@GenerateMocks([PetRepository])
void main() {
  group('CreatePetUseCase', () {
    late CreatePetUseCase useCase;
    late MockPetRepository mockRepository;

    setUp(() {
      mockRepository = MockPetRepository();
      useCase = CreatePetUseCase(mockRepository);
    });

    group('call', () {
      test(
        'should return Result<PetProfileEntity> when repository call succeeds',
        () async {
          // Arrange
          final petEntity = PetProfileEntity(
            id: 'test-id',
            name: 'Test Pet',
            type: 'dog',
            breed: 'Golden Retriever',
            birthDate: DateTime(2020, 1, 1),
            age: 3,
            gender: 'male',
            weight: 25.0,
            imagePath: 'path/to/image.jpg',
            ownerId: 'owner-123',
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          );

          when(
            mockRepository.createPet(petEntity),
          ).thenAnswer((_) async => Result.success('ペットを作成しました', petEntity));

          // Act
          final result = await useCase.call(petEntity);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, equals(petEntity));
          expect(result.message, equals('ペットを作成しました'));
          verify(mockRepository.createPet(petEntity)).called(1);
        },
      );

      test('should return Result.failure when repository fails', () async {
        // Arrange
        final petEntity = PetProfileEntity(
          id: 'test-id',
          name: 'Test Pet',
          type: 'dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          age: 3,
          gender: 'male',
          weight: 25.0,
          imagePath: 'path/to/image.jpg',
          ownerId: 'owner-123',
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        when(
          mockRepository.createPet(petEntity),
        ).thenAnswer((_) async => Result.failure('Failed to create pet'));

        // Act
        final result = await useCase.call(petEntity);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('Failed to create pet'));
        expect(result.data, isNull);
        verify(mockRepository.createPet(petEntity)).called(1);
      });

      test('should pass correct pet entity to repository', () async {
        // Arrange
        final petEntity = PetProfileEntity(
          id: 'test-id-2',
          name: 'Another Pet',
          type: 'cat',
          breed: 'Persian',
          birthDate: DateTime(2021, 5, 15),
          age: 2,
          gender: 'female',
          weight: 4.5,
          imagePath: 'path/to/cat.jpg',
          ownerId: 'owner-456',
          createdAt: DateTime(2023, 6, 1),
          updatedAt: DateTime(2023, 6, 1),
        );

        when(
          mockRepository.createPet(petEntity),
        ).thenAnswer((_) async => Result.success('ペットを作成しました', petEntity));

        // Act
        await useCase.call(petEntity);

        // Assert
        verify(mockRepository.createPet(petEntity)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
