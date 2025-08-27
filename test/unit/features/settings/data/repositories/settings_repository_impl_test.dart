import 'package:aipet_frontend/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsRepositoryImpl repository;

  setUp(() {
    repository = SettingsRepositoryImpl();
  });

  group('SettingsRepositoryImpl', () {
    test('should return user profile when getUserProfile is called', () async {
      // Act
      final result = await repository.getUserProfile();

      // Assert
      expect(result, isA<UserProfileEntity>());
      expect(result.id, equals('user-1'));
      expect(result.name, equals('田中太郎'));
      expect(result.email, equals('tanaka@example.com'));
    });

    test('should return app settings when getAppSettings is called', () async {
      // Act
      final result = await repository.getAppSettings();

      // Assert
      expect(result, isA<AppSettingsEntity>());
      expect(result.language, equals('ja'));
      expect(result.theme, equals(ThemeMode.light));
      expect(result.notificationsEnabled, isTrue);
      expect(result.autoBackup, isTrue);
      expect(result.biometricLogin, isFalse);
      expect(result.syncFrequency, equals(DataSyncFrequency.daily));
    });

    test('should return true when updateUserProfile is called', () async {
      // Arrange
      final userProfile = UserProfileEntity(
        id: 'user-1',
        name: '田中太郎',
        email: 'tanaka@example.com',
        avatarPath: 'assets/images/avatars/default.png',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Act
      final result = await repository.updateUserProfile(userProfile);

      // Assert
      expect(result, isTrue);
    });

    test('should return true when saveAppSettings is called', () async {
      // Arrange
      const appSettings = AppSettingsEntity(
        language: 'ja',
        theme: ThemeMode.light,
        notificationsEnabled: true,
        autoBackup: true,
        biometricLogin: false,
        syncFrequency: DataSyncFrequency.daily,
      );

      // Act
      final result = await repository.saveAppSettings(appSettings);

      // Assert
      expect(result, isTrue);
    });

    test(
      'should return true when changePassword is called with valid request',
      () async {
        // Arrange
        const request = PasswordChangeRequest(
          currentPassword: 'oldpass',
          newPassword: 'newpass123',
          confirmPassword: 'newpass123',
        );

        // Act
        final result = await repository.changePassword(request);

        // Assert
        expect(result, isTrue);
      },
    );

    test(
      'should return false when changePassword is called with invalid request',
      () async {
        // Arrange
        const request = PasswordChangeRequest(
          currentPassword: 'oldpass',
          newPassword: 'newpass123',
          confirmPassword: 'differentpass',
        );

        // Act
        final result = await repository.changePassword(request);

        // Assert
        expect(result, isFalse);
      },
    );

    test('should return true when deleteAccount is called', () async {
      // Act
      final result = await repository.deleteAccount();

      // Assert
      expect(result, isTrue);
    });

    test('should return export result when exportAppData is called', () async {
      // Act
      final result = await repository.exportAppData();

      // Assert
      expect(result, isA<DataExportResult>());
      expect(result.success, isTrue);
      expect(result.filePath, isNotNull);
      expect(result.exportedAt, isA<DateTime>());
    });

    test('should return true when importAppData is called', () async {
      // Arrange
      const filePath = '/path/to/data.json';

      // Act
      final result = await repository.importAppData(filePath);

      // Assert
      expect(result, isTrue);
    });

    test('should return true when clearAppCache is called', () async {
      // Act
      final result = await repository.clearAppCache();

      // Assert
      expect(result, isTrue);
    });

    test('should return cache size when getCacheSize is called', () async {
      // Act
      final result = await repository.getCacheSize();

      // Assert
      expect(result, isA<int>());
      expect(result, equals(1024 * 1024 * 5)); // 5MB
    });
  });
}
