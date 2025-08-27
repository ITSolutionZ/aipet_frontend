import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/features/settings/domain/usecases/update_user_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_user_profile_usecase_test.mocks.dart';

@GenerateMocks([SettingsRepository])
void main() {
  late UpdateUserProfileUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = UpdateUserProfileUseCase(mockRepository);
  });

  group('UpdateUserProfileUseCase', () {
    test('should return true when repository call is successful', () async {
      // Arrange
      final userProfile = UserProfileEntity(
        id: 'user-1',
        name: '田中太郎',
        email: 'tanaka@example.com',
        avatarPath: 'assets/images/avatars/default.png',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      when(
        mockRepository.updateUserProfile(userProfile),
      ).thenAnswer((_) async => true);

      // Act
      final result = await useCase(userProfile);

      // Assert
      expect(result, isTrue);
      verify(mockRepository.updateUserProfile(userProfile)).called(1);
    });

    test('should return false when repository call fails', () async {
      // Arrange
      final userProfile = UserProfileEntity(
        id: 'user-1',
        name: '田中太郎',
        email: 'tanaka@example.com',
        avatarPath: 'assets/images/avatars/default.png',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      when(
        mockRepository.updateUserProfile(userProfile),
      ).thenAnswer((_) async => false);

      // Act
      final result = await useCase(userProfile);

      // Assert
      expect(result, isFalse);
      verify(mockRepository.updateUserProfile(userProfile)).called(1);
    });
  });
}
