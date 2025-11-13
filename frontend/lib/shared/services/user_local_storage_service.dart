import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ユーザーローカルストレージサービス
///
/// ユーザー情報をローカルに保存・管理します
class UserLocalStorageService {
  static const String _keyUserProfile = 'local_user_profile';
  static const String _keyUserSettings = 'local_user_settings';

  /// ユーザープロフィールを取得
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_keyUserProfile);

      if (profileJson != null) {
        return jsonDecode(profileJson) as Map<String, dynamic>;
      }

      // デフォルトユーザープロフィール
      return await _initializeDefaultProfile();
    } catch (e) {
      debugPrint('ユーザープロフィール取得エラー: $e');
      return {};
    }
  }

  /// 初期デフォルトプロフィールを作成
  static Future<Map<String, dynamic>> _initializeDefaultProfile() async {
    final defaultProfile = {
      'id': 'user1',
      'name': '田中太郎',
      'email': 'tanaka@example.com',
      'avatarPath': 'assets/images/placeholder.png',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
    };

    await saveUserProfile(defaultProfile);
    return defaultProfile;
  }

  /// ユーザープロフィールを保存
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserProfile, jsonEncode(profile));
      debugPrint('✅ ユーザープロフィール保存成功');
    } catch (e) {
      debugPrint('ユーザープロフィール保存エラー: $e');
    }
  }

  /// ユーザー設定を取得
  static Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_keyUserSettings);

      if (settingsJson != null) {
        return jsonDecode(settingsJson) as Map<String, dynamic>;
      }

      // デフォルト設定
      return {
        'notificationsEnabled': true,
        'darkMode': false,
        'language': 'ja',
      };
    } catch (e) {
      debugPrint('ユーザー設定取得エラー: $e');
      return {};
    }
  }

  /// ユーザー設定を保存
  static Future<void> saveUserSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserSettings, jsonEncode(settings));
      debugPrint('✅ ユーザー設定保存成功');
    } catch (e) {
      debugPrint('ユーザー設定保存エラー: $e');
    }
  }

  /// すべてのユーザーデータをクリア
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserProfile);
    await prefs.remove(_keyUserSettings);
  }
}
