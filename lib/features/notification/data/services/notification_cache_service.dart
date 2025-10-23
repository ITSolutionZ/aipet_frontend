import 'dart:async';
import 'dart:convert';

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';

import '../../domain/domain.dart';

/// 🗄️ 알림 캐시 서비스
///
/// API에서 받은 알림 데이터를 로컬에 캐시하여 성능을 향상시킵니다.
/// 네트워크가 불안정한 환경에서도 기본적인 알림 기능을 제공합니다.
class NotificationCacheService {
  static const String _tag = 'NotificationCacheService';

  // 캐시 키 정의
  static const String _notificationsCacheKey = 'cached_notifications';
  static const String _settingsCacheKey = 'cached_notification_settings';
  static const String _statsCacheKey = 'cached_notification_stats';

  // 캐시 만료 시간 (30분)
  static const Duration _cacheExpiration = Duration(minutes: 30);

  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();

  /// SharedPreferences 인스턴스 가져오기
  static Future<SharedPreferences> get _preferences async {
    return await _cache.initialize();
  }

  /// 알림 목록을 캐시에 저장
  ///
  /// [userId] 사용자 ID
  /// [notifications] 캐시할 알림 목록
  static Future<Result<bool>> cacheNotifications({
    required String userId,
    required List<NotificationModel> notifications,
  }) async {
    try {
      final prefs = await _preferences;
      final cacheKey = '${_notificationsCacheKey}_$userId';

      final notificationsJson = notifications
          .map((notification) => notification.toJson())
          .toList();

      final cacheData = {
        'data': notificationsJson,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(cacheKey, json.encode(cacheData));

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 알림 캐시 저장 완료: ${notifications.length}개');
      }

      return Result.success('Notifications cached successfully', true);
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 알림 캐시 저장 실패: $error');
      }
      return Result.failure('캐시 저장 중 오류 발생: $error');
    }
  }

  /// 캐시된 알림 목록 조회
  ///
  /// [userId] 사용자 ID
  static Future<Result<List<NotificationModel>>> getCachedNotifications(
    String userId,
  ) async {
    try {
      final prefs = await _preferences;
      final cacheKey = '${_notificationsCacheKey}_$userId';

      final cachedDataString = prefs.getString(cacheKey);
      if (cachedDataString == null) {
        return Result.failure('캐시된 데이터가 없습니다');
      }

      final cacheData = json.decode(cachedDataString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'],
      );

      // 캐시 만료 확인
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        if (kDebugMode) {
          LoggerService.debug('[$_tag] ⚠️ 캐시가 만료되었습니다');
        }
        return Result.failure('캐시가 만료되었습니다');
      }

      final notifications = (cacheData['data'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 캐시된 알림 조회 성공: ${notifications.length}개');
      }

      return Result.success('Cached notifications retrieved', notifications);
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 캐시 조회 실패: $error');
      }
      return Result.failure('캐시 조회 중 오류 발생: $error');
    }
  }

  /// 알림 설정을 캐시에 저장
  ///
  /// [userId] 사용자 ID
  /// [settings] 캐시할 설정 데이터
  static Future<Result<bool>> cacheSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final prefs = await _preferences;
      final cacheKey = '${_settingsCacheKey}_$userId';

      final cacheData = {
        'data': settings,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(cacheKey, json.encode(cacheData));

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 설정 캐시 저장 완료');
      }

      return Result.success('Settings cached successfully', true);
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 설정 캐시 저장 실패: $error');
      }
      return Result.failure('설정 캐시 저장 중 오류 발생: $error');
    }
  }

  /// 캐시된 알림 설정 조회
  ///
  /// [userId] 사용자 ID
  static Future<Result<Map<String, dynamic>>> getCachedSettings(
    String userId,
  ) async {
    try {
      final prefs = await _preferences;
      final cacheKey = '${_settingsCacheKey}_$userId';

      final cachedDataString = prefs.getString(cacheKey);
      if (cachedDataString == null) {
        return Result.failure('캐시된 설정이 없습니다');
      }

      final cacheData = json.decode(cachedDataString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'],
      );

      // 캐시 만료 확인
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        if (kDebugMode) {
          LoggerService.debug('[$_tag] ⚠️ 설정 캐시가 만료되었습니다');
        }
        return Result.failure('설정 캐시가 만료되었습니다');
      }

      final settings = cacheData['data'] as Map<String, dynamic>;

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 캐시된 설정 조회 성공');
      }

      return Result.success('Cached settings retrieved', settings);
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 설정 캐시 조회 실패: $error');
      }
      return Result.failure('설정 캐시 조회 중 오류 발생: $error');
    }
  }

  /// 특정 사용자의 캐시 삭제
  ///
  /// [userId] 사용자 ID
  static Future<Result<bool>> clearUserCache(String userId) async {
    try {
      final prefs = await _preferences;

      await prefs.remove('${_notificationsCacheKey}_$userId');
      await prefs.remove('${_settingsCacheKey}_$userId');
      await prefs.remove('${_statsCacheKey}_$userId');

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 사용자 캐시 삭제 완료: $userId');
      }

      return Result.success('User cache cleared successfully', true);
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 캐시 삭제 실패: $error');
      }
      return Result.failure('캐시 삭제 중 오류 발생: $error');
    }
  }

  /// 전체 캐시 삭제
  static Future<Result<bool>> clearAllCache() async {
    try {
      final prefs = await _preferences;
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_notificationsCacheKey) ||
            key.startsWith(_settingsCacheKey) ||
            key.startsWith(_statsCacheKey)) {
          await prefs.remove(key);
        }
      }

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 전체 캐시 삭제 완료');
      }

      return Result.success('All cache cleared successfully', true);
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 전체 캐시 삭제 실패: $error');
      }
      return Result.failure('전체 캐시 삭제 중 오류 발생: $error');
    }
  }

  /// 캐시 유효성 검사
  ///
  /// [userId] 사용자 ID
  static Future<bool> isCacheValid(String userId) async {
    try {
      final prefs = await _preferences;
      final cacheKey = '${_notificationsCacheKey}_$userId';

      final cachedDataString = prefs.getString(cacheKey);
      if (cachedDataString == null) {
        return false;
      }

      final cacheData = json.decode(cachedDataString);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'],
      );

      return DateTime.now().difference(timestamp) <= _cacheExpiration;
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 캐시 유효성 검사 실패: $error');
      }
      return false;
    }
  }

  /// 캐시 상태 정보 조회
  ///
  /// [userId] 사용자 ID
  static Future<Map<String, dynamic>> getCacheStatus(String userId) async {
    try {
      final prefs = await _preferences;

      final notificationsCacheKey = '${_notificationsCacheKey}_$userId';
      final settingsCacheKey = '${_settingsCacheKey}_$userId';

      final notificationsCache = prefs.getString(notificationsCacheKey);
      final settingsCache = prefs.getString(settingsCacheKey);

      DateTime? notificationsTimestamp;
      DateTime? settingsTimestamp;
      int notificationCount = 0;

      if (notificationsCache != null) {
        final cacheData = json.decode(notificationsCache);
        notificationsTimestamp = DateTime.fromMillisecondsSinceEpoch(
          cacheData['timestamp'],
        );
        notificationCount = (cacheData['data'] as List).length;
      }

      if (settingsCache != null) {
        final cacheData = json.decode(settingsCache);
        settingsTimestamp = DateTime.fromMillisecondsSinceEpoch(
          cacheData['timestamp'],
        );
      }

      return {
        'hasNotificationsCache': notificationsCache != null,
        'hasSettingsCache': settingsCache != null,
        'notificationsLastUpdated': notificationsTimestamp?.toIso8601String(),
        'settingsLastUpdated': settingsTimestamp?.toIso8601String(),
        'notificationCount': notificationCount,
        'isNotificationsCacheValid':
            notificationsTimestamp != null &&
            DateTime.now().difference(notificationsTimestamp) <=
                _cacheExpiration,
        'isSettingsCacheValid':
            settingsTimestamp != null &&
            DateTime.now().difference(settingsTimestamp) <= _cacheExpiration,
      };
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ 캐시 상태 조회 실패: $error');
      }
      return <String, dynamic>{};
    }
  }
}
