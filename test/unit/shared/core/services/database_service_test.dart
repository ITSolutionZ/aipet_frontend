import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:aipet_frontend/shared/core/services/database_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    // SQLite FFI 초기화 (테스트용)
    sqfliteFfiInit();
    databaseFactoryOrNull = databaseFactoryFfi;
  });

  setUp(() {
    databaseService = DatabaseService();
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('DatabaseService', () {
    test('should initialize database successfully', () async {
      final db = await databaseService.database;
      expect(db, isNotNull);
    });

    group('Pet Profile Operations', () {
      test('should save and retrieve pet profile', () async {
        // Given
        final pet = PetProfileEntity(
          id: 'test-pet-1',
          name: 'Buddy',
          type: 'dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 5, 15),
          gender: 'male',
          weight: 25.5,
          imagePath: '/path/to/image.jpg',
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          additionalInfo: {'color': 'golden'},
        );

        // When
        final saveResult = await databaseService.savePetProfile(pet);
        final getResult = await databaseService.getPetProfileById('test-pet-1');

        // Then
        expect(saveResult.isSuccess, isTrue);
        expect(getResult.isSuccess, isTrue);
        expect(getResult.dataOrNull, isNotNull);
        expect(getResult.dataOrNull!.name, equals('Buddy'));
        expect(getResult.dataOrNull!.type, equals('dog'));
        expect(getResult.dataOrNull!.breed, equals('Golden Retriever'));
        expect(getResult.dataOrNull!.weight, equals(25.5));
      });

      test('should return null for non-existent pet', () async {
        // When
        final result = await databaseService.getPetProfileById('non-existent');

        // Then
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNull);
      });

      test('should get all pet profiles', () async {
        // Given
        final pets = [
          PetProfileEntity(
            id: 'pet-1',
            name: 'Max',
            type: 'dog',
            birthDate: DateTime(2019, 3, 10),
            gender: 'male',
            weight: 30.0,
            ownerId: 'owner-1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            additionalInfo: {},
          ),
          PetProfileEntity(
            id: 'pet-2',
            name: 'Luna',
            type: 'cat',
            birthDate: DateTime(2021, 8, 22),
            gender: 'female',
            weight: 4.2,
            ownerId: 'owner-1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            additionalInfo: {},
          ),
        ];

        // When
        for (final pet in pets) {
          await databaseService.savePetProfile(pet);
        }
        final result = await databaseService.getAllPetProfiles();

        // Then
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.length, greaterThanOrEqualTo(2));
        expect(result.dataOrNull!.any((p) => p.name == 'Max'), isTrue);
        expect(result.dataOrNull!.any((p) => p.name == 'Luna'), isTrue);
      });

      test('should get pets by owner ID', () async {
        // Given
        final pets = [
          PetProfileEntity(
            id: 'owner1-pet1',
            name: 'Rocky',
            type: 'dog',
            birthDate: DateTime(2020, 1, 15),
            gender: 'male',
            weight: 20.0,
            ownerId: 'owner-1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            additionalInfo: {},
          ),
          PetProfileEntity(
            id: 'owner2-pet1',
            name: 'Mittens',
            type: 'cat',
            birthDate: DateTime(2021, 6, 10),
            gender: 'female',
            weight: 3.8,
            ownerId: 'owner-2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            additionalInfo: {},
          ),
        ];

        // When
        for (final pet in pets) {
          await databaseService.savePetProfile(pet);
        }
        final result = await databaseService.getPetProfilesByOwnerId('owner-1');

        // Then
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull!.length, equals(1));
        expect(result.dataOrNull!.first.name, equals('Rocky'));
        expect(result.dataOrNull!.first.ownerId, equals('owner-1'));
      });

      test('should update pet profile', () async {
        // Given
        final originalPet = PetProfileEntity(
          id: 'update-test',
          name: 'Charlie',
          type: 'dog',
          birthDate: DateTime(2019, 7, 8),
          gender: 'male',
          weight: 15.0,
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          additionalInfo: {},
        );

        await databaseService.savePetProfile(originalPet);

        final updatedPet = originalPet.copyWith(
          name: 'Charlie Updated',
          weight: 16.5,
        );

        // When
        final updateResult = await databaseService.updatePetProfile(updatedPet);
        final getResult = await databaseService.getPetProfileById('update-test');

        // Then
        expect(updateResult.isSuccess, isTrue);
        expect(getResult.isSuccess, isTrue);
        expect(getResult.dataOrNull!.name, equals('Charlie Updated'));
        expect(getResult.dataOrNull!.weight, equals(16.5));
      });

      test('should delete pet profile', () async {
        // Given
        final pet = PetProfileEntity(
          id: 'delete-test',
          name: 'Temporary Pet',
          type: 'dog',
          birthDate: DateTime(2020, 12, 1),
          gender: 'female',
          weight: 12.0,
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          additionalInfo: {},
        );

        await databaseService.savePetProfile(pet);

        // When
        final deleteResult = await databaseService.deletePetProfile('delete-test');
        final getResult = await databaseService.getPetProfileById('delete-test');

        // Then
        expect(deleteResult.isSuccess, isTrue);
        expect(getResult.isSuccess, isTrue);
        expect(getResult.dataOrNull, isNull);
      });
    });

    group('Temporary Pet Data Operations', () {
      test('should save and retrieve temporary pet data', () async {
        // Given
        const step = 'name_input';
        final data = {
          'name': 'Test Pet',
          'type': 'dog',
          'progress': 0.5,
        };

        // When
        final saveResult = await databaseService.saveTemporaryPetData(step, data);
        final getResult = await databaseService.getTemporaryPetData(step);

        // Then
        expect(saveResult.isSuccess, isTrue);
        expect(getResult.isSuccess, isTrue);
        expect(getResult.dataOrNull, isNotNull);
        expect(getResult.dataOrNull!['name'], equals('Test Pet'));
        expect(getResult.dataOrNull!['type'], equals('dog'));
        expect(getResult.dataOrNull!['progress'], equals(0.5));
      });

      test('should return null for non-existent temporary data', () async {
        // When
        final result = await databaseService.getTemporaryPetData('non-existent');

        // Then
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, isNull);
      });

      test('should clear all temporary pet data', () async {
        // Given
        await databaseService.saveTemporaryPetData('step1', {'data': 'value1'});
        await databaseService.saveTemporaryPetData('step2', {'data': 'value2'});

        // When
        final clearResult = await databaseService.clearTemporaryPetData();
        final getResult1 = await databaseService.getTemporaryPetData('step1');
        final getResult2 = await databaseService.getTemporaryPetData('step2');

        // Then
        expect(clearResult.isSuccess, isTrue);
        expect(getResult1.dataOrNull, isNull);
        expect(getResult2.dataOrNull, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle invalid JSON in additional info', () async {
        // Given
        final pet = PetProfileEntity(
          id: 'json-test',
          name: 'JSON Test Pet',
          type: 'cat',
          birthDate: DateTime(2020, 1, 1),
          gender: 'male',
          weight: 5.0,
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          additionalInfo: {
            'nested': {'deep': 'value'},
            'array': [1, 2, 3],
            'boolean': true,
          },
        );

        // When
        final saveResult = await databaseService.savePetProfile(pet);
        final getResult = await databaseService.getPetProfileById('json-test');

        // Then
        expect(saveResult.isSuccess, isTrue);
        expect(getResult.isSuccess, isTrue);
        expect(getResult.dataOrNull!.additionalInfo['nested'], isA<Map>());
        expect(getResult.dataOrNull!.additionalInfo['array'], isA<List>());
        expect(getResult.dataOrNull!.additionalInfo['boolean'], isTrue);
      });

      test('should fail to update non-existent pet', () async {
        // Given
        final nonExistentPet = PetProfileEntity(
          id: 'non-existent-update',
          name: 'Ghost Pet',
          type: 'ghost',
          birthDate: DateTime(2020, 1, 1),
          gender: 'unknown',
          weight: 0.0,
          ownerId: 'ghost-owner',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          additionalInfo: {},
        );

        // When
        final result = await databaseService.updatePetProfile(nonExistentPet);

        // Then
        expect(result.isSuccess, isFalse);
        expect(result.errorOrNull, contains('업데이트할 펫을 찾을 수 없습니다'));
      });

      test('should fail to delete non-existent pet', () async {
        // When
        final result = await databaseService.deletePetProfile('non-existent-delete');

        // Then
        expect(result.isSuccess, isFalse);
        expect(result.errorOrNull, contains('삭제할 펫을 찾을 수 없습니다'));
      });
    });
  });
}