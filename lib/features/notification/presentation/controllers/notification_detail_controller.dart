import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/domain/usecases/notification_usecases.dart';
import 'package:aipet_frontend/shared/core/services/date_format_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'notification_ui_controller.dart';

/// 알림 상세 화면 컨트롤러 (클린 아키텍처 버전)
class NotificationDetailController {
  final NotificationUIController _uiController;
  final GetNotificationByIdUseCase _getNotificationByIdUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;

  NotificationDetailController(
    this._uiController,
    this._getNotificationByIdUseCase,
    this._markAsReadUseCase,
    this._deleteNotificationUseCase,
  );

  /// 알림 데이터 로드
  Future<NotificationModel?> loadNotification(String userId, String notificationId) async {
    try {
      final result = await _getNotificationByIdUseCase.call(userId, notificationId);
      return result.dataOrNull;
    } catch (error) {
      rethrow;
    }
  }

  /// 알림을 읽음 상태로 변경
  Future<void> markAsRead(
    BuildContext context,
    String userId,
    NotificationModel notification,
  ) async {
    try {
      await _markAsReadUseCase.call(userId, notification.id);
      if (context.mounted) {
        _uiController.showSuccessSnackBar(context, '通知を読み取りました');
      }
    } catch (error) {
      if (context.mounted) {
        _uiController.showErrorSnackBar(context, '読み取り処理中にエラーが発生しました: $error');
      }
    }
  }

  /// 알림 삭제 확인 및 실행
  Future<void> deleteNotification(
    BuildContext context,
    String userId,
    String notificationId,
  ) async {
    try {
      final confirmed = await _uiController.showDeleteConfirmationDialog(context);
      if (confirmed && context.mounted) {
        await _deleteNotificationUseCase.call(userId, notificationId);
        if (context.mounted) {
          _uiController.showSuccessSnackBar(context, '通知を削除しました');
          context.pop();
        }
      }
    } catch (error) {
      if (context.mounted) {
        _uiController.showErrorSnackBar(context, '削除処理中にエラーが発生しました: $error');
      }
    }
  }

  /// 액션 URL에 따른 네비게이션 처리
  void handleAction(BuildContext context, NotificationModel notification) {
    final actionUrl = notification.actionUrl;
    if (actionUrl == null) return;

    try {
      // URL 파싱하여 적절한 화면으로 이동
      if (actionUrl.startsWith('/event-detail/')) {
        context.push(actionUrl);
      } else if (actionUrl.startsWith('/feeding-schedule/')) {
        final petId = actionUrl.split('/')[2];
        final petName = notification.petName ?? '';
        context.push('${RouteConstants.feedingScheduleRoute}/$petId?petName=$petName');
      } else if (actionUrl.startsWith('/feeding-analysis/')) {
        final petId = actionUrl.split('/')[2];
        final petName = notification.petName ?? '';
        context.push('${RouteConstants.feedingAnalysisRoute}/$petId?petName=$petName');
      } else if (actionUrl == '/walk') {
        context.push(RouteConstants.walkRoute);
      } else if (actionUrl == '/vaccines') {
        context.push(RouteConstants.vaccinesRoute);
      } else if (actionUrl == '/reservation') {
        context.push(RouteConstants.calendarRoute);
      } else {
        // 기본적으로 URL을 그대로 사용
        context.push(actionUrl);
      }
    } catch (error) {
      _uiController.showErrorSnackBar(context, '画面移動中にエラーが発生しました: $error');
    }
  }

  /// 날짜 포맷팅 (공통 서비스 사용)
  String formatDateTime(DateTime dateTime) {
    return DateFormatService.formatRelativeTime(dateTime);
  }

  /// 통화 포맷팅
  String formatCurrency(dynamic amount) {
    if (amount is int) {
      return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]},',
      );
    }
    return amount.toString();
  }

  /// 컨트롤러 정리
  void dispose() {
    _uiController.dispose();
  }
}
