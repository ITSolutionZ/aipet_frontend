import 'dart:convert';

import 'package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  // SharedPreferences 키 상수
  static const String _keyUserProfile = 'user_profile';
  static const String _keyAppSettings = 'app_settings';
  static const String _keyCacheSize = 'cache_size';
  static const String _keyUserPassword = 'user_password';
  static const String _keyExportedData = 'exported_data';

  // 기본 사용자 프로필
  final Map<String, dynamic> _defaultUserProfile = {
    'id': 'user-1',
    'name': '田中太郎',
    'email': 'tanaka@example.com',
    'avatarPath': 'assets/images/avatars/default.png',
    'createdAt': DateTime.now(),
    'lastLoginAt': DateTime.now(),
  };

  // 기본 앱 설정
  final Map<String, dynamic> _defaultAppSettings = {
    'language': 'ja',
    'theme': ThemeMode.light,
    'notificationsEnabled': true,
    'autoBackup': true,
    'biometricLogin': false,
    'syncFrequency': DataSyncFrequency.daily,
  };

  @override
  Future<Result<Map<String, dynamic>>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_keyUserProfile);

      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        final profile = {
          'id': profileMap['id'] as String,
          'name': profileMap['name'] as String,
          'email': profileMap['email'] as String,
          'avatarPath': profileMap['avatarPath'] as String?,
          'createdAt': DateTime.parse(profileMap['createdAt'] as String),
          'lastLoginAt': profileMap['lastLoginAt'] != null
              ? DateTime.parse(profileMap['lastLoginAt'] as String)
              : null,
        };
        return Result.success('ユーザープロフィールを取得しました', profile);
      }

      return Result.success('デフォルトプロフィールを取得しました', _defaultUserProfile);
    } catch (e) {
      return Result.failure('プロフィールの取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> updateUserProfile(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileMap = {
        'id': profile['id'],
        'name': profile['name'],
        'email': profile['email'],
        'avatarPath': profile['avatarPath'],
        'createdAt': (profile['createdAt'] as DateTime).toIso8601String(),
        'lastLoginAt': (profile['lastLoginAt'] as DateTime?)?.toIso8601String(),
      };

      await prefs.setString(_keyUserProfile, jsonEncode(profileMap));
      return Result.success('プロフィールが更新されました', profile);
    } catch (e) {
      return Result.failure('プロフィールの更新に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> changePassword(Map<String, dynamic> request) async {
    try {
      // 비밀번호 유효성 검사
      if (request['isValid'] != true) {
        return Result.failure('無効なパスワード変更リクエストです');
      }

      // 로컬에서 비밀번호 변경 처리 (실제로는 암호화 필요)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserPassword, request['newPassword'] as String);

      return Result.success('パスワードが変更されました', null);
    } catch (e) {
      return Result.failure('パスワードの変更に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 사용자 관련 모든 데이터 삭제
      await prefs.remove(_keyUserProfile);
      await prefs.remove(_keyAppSettings);
      await prefs.remove(_keyUserPassword);
      await prefs.remove(_keyCacheSize);
      await prefs.remove(_keyExportedData);

      return Result.success('アカウントが削除されました', null);
    } catch (e) {
      return Result.failure('アカウントの削除に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_keyAppSettings);

      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        final settings = {
          'language': settingsMap['language'] as String,
          'theme': ThemeMode.values.firstWhere(
            (e) => e.name == settingsMap['theme'],
            orElse: () => ThemeMode.light,
          ),
          'notificationsEnabled': settingsMap['notificationsEnabled'] as bool,
          'autoBackup': settingsMap['autoBackup'] as bool,
          'biometricLogin': settingsMap['biometricLogin'] as bool,
          'syncFrequency': DataSyncFrequency.values.firstWhere(
            (e) => e.name == settingsMap['syncFrequency'],
            orElse: () => DataSyncFrequency.daily,
          ),
        };
        return Result.success('アプリ設定を取得しました', settings);
      }

      return Result.success('デフォルト設定を取得しました', _defaultAppSettings);
    } catch (e) {
      return Result.failure('アプリ設定の取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsMap = {
        'language': settings['language'],
        'theme': (settings['theme'] as ThemeMode).name,
        'notificationsEnabled': settings['notificationsEnabled'],
        'autoBackup': settings['autoBackup'],
        'biometricLogin': settings['biometricLogin'],
        'syncFrequency': (settings['syncFrequency'] as DataSyncFrequency).name,
      };

      await prefs.setString(_keyAppSettings, jsonEncode(settingsMap));
      return Result.success('アプリ設定が保存されました', settings);
    } catch (e) {
      return Result.failure('アプリ設定の保存に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<Result<dynamic>>> exportAppData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 모든 설정 데이터 수집
      final exportData = {
        'userProfile': prefs.getString(_keyUserProfile),
        'appSettings': prefs.getString(_keyAppSettings),
        'exportedAt': DateTime.now().toIso8601String(),
      };

      // SharedPreferences에 임시 저장
      await prefs.setString(_keyExportedData, jsonEncode(exportData));

      final exportResult = Result.success('エクスポートが完了しました', {
        'success': true,
        'filePath': 'local://exported_data.json',
        'exportedAt': DateTime.now(),
      });
      return Result.success('アプリデータがエクスポートされました', exportResult);
    } catch (e) {
      return Result.failure('アプリデータのエクスポートに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> importAppData(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exportedDataJson = prefs.getString(_keyExportedData);

      if (exportedDataJson != null) {
        final exportedData = jsonDecode(exportedDataJson) as Map<String, dynamic>;

        // 데이터 복원
        if (exportedData['userProfile'] != null) {
          await prefs.setString(_keyUserProfile, exportedData['userProfile']);
        }
        if (exportedData['appSettings'] != null) {
          await prefs.setString(_keyAppSettings, exportedData['appSettings']);
        }

        return Result.success('アプリデータがインポートされました', null);
      }

      return Result.failure('インポートするデータが見つかりません');
    } catch (e) {
      return Result.failure('アプリデータのインポートに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> clearAppCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 캐시 관련 데이터만 삭제 (사용자 데이터는 유지)
      await prefs.remove(_keyCacheSize);
      await prefs.remove(_keyExportedData);

      return Result.success('キャッシュがクリアされました', null);
    } catch (e) {
      return Result.failure('キャッシュのクリアに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSize = prefs.getInt(_keyCacheSize);

      if (cachedSize != null) {
        return Result.success('キャッシュサイズを取得しました', cachedSize);
      }

      // 기본 캐시 크기 계산 (실제로는 파일 시스템에서 계산)
      const defaultSize = 1024 * 1024 * 5; // 5MB
      await prefs.setInt(_keyCacheSize, defaultSize);

      return Result.success('デフォルトキャッシュサイズを取得しました', defaultSize);
    } catch (e) {
      return Result.failure('キャッシュサイズの取得に失敗しました: ${e.toString()}');
    }
  }
}
