import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import '../../domain/domain.dart';
import 'notification_local_storage_service.dart';

/// 📱 알림 로컬 서비스 (API 대신 로컬 저장소 사용)
///
/// 로컬 저장소를 사용하여 알림 데이터를 관리합니다.
/// 개발 모드에서는 완전히 로컬 데이터만 사용합니다.
class NotificationApiService {
  static const String _tag = 'NotificationApiService';

  /// 사용자의 알림 목록 조회 (로컬 저장소 사용)
  ///
  /// [userId] 사용자 ID
  /// [page] 페이지 번호 (0부터 시작)
  /// [limit] 페이지당 항목 수
  /// [isRead] 읽음 상태 필터 (null이면 전체)
  /// [type] 알림 타입 필터 (null이면 전체)
  Future<Result<List<NotificationModel>>> getNotifications({
    required String userId,
    int page = 0,
    int limit = 20,
    bool? isRead,
    String? type,
  }) async {
    try {
      // 로컬 저장소에서 알림 조회
      final notificationsData =
          await NotificationLocalStorageService.getNotifications();

      final notifications = notificationsData
          .map((data) => NotificationModel.fromJson(data))
          .toList();

      // 필터링 적용
      var filteredNotifications = notifications;

      if (isRead != null) {
        filteredNotifications = filteredNotifications
            .where(
              (n) => (isRead
                  ? n.status == NotificationStatus.read
                  : n.status == NotificationStatus.unread),
            )
            .toList();
      }

      if (type != null) {
        filteredNotifications = filteredNotifications
            .where((n) => n.type.name == type)
            .toList();
      }

      // 페이지네이션 적용
      final startIndex = page * limit;
      final endIndex = (startIndex + limit < filteredNotifications.length)
          ? startIndex + limit
          : filteredNotifications.length;

      final paginatedNotifications = filteredNotifications.sublist(
        startIndex < filteredNotifications.length ? startIndex : 0,
        endIndex,
      );

      if (kDebugMode) {
        LoggerService.debug(
          '[$_tag] ✅ 로컬에서 알림 조회 성공: ${paginatedNotifications.length}개',
        );
      }

      return Result.success('通知を取得しました', paginatedNotifications);
    } catch (error) {
      final errorMessage = '알림 조회 중 오류 발생: $error';
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ $errorMessage');
      }
      return Result.failure(errorMessage);
    }
  }

  /// 알림 읽음 상태 업데이트 (로컬 저장소 사용)
  ///
  /// [notificationId] 알림 ID
  /// [isRead] 읽음 상태
  Future<Result<bool>> markAsRead({
    required String notificationId,
    required bool isRead,
  }) async {
    try {
      // 로컬 저장소에서 알림 조회
      final notificationsData =
          await NotificationLocalStorageService.getNotifications();

      // 해당 알림 찾기
      final notificationIndex = notificationsData.indexWhere(
        (data) => data['id'] == notificationId,
      );

      if (notificationIndex == -1) {
        return Result.failure('通知が見つかりません');
      }

      // 상태 업데이트
      final notificationData = notificationsData[notificationIndex];
      notificationData['status'] = isRead ? 'read' : 'unread';
      if (isRead) {
        notificationData['readAt'] = DateTime.now().toIso8601String();
      }

      // 로컬 저장소에 업데이트
      await NotificationLocalStorageService.updateNotification(
        notificationData,
      );

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 알림 읽음 상태 업데이트 성공: $notificationId');
      }
      return Result.success('通知の既読状態を更新しました', true);
    } catch (error) {
      final errorMessage = '읽음 상태 업데이트 중 오류 발생: $error';
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ $errorMessage');
      }
      return Result.failure(errorMessage);
    }
  }

  /// 알림 삭제 (로컬 저장소 사용)
  ///
  /// [notificationId] 삭제할 알림 ID
  Future<Result<bool>> deleteNotification(String notificationId) async {
    try {
      // 로컬 저장소에서 알림 삭제
      await NotificationLocalStorageService.deleteNotification(notificationId);

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 알림 삭제 성공: $notificationId');
      }
      return Result.success('通知を削除しました', true);
    } catch (error) {
      final errorMessage = '알림 삭제 중 오류 발생: $error';
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ $errorMessage');
      }
      return Result.failure(errorMessage);
    }
  }

  /// 알림 설정 조회 (로컬 저장소 사용)
  ///
  /// [userId] 사용자 ID
  Future<Result<Map<String, dynamic>>> getNotificationSettings(
    String userId,
  ) async {
    try {
      // 로컬 저장소에서 설정 조회
      final settings = await NotificationLocalStorageService.getSettings();

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 알림 설정 조회 성공');
      }
      return Result.success('通知設定を取得しました', settings);
    } catch (error) {
      final errorMessage = '알림 설정 조회 중 오류 발생: $error';
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ $errorMessage');
      }
      return Result.failure(errorMessage);
    }
  }

  /// 알림 설정 업데이트 (로컬 저장소 사용)
  ///
  /// [userId] 사용자 ID
  /// [settings] 업데이트할 설정 맵
  Future<Result<bool>> updateNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      // 로컬 저장소에 설정 저장
      await NotificationLocalStorageService.saveSettings(settings);

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 알림 설정 업데이트 성공');
      }
      return Result.success('通知設定を更新しました', true);
    } catch (error) {
      final errorMessage = '알림 설정 업데이트 중 오류 발생: $error';
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ $errorMessage');
      }
      return Result.failure(errorMessage);
    }
  }

  /// 알림 통계 조회 (로컬 저장소 사용)
  ///
  /// [userId] 사용자 ID
  Future<Result<Map<String, dynamic>>> getNotificationStats(
    String userId,
  ) async {
    try {
      // 로컬 저장소에서 통계 조회
      final stats = await NotificationLocalStorageService.getStats();

      // 통계 요약 생성
      final totalNotifications = stats.length;
      final readNotifications = stats.where((s) => s['read'] > 0).length;
      final unreadNotifications = stats.where((s) => s['unread'] > 0).length;

      final summary = {
        'totalNotifications': totalNotifications,
        'readNotifications': readNotifications,
        'unreadNotifications': unreadNotifications,
        'stats': stats,
      };

      if (kDebugMode) {
        LoggerService.debug('[$_tag] ✅ 알림 통계 조회 성공');
      }
      return Result.success('通知統計を取得しました', summary);
    } catch (error) {
      final errorMessage = '알림 통계 조회 중 오류 발생: $error';
      if (kDebugMode) {
        LoggerService.debug('[$_tag] ❌ $errorMessage');
      }
      return Result.failure(errorMessage);
    }
  }

  /// HTTP 클라이언트 정리 (로컬 전용이므로 불필요)
  void dispose() {
    // 로컬 저장소만 사용하므로 정리 불필요
  }
}
