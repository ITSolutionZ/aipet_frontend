import 'package:aipet_frontend/features/notification/data/services/notification_api_service.dart';
import 'package:aipet_frontend/features/notification/data/services/notification_cache_service.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';

/// 📱 알림 Repository 구현체
///
/// 로컬 저장소와 캐시 서비스를 사용하여 효율적인 데이터 관리를 제공합니다.
/// 완전한 로컬 전용 구조로 외부 API 없이 동작합니다.
class NotificationRepositoryImpl implements NotificationRepository {
  static const String _tag = 'NotificationRepositoryImpl';

  final NotificationApiService _localService;

  NotificationRepositoryImpl({NotificationApiService? apiService})
    : _localService = apiService ?? NotificationApiService();

  @override
  Future<Result<List<NotificationModel>>> getAllNotifications({
    required String userId,
    int page = 0,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      // 1. 캐시가 유효한지 확인
      final isCacheValid = await NotificationCacheService.isCacheValid(userId);

      if (isCacheValid) {
        if (kDebugMode) {
          debugPrint('[$_tag] 🗄️ 유효한 캐시 데이터 사용');
        }
        return await NotificationCacheService.getCachedNotifications(userId);
      }

      // 2. 로컬 저장소에서 데이터 조회
      final localResult = await _localService.getNotifications(
        userId: userId,
        page: page,
        limit: limit,
        isRead: isRead,
        type: type,
      );

      if (localResult.isSuccess) {
        // 3. 성공한 경우 캐시에 저장
        final notifications = localResult.dataOrNull!;
        await NotificationCacheService.cacheNotifications(
          userId: userId,
          notifications: notifications,
        );

        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 로컬 저장소에서 알림 조회 및 캐시 저장 완료');
        }

        return localResult;
      } else {
        // 4. 로컬 조회 실패 시 캐시된 데이터라도 반환 시도
        if (kDebugMode) {
          debugPrint('[$_tag] ⚠️ 로컬 조회 실패, 캐시된 데이터 조회 시도');
        }

        final cacheResult =
            await NotificationCacheService.getCachedNotifications(userId);
        if (cacheResult.isSuccess) {
          if (kDebugMode) {
            debugPrint('[$_tag] 🗄️ 만료된 캐시 데이터 사용');
          }
          return cacheResult;
        }

        return localResult; // 캐시도 없으면 로컬 에러 반환
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 알림 조회 중 예외 발생: $error');
      }
      return Result.failure('알림 조회 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<NotificationModel?>> getNotificationById({
    required String userId,
    required String notificationId,
  }) async {
    try {
      // 1. 캐시에서 먼저 확인
      final cachedNotifications =
          await NotificationCacheService.getCachedNotifications(userId);
      if (cachedNotifications.isSuccess) {
        final notification = cachedNotifications.dataOrNull!
            .cast<NotificationModel?>()
            .firstWhere((n) => n?.id == notificationId, orElse: () => null);

        if (notification != null) {
          if (kDebugMode) {
            debugPrint('[$_tag] 🗄️ 캐시에서 특정 알림 조회 성공: $notificationId');
          }
          return Result.success('Notification found in cache', notification);
        }
      }

      // 2. 캐시에 없으면 전체 목록을 API에서 다시 조회
      final allNotifications = await getAllNotifications(userId: userId);
      if (allNotifications.isSuccess) {
        final notification = allNotifications.dataOrNull!
            .cast<NotificationModel?>()
            .firstWhere((n) => n?.id == notificationId, orElse: () => null);

        if (notification != null) {
          if (kDebugMode) {
            debugPrint('[$_tag] ✅ API에서 특정 알림 조회 성공: $notificationId');
          }
          return Result.success('Notification found via API', notification);
        }
      }

      if (kDebugMode) {
        debugPrint('[$_tag] ⚠️ 알림을 찾을 수 없음: $notificationId');
      }
      return Result.success('Notification not found', null);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 특정 알림 조회 중 예외 발생: $error');
      }
      return Result.failure('알림 조회 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<bool>> markAsRead({
    required String userId,
    required String notificationId,
    required bool isRead,
  }) async {
    try {
      // 1. 로컬 저장소에서 읽음 상태 업데이트
      final result = await _localService.markAsRead(
        notificationId: notificationId,
        isRead: isRead,
      );

      if (result.isSuccess) {
        // 2. 성공한 경우 캐시 무효화 (다음 조회 시 최신 데이터 받기 위해)
        await NotificationCacheService.clearUserCache(userId);

        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 읽음 상태 업데이트 및 캐시 무효화 완료');
        }
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 읽음 상태 업데이트 중 예외 발생: $error');
      }
      return Result.failure('읽음 상태 업데이트 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<bool>> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      // 1. 로컬 저장소에서 알림 삭제
      final result = await _localService.deleteNotification(notificationId);

      if (result.isSuccess) {
        // 2. 성공한 경우 캐시 무효화
        await NotificationCacheService.clearUserCache(userId);

        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 삭제 및 캐시 무효화 완료');
        }
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 알림 삭제 중 예외 발생: $error');
      }
      return Result.failure('알림 삭제 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getNotificationSettings(
    String userId,
  ) async {
    try {
      // 1. 캐시가 유효한지 확인
      final cachedSettings = await NotificationCacheService.getCachedSettings(
        userId,
      );
      if (cachedSettings.isSuccess) {
        if (kDebugMode) {
          debugPrint('[$_tag] 🗄️ 캐시된 설정 사용');
        }
        return cachedSettings;
      }

      // 2. 로컬 저장소에서 설정 조회
      final localResult = await _localService.getNotificationSettings(userId);

      if (localResult.isSuccess) {
        // 3. 성공한 경우 캐시에 저장
        final settings = localResult.dataOrNull!;
        await NotificationCacheService.cacheSettings(
          userId: userId,
          settings: settings,
        );

        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 로컬 저장소에서 설정 조회 및 캐시 저장 완료');
        }
      }

      return localResult;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 설정 조회 중 예외 발생: $error');
      }
      return Result.failure('설정 조회 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<bool>> updateNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      // 1. 로컬 저장소에서 설정 업데이트
      final result = await _localService.updateNotificationSettings(
        userId: userId,
        settings: settings,
      );

      if (result.isSuccess) {
        // 2. 성공한 경우 캐시에도 업데이트
        await NotificationCacheService.cacheSettings(
          userId: userId,
          settings: settings,
        );

        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 설정 업데이트 및 캐시 동기화 완료');
        }
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 설정 업데이트 중 예외 발생: $error');
      }
      return Result.failure('설정 업데이트 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getNotificationStats(
    String userId,
  ) async {
    try {
      // 로컬 저장소에서 통계 조회
      return await _localService.getNotificationStats(userId);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 통계 조회 중 예외 발생: $error');
      }
      return Result.failure('통계 조회 중 오류 발생: $error');
    }
  }

  /// Repository 정리
  void dispose() {
    _localService.dispose();
  }
}
