import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/features/settings/domain/usecases/get_user_profile_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_profile_usecase_test.mocks.dart';

@GenerateMocks([SettingsRepository])
void main() {
  late GetUserProfileUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetUserProfileUseCase(mockRepository);
  });

  group('GetUserProfileUseCase', () {
    test(
      'should return user profile when repository call is successful',
      () async {
        // Arrange
        final mockUserProfile = UserProfileEntity(
          id: 'user-1',
          name: '田中太郎',
          email: 'tanaka@example.com',
          avatarPath: 'assets/images/avatars/default.png',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        when(
          mockRepository.getUserProfile(),
        ).thenAnswer((_) async => mockUserProfile);

        // Act
        final result = await useCase();

        // Assert
        expect(result, equals(mockUserProfile));
        verify(mockRepository.getUserProfile()).called(1);
      },
    );

    test('should throw exception when repository call fails', () async {
      // Arrange
      when(
        mockRepository.getUserProfile(),
      ).thenThrow(Exception('Failed to load user profile'));

      // Act & Assert
      expect(() => useCase(), throwsA(isA<Exception>()));
      verify(mockRepository.getUserProfile()).called(1);
    });
  });
}
