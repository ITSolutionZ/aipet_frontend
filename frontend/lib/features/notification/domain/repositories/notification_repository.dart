import 'package:aipet_frontend/shared/shared.dart';

import '../entities/entities.dart';

/// 📱 알림 Repository 인터페이스
///
/// 프론트엔드 중심의 API 기반 알림 관리를 위한 인터페이스입니다.
/// Result 패턴을 사용하여 성공/실패를 명확히 구분합니다.
abstract class NotificationRepository {
  /// 사용자의 모든 알림 조회
  ///
  /// [userId] 사용자 ID
  /// [page] 페이지 번호 (0부터 시작)
  /// [limit] 페이지당 항목 수
  /// [isRead] 읽음 상태 필터 (null이면 전체)
  /// [type] 알림 타입 필터 (null이면 전체)
  Future<Result<List<NotificationModel>>> getAllNotifications({
    required String userId,
    int page = 0,
    int limit = 20,
    bool? isRead,
    String? type,
  });

  /// ID로 특정 알림 조회
  ///
  /// [userId] 사용자 ID
  /// [notificationId] 조회할 알림 ID
  Future<Result<NotificationModel?>> getNotificationById({
    required String userId,
    required String notificationId,
  });

  /// 알림을 읽음/읽지않음 상태로 표시
  ///
  /// [userId] 사용자 ID
  /// [notificationId] 대상 알림 ID
  /// [isRead] 읽음 상태
  Future<Result<bool>> markAsRead({
    required String userId,
    required String notificationId,
    required bool isRead,
  });

  /// 알림 삭제
  ///
  /// [userId] 사용자 ID
  /// [notificationId] 삭제할 알림 ID
  Future<Result<bool>> deleteNotification({
    required String userId,
    required String notificationId,
  });

  /// 알림 설정 조회
  ///
  /// [userId] 사용자 ID
  Future<Result<Map<String, dynamic>>> getNotificationSettings(String userId);

  /// 알림 설정 업데이트
  ///
  /// [userId] 사용자 ID
  /// [settings] 업데이트할 설정 맵
  Future<Result<bool>> updateNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  });

  /// 알림 통계 조회
  ///
  /// [userId] 사용자 ID
  Future<Result<Map<String, dynamic>>> getNotificationStats(String userId);
}
