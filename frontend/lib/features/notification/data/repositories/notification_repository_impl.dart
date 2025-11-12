import '../../../../shared/shared.dart';

import '../../domain/domain.dart';
import '../services/backend_notification_api_service.dart';
import '../services/notification_cache_service.dart';

/// 📱 알림 Repository 구현체
///
/// Backend API 연동: BackendNotificationApiService 사용
/// 캐시 서비스를 함께 사용하여 효율적인 데이터 관리 제공
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl();

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
        LoggerService.debug('✅ NotificationRepository: 유효한 캐시 데이터 사용');
        return await NotificationCacheService.getCachedNotifications(userId);
      }

      // 2. Backend API에서 데이터 조회
      final result = await BackendNotificationApiService.getNotifications(
        isRead: isRead,
        notificationType: type,
        limit: limit,
      );

      if (result.isSuccess) {
        // 3. 성공한 경우 캐시에 저장
        final notifications = result.dataOrNull!;
        await NotificationCacheService.cacheNotifications(
          userId: userId,
          notifications: notifications,
        );

        LoggerService.debug(
          '✅ NotificationRepository: Backend API에서 알림 조회 및 캐시 저장 완료 (${notifications.length}개)',
        );

        return result;
      } else {
        // 4. API 조회 실패 시 캐시된 데이터라도 반환 시도
        LoggerService.debug(
          '⚠️ NotificationRepository: API 조회 실패, 캐시된 데이터 조회 시도',
        );

        final cacheResult =
            await NotificationCacheService.getCachedNotifications(userId);
        if (cacheResult.isSuccess) {
          LoggerService.debug('✅ NotificationRepository: 만료된 캐시 데이터 사용');
          return cacheResult;
        }

        return result; // 캐시도 없으면 API 에러 반환
      }
    } catch (error) {
      LoggerService.debug('❌ NotificationRepository: 알림 조회 중 예외 발생 - $error');
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
          LoggerService.debug(
            '✅ NotificationRepository: 캐시에서 특정 알림 조회 성공 - $notificationId',
          );
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
          LoggerService.debug(
            '✅ NotificationRepository: API에서 특정 알림 조회 성공 - $notificationId',
          );
          return Result.success('Notification found via API', notification);
        }
      }

      LoggerService.debug(
        '⚠️ NotificationRepository: 알림을 찾을 수 없음 - $notificationId',
      );
      return Result.success('Notification not found', null);
    } catch (error) {
      LoggerService.debug(
        '❌ NotificationRepository: 특정 알림 조회 중 예외 발생 - $error',
      );
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
      // Backend API는 읽음 처리만 지원 (isRead=true만 가능)
      if (!isRead) {
        LoggerService.debug(
          '⚠️ NotificationRepository: 읽지않음 처리는 Backend API에서 지원하지 않음',
        );
        return Result.failure('읽지않음 처리는 지원되지 않습니다');
      }

      // 1. Backend API에서 읽음 상태 업데이트
      final result = await BackendNotificationApiService.markAsRead(
        notificationId: notificationId,
      );

      if (result.isSuccess) {
        // 2. 성공한 경우 캐시 무효화 (다음 조회 시 최신 데이터 받기 위해)
        await NotificationCacheService.clearUserCache(userId);
        LoggerService.debug(
          '✅ NotificationRepository: 읽음 상태 업데이트 및 캐시 무효화 완료 (Backend API)',
        );
        return Result.success('알림을 읽음으로 표시했습니다', true);
      }

      return Result.failure(result.error?.toString() ?? '읽음 상태 업데이트 실패');
    } catch (error) {
      LoggerService.debug(
        '❌ NotificationRepository: 읽음 상태 업데이트 중 예외 발생 - $error',
      );
      return Result.failure('읽음 상태 업데이트 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<bool>> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      // 1. Backend API에서 알림 삭제
      final result = await BackendNotificationApiService.deleteNotification(
        notificationId: notificationId,
      );

      if (result.isSuccess) {
        // 2. 성공한 경우 캐시 무효화
        await NotificationCacheService.clearUserCache(userId);
        LoggerService.debug(
          '✅ NotificationRepository: 알림 삭제 및 캐시 무효화 완료 (Backend API)',
        );
        return Result.success('알림을 삭제했습니다', true);
      }

      return Result.failure(result.error?.toString() ?? '알림 삭제 실패');
    } catch (error) {
      LoggerService.debug('❌ NotificationRepository: 알림 삭제 중 예외 발생 - $error');
      return Result.failure('알림 삭제 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getNotificationSettings(
    String userId,
  ) async {
    try {
      // Backend API에는 설정 관리 엔드포인트가 없으므로 로컬 캐시만 사용
      LoggerService.debug(
        '⚠️ NotificationRepository: 설정은 Backend API에서 지원하지 않음, 로컬 캐시 사용',
      );

      final cachedSettings = await NotificationCacheService.getCachedSettings(
        userId,
      );

      if (cachedSettings.isSuccess) {
        return cachedSettings;
      }

      // 기본 설정 반환
      final defaultSettings = {
        'pushEnabled': true,
        'emailEnabled': false,
        'notificationTypes': {
          'vaccination': true,
          'feeding': true,
          'walk': true,
          'medical': true,
          'general': true,
        },
      };

      await NotificationCacheService.cacheSettings(
        userId: userId,
        settings: defaultSettings,
      );

      return Result.success('기본 설정을 사용합니다', defaultSettings);
    } catch (error) {
      LoggerService.debug('❌ NotificationRepository: 설정 조회 중 예외 발생 - $error');
      return Result.failure('설정 조회 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<bool>> updateNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      // Backend API에는 설정 관리 엔드포인트가 없으므로 로컬 캐시만 업데이트
      LoggerService.debug(
        '⚠️ NotificationRepository: 설정은 Backend API에서 지원하지 않음, 로컬 캐시만 업데이트',
      );

      await NotificationCacheService.cacheSettings(
        userId: userId,
        settings: settings,
      );

      LoggerService.debug('✅ NotificationRepository: 설정 로컬 캐시 업데이트 완료');
      return Result.success('설정을 업데이트했습니다', true);
    } catch (error) {
      LoggerService.debug('❌ NotificationRepository: 설정 업데이트 중 예외 발생 - $error');
      return Result.failure('설정 업데이트 중 오류 발생: $error');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getNotificationStats(
    String userId,
  ) async {
    try {
      // Backend API에는 통계 엔드포인트가 없으므로 로컬에서 계산
      LoggerService.debug(
        '⚠️ NotificationRepository: 통계는 Backend API에서 지원하지 않음, 로컬 계산',
      );

      // 읽지 않은 알림 개수만 Backend API에서 가져오기
      final unreadCountResult =
          await BackendNotificationApiService.getUnreadCount();

      final unreadCount = unreadCountResult.isSuccess
          ? (unreadCountResult.dataOrNull ?? 0)
          : 0;

      final stats = {
        'unreadCount': unreadCount,
        'totalCount': 0, // Backend API에서 제공하지 않음
        'readCount': 0, // Backend API에서 제공하지 않음
      };

      return Result.success('통계를 조회했습니다', stats);
    } catch (error) {
      LoggerService.debug('❌ NotificationRepository: 통계 조회 중 예외 발생 - $error');
      return Result.failure('통계 조회 중 오류 발생: $error');
    }
  }
}
