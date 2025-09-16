import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_pet_by_id_usecase_test.mocks.dart';

@GenerateMocks([PetRepository])
void main() {
  group('GetPetByIdUseCase', () {
    late GetPetByIdUseCase useCase;
    late MockPetRepository mockRepository;

    setUp(() {
      mockRepository = MockPetRepository();
      useCase = GetPetByIdUseCase(mockRepository);
    });

    group('call', () {
      test(
        'should return PetProfileEntity when repository returns pet',
        () async {
          // Arrange
          const petId = 'test-id';
          final expectedPet = PetProfileEntity(
            id: petId,
            name: 'Test Pet',
            type: 'dog',
            breed: 'Golden Retriever',
            birthDate: DateTime(2020, 1, 1),
            imagePath: 'path/to/image.jpg',
            ownerId: 'owner-123',
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          );

          when(
            mockRepository.getPetById(petId),
          ).thenAnswer((_) async => expectedPet);

          // Act
          final result = await useCase.call(petId);

          // Assert
          expect(result, equals(expectedPet));
          verify(mockRepository.getPetById(petId)).called(1);
        },
      );

      test('should return null when repository returns null', () async {
        // Arrange
        const petId = 'non-existent-id';

        when(mockRepository.getPetById(petId)).thenAnswer((_) async => null);

        // Act
        final result = await useCase.call(petId);

        // Assert
        expect(result, isNull);
        verify(mockRepository.getPetById(petId)).called(1);
      });

      test('should throw exception when repository fails', () async {
        // Arrange
        const petId = 'test-id';

        when(
          mockRepository.getPetById(petId),
        ).thenThrow(Exception('Failed to get pet'));

        // Act & Assert
        expect(() => useCase.call(petId), throwsException);
        verify(mockRepository.getPetById(petId)).called(1);
      });
    });
  });
}
