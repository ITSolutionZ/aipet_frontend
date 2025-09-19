import 'dart:convert';

import 'package:aipet_frontend/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepositoryImpl();
  });

  group('SettingsRepositoryImpl', () {
    test('should return user profile when getUserProfile is called', () async {
      // Act
      final result = await repository.getUserProfile();

      // Assert
      expect(result, isA<Result<UserProfileEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<UserProfileEntity>());
      expect(result.data!.id, equals('user-1'));
      expect(result.data!.name, equals('田中太郎'));
      expect(result.data!.email, equals('tanaka@example.com'));
    });

    test('should return app settings when getAppSettings is called', () async {
      // Act
      final result = await repository.getAppSettings();

      // Assert
      expect(result, isA<Result<AppSettingsEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<AppSettingsEntity>());
      expect(result.data!.language, equals('ja'));
      expect(result.data!.theme, equals(ThemeMode.light));
      expect(result.data!.notificationsEnabled, isTrue);
      expect(result.data!.autoBackup, isTrue);
      expect(result.data!.biometricLogin, isFalse);
      expect(result.data!.syncFrequency, equals(DataSyncFrequency.daily));
    });

    test('should return success when updateUserProfile is called', () async {
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
      expect(result, isA<Result<UserProfileEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<UserProfileEntity>());
    });

    test('should return success when saveAppSettings is called', () async {
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
      expect(result, isA<Result<AppSettingsEntity>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<AppSettingsEntity>());
    });

    test(
      'should return success when changePassword is called with valid request',
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
        expect(result, isA<Result<void>>());
        expect(result.isSuccess, isTrue);
      },
    );

    test(
      'should return failure when changePassword is called with invalid request',
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
        expect(result, isA<Result<void>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('無効なパスワード変更リクエストです'));
      },
    );

    test('should return success when deleteAccount is called', () async {
      // Act
      final result = await repository.deleteAccount();

      // Assert
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
    });

    test('should return export result when exportAppData is called', () async {
      // Act
      final result = await repository.exportAppData();

      // Assert
      expect(result, isA<Result<DataExportResult>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<DataExportResult>());
      expect(result.data!.success, isTrue);
      expect(result.data!.filePath, isNotNull);
      expect(result.data!.exportedAt, isA<DateTime>());
    });

    test('should return success when importAppData is called', () async {
      // Arrange
      const filePath = '/path/to/data.json';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'exported_data',
        jsonEncode({
          'userProfile': jsonEncode({
            'id': 'user-1',
            'name': '田中太郎',
            'email': 'tanaka@example.com',
            'avatarPath': 'assets/images/avatars/default.png',
            'createdAt': DateTime.now().toIso8601String(),
            'lastLoginAt': DateTime.now().toIso8601String(),
          }),
          'appSettings': jsonEncode({
            'language': 'ja',
            'theme': 'light',
            'notificationsEnabled': true,
            'autoBackup': true,
            'biometricLogin': false,
            'syncFrequency': 'daily',
          }),
        }),
      );

      // Act
      final result = await repository.importAppData(filePath);

      // Assert
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
    });

    test('should return success when clearAppCache is called', () async {
      // Act
      final result = await repository.clearAppCache();

      // Assert
      expect(result, isA<Result<void>>());
      expect(result.isSuccess, isTrue);
    });

    test('should return cache size when getCacheSize is called', () async {
      // Act
      final result = await repository.getCacheSize();

      // Assert
      expect(result, isA<Result<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.data, isA<int>());
      expect(result.data, equals(1024 * 1024 * 5)); // 5MB
    });
  });
}
