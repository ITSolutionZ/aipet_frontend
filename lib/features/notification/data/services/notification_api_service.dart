import 'dart:convert';

import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 📡 알림 API 서비스
///
/// 백엔드 API와 통신하여 알림 데이터를 관리합니다.
/// 프론트엔드 중심의 구조로 로컬 데이터베이스 대신 API 통신을 사용합니다.
class NotificationApiService {
  static const String _tag = 'NotificationApiService';

  // API Endpoints (실제 백엔드 URL로 교체 필요)
  static const String _baseUrl = 'https://api.aipet.com/v1';
  static const String _notificationsEndpoint = '/notifications';
  static const String _settingsEndpoint = '/notification-settings';

  final http.Client _httpClient;

  NotificationApiService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// 사용자의 알림 목록 조회
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
      final queryParams = <String, String>{
        'userId': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (isRead != null) {
        queryParams['isRead'] = isRead.toString();
      }

      if (type != null) {
        queryParams['type'] = type;
      }

      final uri = Uri.parse(
        '$_baseUrl$_notificationsEndpoint',
      ).replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = (data['notifications'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 조회 성공: ${notifications.length}개');
        }

        return ResultFactory.success(
          notifications,
          'Notifications fetched successfully',
        );
      } else {
        final errorMessage = 'API 요청 실패: ${response.statusCode}';
        if (kDebugMode) {
          debugPrint('[$_tag] ❌ $errorMessage');
        }
        return ResultFactory.failure(errorMessage);
      }
    } catch (error) {
      final errorMessage = '알림 조회 중 오류 발생: $error';
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ $errorMessage');
      }
      return ResultFactory.failure(errorMessage);
    }
  }

  /// 알림 읽음 상태 업데이트
  ///
  /// [notificationId] 알림 ID
  /// [isRead] 읽음 상태
  Future<Result<bool>> markAsRead({
    required String notificationId,
    required bool isRead,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl$_notificationsEndpoint/$notificationId/read',
      );

      final response = await _httpClient.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'isRead': isRead}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 읽음 상태 업데이트 성공: $notificationId');
        }
        return ResultFactory.success(true, 'Notification read status updated');
      } else {
        final errorMessage = 'API 요청 실패: ${response.statusCode}';
        if (kDebugMode) {
          debugPrint('[$_tag] ❌ $errorMessage');
        }
        return ResultFactory.failure(errorMessage);
      }
    } catch (error) {
      final errorMessage = '읽음 상태 업데이트 중 오류 발생: $error';
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ $errorMessage');
      }
      return ResultFactory.failure(errorMessage);
    }
  }

  /// 알림 삭제
  ///
  /// [notificationId] 삭제할 알림 ID
  Future<Result<bool>> deleteNotification(String notificationId) async {
    try {
      final uri = Uri.parse('$_baseUrl$_notificationsEndpoint/$notificationId');

      final response = await _httpClient.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 삭제 성공: $notificationId');
        }
        return ResultFactory.success(true, 'Notification deleted successfully');
      } else {
        final errorMessage = 'API 요청 실패: ${response.statusCode}';
        if (kDebugMode) {
          debugPrint('[$_tag] ❌ $errorMessage');
        }
        return ResultFactory.failure(errorMessage);
      }
    } catch (error) {
      final errorMessage = '알림 삭제 중 오류 발생: $error';
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ $errorMessage');
      }
      return ResultFactory.failure(errorMessage);
    }
  }

  /// 알림 설정 조회
  ///
  /// [userId] 사용자 ID
  Future<Result<Map<String, dynamic>>> getNotificationSettings(
    String userId,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl$_settingsEndpoint/$userId');

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final settings = json.decode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 설정 조회 성공');
        }
        return ResultFactory.success(
          settings,
          'Notification settings fetched successfully',
        );
      } else {
        final errorMessage = 'API 요청 실패: ${response.statusCode}';
        if (kDebugMode) {
          debugPrint('[$_tag] ❌ $errorMessage');
        }
        return ResultFactory.failure(errorMessage);
      }
    } catch (error) {
      final errorMessage = '알림 설정 조회 중 오류 발생: $error';
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ $errorMessage');
      }
      return ResultFactory.failure(errorMessage);
    }
  }

  /// 알림 설정 업데이트
  ///
  /// [userId] 사용자 ID
  /// [settings] 업데이트할 설정 맵
  Future<Result<bool>> updateNotificationSettings({
    required String userId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$_settingsEndpoint/$userId');

      final response = await _httpClient.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(settings),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 설정 업데이트 성공');
        }
        return ResultFactory.success(
          true,
          'Notification settings updated successfully',
        );
      } else {
        final errorMessage = 'API 요청 실패: ${response.statusCode}';
        if (kDebugMode) {
          debugPrint('[$_tag] ❌ $errorMessage');
        }
        return ResultFactory.failure(errorMessage);
      }
    } catch (error) {
      final errorMessage = '알림 설정 업데이트 중 오류 발생: $error';
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ $errorMessage');
      }
      return ResultFactory.failure(errorMessage);
    }
  }

  /// 알림 통계 조회
  ///
  /// [userId] 사용자 ID
  Future<Result<Map<String, dynamic>>> getNotificationStats(
    String userId,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl$_notificationsEndpoint/$userId/stats');

      final response = await _httpClient.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final stats = json.decode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          debugPrint('[$_tag] ✅ 알림 통계 조회 성공');
        }
        return ResultFactory.success(
          stats,
          'Notification stats fetched successfully',
        );
      } else {
        final errorMessage = 'API 요청 실패: ${response.statusCode}';
        if (kDebugMode) {
          debugPrint('[$_tag] ❌ $errorMessage');
        }
        return ResultFactory.failure(errorMessage);
      }
    } catch (error) {
      final errorMessage = '알림 통계 조회 중 오류 발생: $error';
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ $errorMessage');
      }
      return ResultFactory.failure(errorMessage);
    }
  }

  /// HTTP 클라이언트 정리
  void dispose() {
    _httpClient.close();
  }
}
