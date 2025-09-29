import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:flutter/material.dart';

import '../core/services/unified_error_handler.dart';

/// 🎯 Facility 전용 에러 핸들러
///
/// Facility 관련 모든 에러를 통합 처리하여
/// 일관된 사용자 경험을 제공합니다.
class FacilityErrorHandler {
  /// 시설 로드 에러 처리
  static void handleLoadError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_load');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_load'},
    );
  }

  /// 시설 검색 에러 처리
  static void handleSearchError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_search');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_search'},
    );
  }

  /// 시설 필터링 에러 처리
  static void handleFilterError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_filter');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_filter'},
    );
  }

  /// 시설 즐겨찾기 에러 처리
  static void handleFavoriteError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_favorite');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_favorite'},
    );
  }

  /// 시설 예약 에러 처리
  static void handleBookingError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_booking');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_booking'},
    );
  }

  /// 시설 연락처 에러 처리
  static void handleContactError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_contact');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_contact'},
    );
  }

  /// 시설 지도 에러 처리
  static void handleMapError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_map');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_map'},
    );
  }

  /// 시설 위치 에러 처리
  static void handleLocationError(dynamic error, BuildContext context) {
    final errorMessage = _getErrorMessage(error, 'facility_location');
    _showErrorSnackBar(context, errorMessage);
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'operation': 'facility_location'},
    );
  }

  /// 성공 메시지 표시
  static void showSuccessMessage(String message, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 정보 메시지 표시
  static void showInfoMessage(String message, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 경고 메시지 표시
  static void showWarningMessage(String message, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 에러 메시지 생성
  static String _getErrorMessage(dynamic error, String operation) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'ネットワークエラーが発生しました。接続を確認してください。';
    }

    if (errorString.contains('timeout')) {
      return 'タイムアウトが発生しました。しばらくしてから再度お試しください。';
    }

    if (errorString.contains('permission')) {
      return '権限が不足しています。設定を確認してください。';
    }

    if (errorString.contains('not found')) {
      return '施設が見つかりませんでした。';
    }

    if (errorString.contains('unauthorized')) {
      return '認証が必要です。再度ログインしてください。';
    }

    if (errorString.contains('forbidden')) {
      return 'アクセスが拒否されました。';
    }

    if (errorString.contains('server')) {
      return 'サーバーエラーが発生しました。後でもう一度お試しください。';
    }

    // 기본 에러 메시지
    switch (operation) {
      case 'facility_load':
        return '施設の読み込みに失敗しました。';
      case 'facility_search':
        return '施設の検索に失敗しました。';
      case 'facility_filter':
        return '施設のフィルタリングに失敗しました。';
      case 'facility_favorite':
        return 'お気に入りの設定に失敗しました。';
      case 'facility_booking':
        return '予約の処理に失敗しました。';
      case 'facility_contact':
        return '連絡先の処理に失敗しました。';
      case 'facility_map':
        return '地図の表示に失敗しました。';
      case 'facility_location':
        return '位置情報の取得に失敗しました。';
      default:
        return 'エラーが発生しました。';
    }
  }

  /// 에러 스낵바 표시
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '閉じる',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// 시설 유효성 검사
  static bool validateFacility(Facility facility) {
    if (facility.id.isEmpty) return false;
    if (facility.name.isEmpty) return false;
    if (facility.address.isEmpty) return false;
    if (facility.latitude == 0 && facility.longitude == 0) return false;
    return true;
  }

  /// 시설 리스트 유효성 검사
  static List<Facility> validateFacilityList(List<Facility> facilities) {
    return facilities.where(validateFacility).toList();
  }
}
