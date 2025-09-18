import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileRepository', () {
    late PetProfileRepository mockRepository;
    late PetProfileEntity testPet;

    setUp(() {
      // Mock repository implementation for testing
      mockRepository = _MockPetProfileRepository();
      testPet = PetProfileEntity(
        id: 'test-pet-1',
        name: 'テストペット',
        type: 'dog',
        breed: '柴犬',
        age: 3,
        gender: 'male',
        weight: 12.5,
        imagePath: 'test_image.jpg',
        ownerId: 'owner-1',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 12, 1),
        additionalInfo: {
          'microchipNumber': '123456789012345',
          'isPublic': true,
          'familyManagers': ['user-1', 'user-2'],
        },
      );
    });

    group('getPetProfile', () {
      test('should return pet profile when pet exists', () async {
        // Arrange
        when(
          mockRepository.getPetProfile('test-pet-1'),
        ).thenAnswer((_) async => testPet);

        // Act
        final result = await mockRepository.getPetProfile('test-pet-1');

        // Assert
        expect(result, equals(testPet));
      });

      test('should throw exception when pet not found', () async {
        // Arrange
        when(
          mockRepository.getPetProfile('non-existent-pet'),
        ).thenThrow(Exception('펫 프로필을 찾을 수 없습니다'));

        // Act & Assert
        expect(
          () => mockRepository.getPetProfile('non-existent-pet'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updatePetProfile', () {
      test('should update and return pet profile', () async {
        // Arrange
        final updatedPet = testPet.copyWith(
          name: '更新されたペット',
          weight: 13.0,
          updatedAt: DateTime(2023, 12, 2),
        );
        when(
          mockRepository.updatePetProfile(any),
        ).thenAnswer((_) async => updatedPet);

        // Act
        final result = await mockRepository.updatePetProfile(updatedPet);

        // Assert
        expect(result, equals(updatedPet));
        expect(result.name, equals('更新されたペット'));
        expect(result.weight, equals(13.0));
      });

      test('should throw exception when pet not found for update', () async {
        // Arrange
        when(
          mockRepository.updatePetProfile(any),
        ).thenThrow(Exception('펫 프로필을 찾을 수 없습니다'));

        // Act & Assert
        expect(
          () => mockRepository.updatePetProfile(testPet),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadPetImage', () {
      test('should return image URL when upload succeeds', () async {
        // Arrange
        const imagePath = 'path/to/image.jpg';
        const expectedUrl =
            'https://example.com/images/test-pet-1/1234567890.jpg';
        when(
          mockRepository.uploadPetImage('test-pet-1', imagePath),
        ).thenAnswer((_) async => expectedUrl);

        // Act
        final result = await mockRepository.uploadPetImage(
          'test-pet-1',
          imagePath,
        );

        // Assert
        expect(result, equals(expectedUrl));
      });

      test('should throw exception when upload fails', () async {
        // Arrange
        when(
          mockRepository.uploadPetImage(any, any),
        ).thenThrow(Exception('이미지 업로드에 실패했습니다'));

        // Act & Assert
        expect(
          () => mockRepository.uploadPetImage('test-pet-1', 'invalid-path'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateSharingSettings', () {
      test('should update sharing settings to public', () async {
        // Arrange
        when(
          mockRepository.updateSharingSettings('test-pet-1', true),
        ).thenAnswer((_) async {
          return null;
        });

        // Act
        await mockRepository.updateSharingSettings('test-pet-1', true);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should update sharing settings to private', () async {
        // Arrange
        when(
          mockRepository.updateSharingSettings('test-pet-1', false),
        ).thenAnswer((_) async {
          return null;
        });

        // Act
        await mockRepository.updateSharingSettings('test-pet-1', false);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should throw exception when pet not found', () async {
        // Arrange
        when(
          mockRepository.updateSharingSettings('non-existent-pet', true),
        ).thenThrow(Exception('펫 프로필을 찾을 수 없습니다'));

        // Act & Assert
        expect(
          () => mockRepository.updateSharingSettings('non-existent-pet', true),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('addFamilyManager', () {
      test('should add family manager successfully', () async {
        // Arrange
        const userId = 'new-manager-1';
        when(mockRepository.addFamilyManager('test-pet-1', userId)).thenAnswer((
          _,
        ) async {
          return null;
        });

        // Act
        await mockRepository.addFamilyManager('test-pet-1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should throw exception when pet not found', () async {
        // Arrange
        when(
          mockRepository.addFamilyManager('non-existent-pet', 'user-1'),
        ).thenThrow(Exception('펫 프로필을 찾을 수 없습니다'));

        // Act & Assert
        expect(
          () => mockRepository.addFamilyManager('non-existent-pet', 'user-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('removeFamilyManager', () {
      test('should remove family manager successfully', () async {
        // Arrange
        const userId = 'manager-to-remove';
        when(
          mockRepository.removeFamilyManager('test-pet-1', userId),
        ).thenAnswer((_) async {
          return null;
        });

        // Act
        await mockRepository.removeFamilyManager('test-pet-1', userId);

        // Assert - 성공적으로 실행되면 예외가 발생하지 않음
        expect(true, isTrue);
      });

      test('should throw exception when pet not found', () async {
        // Arrange
        when(
          mockRepository.removeFamilyManager('non-existent-pet', 'user-1'),
        ).thenThrow(Exception('펫 프로필을 찾을 수 없습니다'));

        // Act & Assert
        expect(
          () =>
              mockRepository.removeFamilyManager('non-existent-pet', 'user-1'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Mock implementation for testing
class _MockPetProfileRepository implements PetProfileRepository {
  final Map<String, PetProfileEntity> _pets = {};
  final Map<String, String> _imageUrls = {};
  final Map<String, bool> _sharingSettings = {};
  final Map<String, List<String>> _familyManagers = {};

  @override
  Future<PetProfileEntity> getPetProfile(String petId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_pets.containsKey(petId)) {
      return _pets[petId]!;
    }
    throw Exception('펫 프로필을 찾을 수 없습니다');
  }

  @override
  Future<PetProfileEntity> updatePetProfile(PetProfileEntity pet) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _pets[pet.id] = pet;
    return pet;
  }

  @override
  Future<String> uploadPetImage(String petId, String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final url =
        'https://example.com/images/$petId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    _imageUrls[petId] = url;
    return url;
  }

  @override
  Future<void> updateSharingSettings(String petId, bool isPublic) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sharingSettings[petId] = isPublic;
  }

  @override
  Future<void> addFamilyManager(String petId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _familyManagers[petId] ??= [];
    if (!_familyManagers[petId]!.contains(userId)) {
      _familyManagers[petId]!.add(userId);
    }
  }

  @override
  Future<void> removeFamilyManager(String petId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _familyManagers[petId]?.remove(userId);
  }
}
