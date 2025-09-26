import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_pet_summary_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.dart';
import 'get_pet_summary_usecase_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  group('GetPetSummaryUseCase', () {
    late GetPetSummaryUseCase useCase;
    late MockHomeRepository mockRepository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockRepository = MockHomeRepository();
      useCase = GetPetSummaryUseCase(mockRepository);
    });

    group('call method', () {
      test('should return pet summaries successfully', () async {
        // Arrange
        final expectedPets = [
          PetSummaryEntity(
            id: '1',
            name: 'テストペット1',
            typeName: '犬',
            breed: '柴犬',
            age: 3,
            birthDate: DateTime(2021, 1, 1),
            createdAt: DateTime(2021, 1, 1),
            additionalInfo: {'gender': 'オス', 'isMicrochipped': true},
          ),
          PetSummaryEntity(
            id: '2',
            name: 'テストペット2',
            typeName: '猫',
            breed: 'アメリカンショートヘア',
            age: 2,
            birthDate: DateTime(2022, 1, 1),
            createdAt: DateTime(2022, 1, 1),
            additionalInfo: {'gender': 'メス', 'isMicrochipped': false},
          ),
        ];

        when(
          mockRepository.getPetSummaries(),
        ).thenAnswer((_) async => expectedPets);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, equals(expectedPets));
        expect(result.length, equals(2));
        verify(mockRepository.getPetSummaries()).called(1);
      });

      test('should return empty list when no pets', () async {
        // Arrange
        when(
          mockRepository.getPetSummaries(),
        ).thenAnswer((_) async => <PetSummaryEntity>[]);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getPetSummaries()).called(1);
      });

      test('should handle repository errors', () async {
        // Arrange
        when(
          mockRepository.getPetSummaries(),
        ).thenThrow(Exception('Repository error'));

        // Act & Assert
        expect(() => useCase.call(), throwsException);
        verify(mockRepository.getPetSummaries()).called(1);
      });
    });

    group('getById method', () {
      test('should return specific pet by id', () async {
        // Arrange
        final pets = [
          PetSummaryEntity(
            id: '1',
            name: 'テストペット1',
            typeName: '犬',
            breed: '柴犬',
            age: 3,
            birthDate: DateTime(2021, 1, 1),
            createdAt: DateTime(2021, 1, 1),
            additionalInfo: {'gender': 'オス', 'isMicrochipped': true},
          ),
          PetSummaryEntity(
            id: '2',
            name: 'テストペット2',
            typeName: '猫',
            breed: 'アメリカンショートヘア',
            age: 2,
            birthDate: DateTime(2022, 1, 1),
            createdAt: DateTime(2022, 1, 1),
            additionalInfo: {'gender': 'メス', 'isMicrochipped': false},
          ),
        ];

        when(mockRepository.getPetSummaries()).thenAnswer((_) async => pets);

        // Act
        final result = await useCase.getById('1');

        // Assert
        expect(result, isNotNull);
        expect(result.id, equals('1'));
        expect(result.name, equals('テストペット1'));
        verify(mockRepository.getPetSummaries()).called(1);
      });

      test('should return null when pet not found', () async {
        // Arrange
        when(
          mockRepository.getPetSummaries(),
        ).thenAnswer((_) async => <PetSummaryEntity>[]);

        // Act
        final result = await useCase.getById('nonexistent');

        // Assert
        expect(result, isNull);
        verify(mockRepository.getPetSummaries()).called(1);
      });
    });

    group('edge cases', () {
      test('should handle pets with special characters in names', () async {
        // Arrange
        final specialPets = [
          PetSummaryEntity(
            id: '1',
            name: 'テストペット特殊文字',
            typeName: '犬',
            breed: '柴犬',
            age: 3,
            birthDate: DateTime(2021, 1, 1),
            createdAt: DateTime(2021, 1, 1),
            additionalInfo: {'gender': 'オス', 'isMicrochipped': true},
          ),
        ];

        when(
          mockRepository.getPetSummaries(),
        ).thenAnswer((_) async => specialPets);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.length, equals(1));
        expect(result.first.name, contains('特殊文字'));
        expect(result.first.additionalInfo, isNotNull);
      });
    });
  });
}
