import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_all_pets_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_all_pets_usecase_test.mocks.dart';

@GenerateMocks([PetRepository])
void main() {
  group('GetAllPetsUseCase', () {
    late GetAllPetsUseCase useCase;
    late MockPetRepository mockRepository;

    setUp(() {
      mockRepository = MockPetRepository();
      useCase = GetAllPetsUseCase(mockRepository);
    });

    group('call', () {
      test(
        'should return Result<List<PetProfileEntity>> when repository returns pets',
        () async {
          // Arrange
          final expectedPets = [
            PetProfileEntity(
              id: 'pet-1',
              name: 'Dog Pet',
              type: 'dog',
              breed: 'Golden Retriever',
              birthDate: DateTime(2020, 1, 1),
              age: 3,
              gender: 'male',
              weight: 25.0,
              imagePath: 'path/to/dog.jpg',
              ownerId: 'owner-123',
              createdAt: DateTime(2023, 1, 1),
              updatedAt: DateTime(2023, 1, 1),
            ),
            PetProfileEntity(
              id: 'pet-2',
              name: 'Cat Pet',
              type: 'cat',
              breed: 'Persian',
              birthDate: DateTime(2021, 5, 15),
              age: 2,
              gender: 'female',
              weight: 4.5,
              imagePath: 'path/to/cat.jpg',
              ownerId: 'owner-123',
              createdAt: DateTime(2023, 1, 1),
              updatedAt: DateTime(2023, 1, 1),
            ),
          ];

          when(mockRepository.getAllPets()).thenAnswer(
            (_) async => Result.success('ペット一覧を取得しました', expectedPets),
          );

          // Act
          final result = await useCase.call();

          // Assert
          expect(result.isSuccess, isTrue);
          expect(result.data, equals(expectedPets));
          expect(result.data!.length, equals(2));
          expect(result.message, equals('ペット一覧を取得しました'));
          verify(mockRepository.getAllPets()).called(1);
        },
      );

      test('should return Result with empty list when no pets exist', () async {
        // Arrange
        when(mockRepository.getAllPets()).thenAnswer(
          (_) async => Result.success('ペット一覧を取得しました', <PetProfileEntity>[]),
        );

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
        expect(result.message, equals('ペット一覧を取得しました'));
        verify(mockRepository.getAllPets()).called(1);
      });

      test('should return Result.failure when repository fails', () async {
        // Arrange
        when(
          mockRepository.getAllPets(),
        ).thenAnswer((_) async => Result.failure('Failed to get pets'));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('Failed to get pets'));
        expect(result.data, isNull);
        verify(mockRepository.getAllPets()).called(1);
      });
    });
  });
}
