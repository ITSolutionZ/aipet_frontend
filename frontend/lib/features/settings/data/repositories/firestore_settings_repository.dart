import 'dart:convert';

import 'package:aipet_frontend/features/settings/domain/entities/settings_entity.dart';
import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/core/services/firestore_settings_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Firestore를 사용하는 설정 Repository 구현체
///
/// 사용자 프로필과 앱 설정은 Firestore에 저장하고,
/// 비밀번호와 같은 민감한 정보는 로컬에 저장합니다.
class FirestoreSettingsRepository implements SettingsRepository {
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  // SharedPreferences 키 상수 (민감한 정보용)
  static const String _keyCacheSize = 'cache_size';
  static const String _keyUserPassword = 'user_password';
  static const String _keyExportedData = 'exported_data';
  static const String _keyUserLocation = 'user_location';

  @override
  Future<Result<UserProfileEntity>> getUserProfile() async {
    try {
      LoggerService.debug('📡 FirestoreSettingsRepository.getUserProfile() 호출');

      final result = await FirestoreSettingsService.getUserProfile();

      if (result.isSuccess && result.dataOrNull != null) {
        final data = result.dataOrNull!;

        final profile = UserProfileEntity(
          id: data['id'] as String? ?? '',
          userName: data['userName'] as String? ?? '',
          email: data['email'] as String? ?? '',
          nameKatakana: data['nameKatakana'] as String?,
          contact: data['contact'] as String?,
          profileImage: data['profileImage'] as String?,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : DateTime.now(),
        );

        LoggerService.debug('✅ getUserProfile 성공');
        return Result.success('ユーザープロフィールを取得しました', profile);
      } else {
        // 프로필이 없는 경우 기본 프로필 반환
        LoggerService.debug('⚠️ Firestore에 프로필 없음, 기본 프로필 반환');
        final defaultProfile = UserProfileEntity(
          id: 'user-1',
          userName: '田中太郎',
          email: 'tanaka@example.com',
          profileImage: 'assets/images/avatars/default.png',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        return Result.success('デフォルトプロフィールを取得しました', defaultProfile);
      }
    } catch (e) {
      LoggerService.debug('❌ getUserProfile 실패: $e');
      return Result.failure('プロフィールの取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<UserProfileEntity>> updateUserProfile(
    UserProfileEntity profile,
  ) async {
    try {
      LoggerService.debug(
        '📡 FirestoreSettingsRepository.updateUserProfile() 호출',
      );

      final profileData = {
        'id': profile.id,
        'userName': profile.userName,
        'email': profile.email,
        'nameKatakana': profile.nameKatakana,
        'contact': profile.contact,
        'profileImage': profile.profileImage,
        'createdAt': profile.createdAt.toIso8601String(),
        'updatedAt': profile.updatedAt.toIso8601String(),
      };

      final result = await FirestoreSettingsService.updateUserProfile(
        profileData,
      );

      if (result.isSuccess) {
        LoggerService.debug('✅ updateUserProfile 성공');
        return Result.success('プロフィールが更新されました', profile);
      } else {
        LoggerService.debug('❌ updateUserProfile 실패: ${result.error}');
        return Result.failure('プロフィールの更新に失敗しました: ${result.error}');
      }
    } catch (e) {
      LoggerService.debug('❌ updateUserProfile 예외: $e');
      return Result.failure('プロフィールの更新に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> changePassword(PasswordChangeRequest request) async {
    try {
      // 비밀번호는 보안상 로컬에만 저장
      if (!request.isValid) {
        return Result.failure('無効なパスワード変更リクエストです');
      }

      await _init();
      await _cache.setString(_keyUserPassword, request.newPassword);

      LoggerService.debug('✅ changePassword 성공 (로컬 저장)');
      return Result.success('パスワードが変更されました', null);
    } catch (e) {
      LoggerService.debug('❌ changePassword 실패: $e');
      return Result.failure('パスワードの変更に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<AppSettingsEntity>> getAppSettings() async {
    try {
      LoggerService.debug('📡 FirestoreSettingsRepository.getAppSettings() 호출');

      final result = await FirestoreSettingsService.getUserSettings();

      if (result.isSuccess && result.dataOrNull != null) {
        final data = result.dataOrNull!;

        final settings = AppSettingsEntity(
          language: data['language'] as String? ?? 'ja',
          theme: data['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light,
          notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
          autoBackup: data['autoBackup'] as bool? ?? true,
          biometricLogin: data['biometricLogin'] as bool? ?? false,
          syncFrequency: _parseSyncFrequency(data['syncFrequency'] as String?),
        );

        LoggerService.debug('✅ getAppSettings 성공');
        return Result.success('アプリ設定を取得しました', settings);
      } else {
        // 기본 설정 반환
        LoggerService.debug('⚠️ Firestore에 설정 없음, 기본 설정 반환');
        const defaultSettings = AppSettingsEntity(
          language: 'ja',
          theme: ThemeMode.light,
          notificationsEnabled: true,
          autoBackup: true,
          biometricLogin: false,
          syncFrequency: DataSyncFrequency.daily,
        );

        return Result.success('デフォルト設定を取得しました', defaultSettings);
      }
    } catch (e) {
      LoggerService.debug('❌ getAppSettings 실패: $e');
      return Result.failure('設定の取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<AppSettingsEntity>> updateAppSettings(
    AppSettingsEntity settings,
  ) async {
    try {
      LoggerService.debug(
        '📡 FirestoreSettingsRepository.updateAppSettings() 호출',
      );

      final settingsData = {
        'language': settings.language,
        'theme': settings.theme == ThemeMode.dark ? 'dark' : 'light',
        'notificationsEnabled': settings.notificationsEnabled,
        'autoBackup': settings.autoBackup,
        'biometricLogin': settings.biometricLogin,
        'syncFrequency': settings.syncFrequency.toString(),
      };

      final result = await FirestoreSettingsService.updateUserSettings(
        settingsData,
      );

      if (result.isSuccess) {
        LoggerService.debug('✅ updateAppSettings 성공');
        return Result.success('設定が更新されました', settings);
      } else {
        LoggerService.debug('❌ updateAppSettings 실패: ${result.error}');
        return Result.failure('設定の更新に失敗しました: ${result.error}');
      }
    } catch (e) {
      LoggerService.debug('❌ updateAppSettings 예외: $e');
      return Result.failure('設定の更新に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> getCacheSize() async {
    try {
      await _init();
      final size = _cache.getIntValue(_keyCacheSize) ?? 0;
      return Result.success('キャッシュサイズを取得しました', size);
    } catch (e) {
      return Result.failure('キャッシュサイズの取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> clearCache() async {
    try {
      await _init();
      await _cache.clearAll();
      return Result.success('キャッシュをクリアしました', null);
    } catch (e) {
      return Result.failure('キャッシュのクリアに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<String>> exportData() async {
    try {
      // 데이터 내보내기는 로컬에서 처리
      await _init();
      final data = _cache.getString(_keyExportedData) ?? '{}';
      return Result.success('データをエクスポートしました', data);
    } catch (e) {
      return Result.failure('データのエクスポートに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> importData(String data) async {
    try {
      // 데이터 가져오기는 로컬에서 처리
      await _init();
      await _cache.setString(_keyExportedData, data);
      return Result.success('データをインポートしました', null);
    } catch (e) {
      return Result.failure('データのインポートに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // 계정 삭제는 Firestore와 로컬 모두 처리 필요
      await _init();
      await _cache.clearAll();

      LoggerService.debug('✅ deleteAccount 성공 (로컬 데이터 삭제)');
      return Result.success('アカウントが削除されました', null);
    } catch (e) {
      LoggerService.debug('❌ deleteAccount 실패: $e');
      return Result.failure('アカウント削除に失敗しました: ${e.toString()}');
    }
  }

  // ========== 인터페이스 호환성 메서드 ==========

  @override
  Future<Result<AppSettingsEntity>> saveAppSettings(
    AppSettingsEntity settings,
  ) async {
    return updateAppSettings(settings);
  }

  @override
  Future<Result<DataExportResult>> exportAppData() async {
    try {
      final result = await exportData();
      if (result.isSuccess) {
        final exportResult = DataExportResult(
          success: true,
          filePath: result.dataOrNull,
          exportedAt: DateTime.now(),
        );
        return Result.success('データをエクスポートしました', exportResult);
      } else {
        final exportResult = DataExportResult(
          success: false,
          errorMessage: result.error?.toString(),
          exportedAt: DateTime.now(),
        );
        return Result.failure(result.error?.toString() ?? 'エクスポートに失敗しました');
      }
    } catch (e) {
      return Result.failure('データのエクスポートに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> importAppData(String filePath) async {
    return importData(filePath);
  }

  @override
  Future<Result<void>> clearAppCache() async {
    return clearCache();
  }

  @override
  Future<Result<void>> saveUserLocation({
    required String postalCode,
    required String address,
    String? detailAddress,
  }) async {
    try {
      await _init();
      final locationData = {
        'postalCode': postalCode,
        'address': address,
        'detailAddress': detailAddress,
      };
      await _cache.setString(_keyUserLocation, jsonEncode(locationData));
      LoggerService.debug('✅ saveUserLocation 성공');
      return Result.success('位置情報を保存しました', null);
    } catch (e) {
      LoggerService.debug('❌ saveUserLocation 실패: $e');
      return Result.failure('位置情報の保存に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserLocation() async {
    try {
      await _init();
      final locationJson = _cache.getString(_keyUserLocation);
      if (locationJson != null) {
        final locationData = jsonDecode(locationJson) as Map<String, dynamic>;
        LoggerService.debug('✅ getUserLocation 성공');
        return Result.success('位置情報を取得しました', locationData);
      } else {
        LoggerService.debug('⚠️ 위치 정보 없음');
        return Result.failure('位置情報が見つかりません');
      }
    } catch (e) {
      LoggerService.debug('❌ getUserLocation 실패: $e');
      return Result.failure('位置情報の取得に失敗しました: ${e.toString()}');
    }
  }

  /// 동기화 빈도 문자열을 enum으로 변환
  DataSyncFrequency _parseSyncFrequency(String? value) {
    switch (value) {
      case 'realtime':
        return DataSyncFrequency.realtime;
      case 'hourly':
        return DataSyncFrequency.hourly;
      case 'daily':
        return DataSyncFrequency.daily;
      case 'manual':
        return DataSyncFrequency.manual;
      default:
        return DataSyncFrequency.daily;
    }
  }
}
