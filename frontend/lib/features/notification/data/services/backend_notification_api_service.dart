import 'package:dio/dio.dart';

import '../../../../shared/core/api/backend_api_client.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_priority.dart';
import '../../domain/entities/notification_status.dart';
import '../../domain/entities/notification_type.dart';

/// 백엔드 Notification API 서비스
///
/// BackendApiClient를 사용하여 알림 CRUD 및 FCM을 수행합니다.
/// Firebase ID Token이 자동으로 Authorization 헤더에 추가됩니다.
class BackendNotificationApiService {
  static final BackendApiClient _apiClient = BackendApiClient.instance;

  /// 알림 목록 조회
  ///
  /// GET /notifications
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<List<NotificationModel>>> getNotifications({
    bool? isRead,
    String? notificationType,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) {
        queryParams['isRead'] = isRead;
      }
      if (notificationType != null) {
        queryParams['notificationType'] = notificationType;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiClient.get(
        '/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<NotificationModel> notifications = [];

        if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              notifications.add(_mapToNotificationModel(item));
            }
          }
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          final list = data['data'] as List;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              notifications.add(_mapToNotificationModel(item));
            }
          }
        }

        return Result.success('通知リストを取得しました', notifications);
      } else {
        return Result.failure('通知リストの取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('알림 목록 조회', e);
    } catch (e) {
      return Result.failure('通知リストの取得に失敗しました');
    }
  }

  /// 알림 생성 (스케줄링)
  ///
  /// POST /notifications
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<NotificationModel>> createNotification({
    required String title,
    required String body,
    String? petId,
    NotificationType? notificationType,
    DateTime? scheduledAt,
    bool sendImmediately = false,
    String? fcmToken,
  }) async {
    try {
      final notificationData = {
        'title': title,
        'body': body,
        if (petId != null) 'petId': petId,
        if (notificationType != null) 'notificationType': notificationType.name,
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
        'sendImmediately': sendImmediately,
        if (fcmToken != null) 'fcmToken': fcmToken,
      };

      final response = await _apiClient.post(
        '/notifications',
        data: notificationData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final createdNotification = _mapToNotificationModel(
            data['data'] ?? data,
          );
          return Result.success('通知を作成しました', createdNotification);
        }

        return Result.failure('通知の作成に失敗しました');
      } else {
        return Result.failure('通知の作成に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('알림 생성', e);
    } catch (e) {
      return Result.failure('通知の作成に失敗しました');
    }
  }

  /// 알림 읽음 처리
  ///
  /// PUT /notifications/:notificationId/read
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<NotificationModel>> markAsRead({
    required String notificationId,
  }) async {
    try {
      final response = await _apiClient.put(
        '/notifications/$notificationId/read',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic>) {
          final updatedNotification = _mapToNotificationModel(
            data['data'] ?? data,
          );
          return Result.success('通知を既読にしました', updatedNotification);
        }

        return Result.failure('通知の既読処理に失敗しました');
      } else {
        return Result.failure('通知の既読処理に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('알림 읽음 처리', e);
    } catch (e) {
      return Result.failure('通知の既読処理に失敗しました');
    }
  }

  /// 모든 알림 읽음 처리
  ///
  /// PUT /notifications/mark-all-read
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> markAllAsRead() async {
    try {
      final response = await _apiClient.put('/notifications/mark-all-read');

      if (response.statusCode == 200) {
        return Result.success('すべての通知を既読にしました', null);
      } else {
        return Result.failure('すべての通知の既読処理に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('모든 알림 읽음 처리', e);
    } catch (e) {
      return Result.failure('すべての通知の既読処理に失敗しました');
    }
  }

  /// 알림 삭제
  ///
  /// DELETE /notifications/:notificationId
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/notifications/$notificationId',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Result.success('通知を削除しました', null);
      } else {
        return Result.failure('通知の削除に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('알림 삭제', e);
    } catch (e) {
      return Result.failure('通知の削除に失敗しました');
    }
  }

  /// 읽지 않은 알림 개수 조회
  ///
  /// GET /notifications/unread-count
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<int>> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        final data = response.data;
        final count = data['count'] ?? data['unreadCount'] ?? 0;

        return Result.success('未読通知数を取得しました', count as int);
      } else {
        return Result.failure('未読通知数の取得に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('읽지 않은 알림 개수 조회', e);
    } catch (e) {
      return Result.failure('未読通知数の取得に失敗しました');
    }
  }

  /// FCM 토큰 저장/업데이트
  ///
  /// POST /notifications/fcm-token
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> saveFCMToken({
    required String fcmToken,
    String deviceType = 'android', // android or ios
  }) async {
    try {
      final response = await _apiClient.post(
        '/notifications/fcm-token',
        data: {'fcmToken': fcmToken, 'deviceType': deviceType},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.success('FCMトークンを保存しました', null);
      } else {
        return Result.failure('FCMトークンの保存に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('FCM 토큰 저장', e);
    } catch (e) {
      return Result.failure('FCMトークンの保存に失敗しました');
    }
  }

  /// FCM 푸시 알림 전송 (테스트용)
  ///
  /// POST /notifications/push
  /// Authorization 헤더는 자동으로 추가됨
  static Future<Result<void>> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/notifications/push',
        data: {
          'fcmToken': fcmToken,
          'title': title,
          'body': body,
          if (data != null) 'data': data,
        },
      );

      if (response.statusCode == 200) {
        return Result.success('プッシュ通知を送信しました', null);
      } else {
        return Result.failure('プッシュ通知の送信に失敗しました');
      }
    } on DioException catch (e) {
      return _handleDioError('푸시 알림 전송', e);
    } catch (e) {
      return Result.failure('プッシュ通知の送信に失敗しました');
    }
  }

  /// 백엔드 응답 데이터를 NotificationModel로 변환
  static NotificationModel _mapToNotificationModel(Map<String, dynamic> json) {
    // notification_type → notificationType
    final notificationTypeStr =
        json['notification_type'] ?? json['notificationType'] ?? 'general';
    final notificationType = NotificationType.values.firstWhere(
      (e) => e.name == notificationTypeStr,
      orElse: () => NotificationType.general,
    );

    // is_read → status
    final isRead = json['is_read'] ?? json['isRead'] ?? false;
    final status = isRead ? NotificationStatus.read : NotificationStatus.unread;

    // priority (백엔드에 없으면 기본값)
    final priorityStr = json['priority'] ?? 'normal';
    final priority = NotificationPriority.values.firstWhere(
      (e) => e.name == priorityStr,
      orElse: () => NotificationPriority.normal,
    );

    // 날짜 처리
    final createdAt = json['created_at'] ?? json['createdAt'];
    final readAt = json['read_at'] ?? json['readAt'];

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: notificationType,
      priority: priority,
      status: status,
      createdAt: createdAt != null
          ? DateTime.tryParse(createdAt) ?? DateTime.now()
          : DateTime.now(),
      readAt: readAt != null ? DateTime.tryParse(readAt) : null,
      expiresAt: null, // 백엔드에 없으면 null
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['image_url'] ?? json['imageUrl'],
      icon: json['icon'],
    );
  }

  /// DioException 에러 처리
  static Result<T> _handleDioError<T>(String operation, DioException e) {
    String errorMessage = 'エラーが発生しました';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'タイムアウトが発生しました';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'ネットワーク接続を確認してください';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = '認証に失敗しました';
        } else if (statusCode == 403) {
          errorMessage = 'アクセスが拒否されました';
        } else if (statusCode == 404) {
          errorMessage = 'リソースが見つかりません';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'サーバーエラーが発生しました';
        }
        break;
      default:
        errorMessage = '予期しないエラーが発生しました';
    }

    return Result.failure(errorMessage);
  }
}
