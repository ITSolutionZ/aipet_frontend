import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
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
        'should return Result<PetProfileEntity?> when repository returns pet',
        () async {
          // Arrange
          const petId = 'test-id';
          final expectedPet = PetProfileEntity(
            id: petId,
            name: 'Test Pet',
            type: 'dog',
            breed: 'Golden Retriever',
            birthDate: DateTime(2020, 1, 1),
            gender: 'male',
            weight: 25.0,
            imagePath: 'path/to/image.jpg',
            ownerId: 'owner-123',
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
          );

          when(mockRepository.getPetById(petId)).thenAnswer(
            (_) async => Result.success('ペット情報を取得しました', expectedPet),
          );

          // Act
          final result = await useCase.call(petId);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, equals(expectedPet));
          expect(result.message, equals('ペット情報を取得しました'));
          verify(mockRepository.getPetById(petId)).called(1);
        },
      );

      test(
        'should return Result with null data when repository returns null',
        () async {
          // Arrange
          const petId = 'non-existent-id';

          when(
            mockRepository.getPetById(petId),
          ).thenAnswer((_) async => Result.success('ペット情報を取得しました', null));

          // Act
          final result = await useCase.call(petId);

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, isNull);
          expect(result.message, equals('ペット情報を取得しました'));
          verify(mockRepository.getPetById(petId)).called(1);
        },
      );

      test('should return Result.failure when repository fails', () async {
        // Arrange
        const petId = 'test-id';

        when(
          mockRepository.getPetById(petId),
        ).thenAnswer((_) async => Result.failure('Failed to get pet'));

        // Act
        final result = await useCase.call(petId);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('Failed to get pet'));
        expect(result.data, isNull);
        verify(mockRepository.getPetById(petId)).called(1);
      });
    });
  });
}
