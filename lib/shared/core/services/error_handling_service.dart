import 'dart:async';

import 'package:flutter/material.dart';

import 'logger_service.dart';
import 'ui_notification_service.dart';

/// 통합 에러 처리 서비스
///
/// 앱 전체의 에러를 일관되게 처리하고 사용자에게 적절한 피드백을 제공합니다.
/// 보안을 고려하여 민감한 정보를 노출하지 않는 안전한 에러 메시지를 생성합니다.
class ErrorHandlingService {
  /// 비동기 작업 에러 처리
  static Future<T?> handleAsync<T>(
    Future<T> operation, {
    String? context,
    bool showUserMessage = true,
    String? customUserMessage,
  }) async {
    try {
      LoggerService.debug('Starting async operation: ${context ?? 'unknown'}');
      final result = await operation;
      LoggerService.debug(
        'Async operation completed successfully: ${context ?? 'unknown'}',
      );
      return result;
    } catch (error, stackTrace) {
      return _handleError(
        error,
        stackTrace,
        context: context,
        showUserMessage: showUserMessage,
        customUserMessage: customUserMessage,
      );
    }
  }

  /// 동기 작업 에러 처리
  static T? handleSync<T>(
    T Function() operation, {
    String? context,
    bool showUserMessage = true,
    String? customUserMessage,
  }) {
    try {
      LoggerService.debug('Starting sync operation: ${context ?? 'unknown'}');
      final result = operation();
      LoggerService.debug(
        'Sync operation completed successfully: ${context ?? 'unknown'}',
      );
      return result;
    } catch (error, stackTrace) {
      return _handleError(
        error,
        stackTrace,
        context: context,
        showUserMessage: showUserMessage,
        customUserMessage: customUserMessage,
      );
    }
  }

  /// Future 빌더용 에러 처리
  static Widget handleFutureBuilderError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    Widget? customErrorWidget,
  }) {
    _handleError(
      error,
      stackTrace,
      context: context ?? 'FutureBuilder',
      showUserMessage: false, // UI에서는 메시지 표시하지 않음
    );

    return customErrorWidget ?? _buildDefaultErrorWidget();
  }

  /// StreamBuilder용 에러 처리
  static Widget handleStreamBuilderError(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    Widget? customErrorWidget,
  }) {
    _handleError(
      error,
      stackTrace,
      context: context ?? 'StreamBuilder',
      showUserMessage: false, // UI에서는 메시지 표시하지 않음
    );

    return customErrorWidget ?? _buildDefaultErrorWidget();
  }

  /// 네트워크 에러 처리
  static void handleNetworkError(
    Object error, {
    String? context,
    bool showUserMessage = true,
  }) {
    LoggerService.error(
      'Network error occurred',
      error: error,
      data: {'context': context ?? 'unknown'},
    );

    if (showUserMessage) {
      final userMessage = _getNetworkErrorMessage(error);
      UINotificationService.showError(userMessage);
    }
  }

  /// API 에러 처리
  static void handleApiError(
    int statusCode,
    String? responseBody, {
    String? context,
    bool showUserMessage = true,
  }) {
    LoggerService.error(
      'API error occurred',
      data: {
        'statusCode': statusCode,
        'context': context ?? 'unknown',
        'hasResponseBody': responseBody != null,
      },
    );

    if (showUserMessage) {
      final userMessage = _getApiErrorMessage(statusCode);
      UINotificationService.showError(userMessage);
    }
  }

  /// 입력 검증 에러 처리
  static void handleValidationError(
    String field,
    String message, {
    bool showUserMessage = true,
  }) {
    LoggerService.warning(
      'Validation error',
      data: {'field': field, 'message': message},
    );

    if (showUserMessage) {
      UINotificationService.showWarning(message);
    }
  }

  /// 인증 에러 처리
  static void handleAuthError(
    Object error, {
    String? context,
    bool showUserMessage = true,
    VoidCallback? onAuthRequired,
  }) {
    LoggerService.error(
      'Authentication error occurred',
      error: error,
      data: {'context': context ?? 'unknown'},
    );

    if (showUserMessage) {
      UINotificationService.showError('인증이 필요합니다. 다시 로그인해주세요.');
    }

    // 인증 필요 콜백 실행
    onAuthRequired?.call();
  }

  /// 권한 에러 처리
  static void handlePermissionError(
    String permission, {
    String? context,
    bool showUserMessage = true,
  }) {
    LoggerService.warning(
      'Permission denied',
      data: {'permission': permission, 'context': context ?? 'unknown'},
    );

    if (showUserMessage) {
      UINotificationService.showWarning('$permission 권한이 필요합니다.');
    }
  }

  /// 내부 에러 처리 로직
  static T? _handleError<T>(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    bool showUserMessage = true,
    String? customUserMessage,
  }) {
    // 에러 로깅
    LoggerService.error(
      'Error occurred in ${context ?? 'unknown context'}',
      error: error,
      stackTrace: stackTrace,
    );

    // 사용자 메시지 표시
    if (showUserMessage) {
      final userMessage = customUserMessage ?? _getUserFriendlyMessage(error);
      UINotificationService.showError(userMessage);
    }

    return null;
  }

  /// 사용자 친화적 에러 메시지 생성
  static String _getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    // 네트워크 관련 에러
    if (errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return '네트워크 연결을 확인해주세요.';
    }

    // 타임아웃 에러
    if (errorString.contains('timeout')) {
      return '응답 시간이 초과되었습니다. 다시 시도해주세요.';
    }

    // 권한 에러
    if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return '권한이 없습니다. 로그인을 확인해주세요.';
    }

    // 파일 관련 에러
    if (errorString.contains('file') || errorString.contains('path')) {
      return '파일을 처리하는 중 오류가 발생했습니다.';
    }

    // 데이터 관련 에러
    if (errorString.contains('parse') || errorString.contains('format')) {
      return '데이터 형식에 오류가 있습니다.';
    }

    // 기본 메시지
    return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
  }

  /// 네트워크 에러 메시지 생성
  static String _getNetworkErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('no internet') ||
        errorString.contains('offline')) {
      return '인터넷 연결을 확인해주세요.';
    } else if (errorString.contains('timeout')) {
      return '네트워크 응답 시간이 초과되었습니다.';
    } else if (errorString.contains('dns') || errorString.contains('host')) {
      return '서버에 연결할 수 없습니다.';
    } else {
      return '네트워크 오류가 발생했습니다.';
    }
  }

  /// API 에러 메시지 생성
  static String _getApiErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다.';
      case 401:
        return '인증이 필요합니다.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청한 정보를 찾을 수 없습니다.';
      case 408:
        return '요청 시간이 초과되었습니다.';
      case 429:
        return '너무 많은 요청이 발생했습니다. 잠시 후 시도해주세요.';
      case 500:
        return '서버 내부 오류가 발생했습니다.';
      case 502:
        return '서버 게이트웨이 오류가 발생했습니다.';
      case 503:
        return '서비스를 일시적으로 사용할 수 없습니다.';
      case 504:
        return '서버 응답 시간이 초과되었습니다.';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return '클라이언트 오류가 발생했습니다. ($statusCode)';
        } else if (statusCode >= 500) {
          return '서버 오류가 발생했습니다. ($statusCode)';
        } else {
          return '알 수 없는 오류가 발생했습니다. ($statusCode)';
        }
    }
  }

  /// 기본 에러 위젯 생성
  static Widget _buildDefaultErrorWidget() {
    return Container(
      padding: const const EdgeInsets.all(16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            '데이터를 불러올 수 없습니다',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text('다시 시도해주세요', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

/// Future 확장 메서드
extension FutureErrorHandling<T> on Future<T> {
  /// 자동 에러 처리가 포함된 Future
  Future<T?> withErrorHandling({
    String? context,
    bool showUserMessage = true,
    String? customUserMessage,
  }) {
    return ErrorHandlingService.handleAsync(
      this,
      context: context,
      showUserMessage: showUserMessage,
      customUserMessage: customUserMessage,
    );
  }
}
