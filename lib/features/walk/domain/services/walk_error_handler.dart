import 'package:geolocator/geolocator.dart';

/// 산책 관련 에러 핸들링 서비스
class WalkErrorHandler {
  WalkErrorHandler._();

  /// 위치 관련 에러 메시지 생성
  static String getLocationErrorMessage(dynamic error) {
    if (error is LocationServiceDisabledException) {
      return '位置サービスが無効になっています。設定で有効にしてください。';
    } else if (error is PermissionDeniedException) {
      return '位置情報の権限が拒否されました。設定で権限を許可してください。';
    } else if (error.toString().contains('Location permission denied')) {
      return '位置情報の権限が必要です。設定で権限を許可してください。';
    } else if (error.toString().contains('Location permission permanently denied')) {
      return '位置情報の権限が永続的に拒否されています。設定アプリで権限を許可してください。';
    } else if (error.toString().contains('Location service disabled')) {
      return '位置サービスが無効になっています。設定で有効にしてください。';
    } else {
      return '位置情報の取得に失敗しました: ${error.toString()}';
    }
  }

  /// 산책 관련 일반 에러 메시지 생성
  static String getWalkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'ネットワーク接続を確認してください。';
    } else if (errorString.contains('timeout')) {
      return '処理がタイムアウトしました。もう一度お試しください。';
    } else if (errorString.contains('storage') || errorString.contains('disk')) {
      return 'ストレージ容量が不足している可能性があります。';
    } else if (errorString.contains('battery')) {
      return 'バッテリー残量が少ないため、位置追跡が制限される可能性があります。';
    } else {
      return '予期しないエラーが発生しました: ${error.toString()}';
    }
  }

  /// Google Maps 관련 에러 메시지 생성
  static String getMapErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('api_key') || errorString.contains('authentication')) {
      return 'Google Maps APIの認証に失敗しました。';
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return 'Google Maps APIの使用量上限に達しました。';
    } else if (errorString.contains('network')) {
      return 'マップの読み込みに失敗しました。ネットワーク接続を確認してください。';
    } else {
      return 'マップの表示でエラーが発生しました: ${error.toString()}';
    }
  }

  /// 산책 데이터 관련 에러 메시지 생성
  static String getWalkDataErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('not found')) {
      return '散歩記録が見つかりません。';
    } else if (errorString.contains('invalid data') || errorString.contains('format')) {
      return '散歩データの形式が正しくありません。';
    } else if (errorString.contains('save') || errorString.contains('write')) {
      return '散歩記録の保存に失敗しました。';
    } else if (errorString.contains('load') || errorString.contains('read')) {
      return '散歩記録の読み込みに失敗しました。';
    } else {
      return '散歩データの処理でエラーが発生しました: ${error.toString()}';
    }
  }

  /// 사용자 액션 제안 메시지 생성
  static String getUserActionSuggestion(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return '設定アプリで位置情報の権限を確認してください。';
    } else if (errorString.contains('location service')) {
      return '設定で位置サービスを有効にしてください。';
    } else if (errorString.contains('network')) {
      return 'Wi-Fiまたはモバイル通信の接続を確認してください。';
    } else if (errorString.contains('battery')) {
      return 'デバイスを充電することをお勧めします。';
    } else if (errorString.contains('storage')) {
      return 'ストレージ容量を確保してください。';
    } else {
      return 'アプリを再起動するか、しばらく時間をおいてから再試行してください。';
    }
  }

  /// 에러 심각도 판별
  static WalkErrorSeverity getErrorSeverity(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permanently denied') ||
        errorString.contains('location service disabled')) {
      return WalkErrorSeverity.critical;
    } else if (errorString.contains('permission denied') ||
               errorString.contains('network') ||
               errorString.contains('api_key')) {
      return WalkErrorSeverity.high;
    } else if (errorString.contains('timeout') ||
               errorString.contains('storage') ||
               errorString.contains('battery')) {
      return WalkErrorSeverity.medium;
    } else {
      return WalkErrorSeverity.low;
    }
  }
}

/// 에러 심각도 레벨
enum WalkErrorSeverity {
  low,     // 낮음: 일반적인 에러, 재시도 가능
  medium,  // 중간: 사용자 개입 필요할 수 있음
  high,    // 높음: 기능 제한됨, 사용자 액션 필요
  critical // 치명적: 핵심 기능 불가, 즉시 해결 필요
}

/// 에러 복구 전략
class WalkErrorRecovery {
  static Future<bool> attemptLocationRecovery() async {
    try {
      // 위치 서비스 상태 재확인
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // 권한 상태 재확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission != LocationPermission.denied &&
             permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> attemptDataRecovery() async {
    try {
      // 로컬 데이터 복구 시도
      // 임시 저장된 데이터 확인
      // 백업 데이터 복원
      return true;
    } catch (e) {
      return false;
    }
  }
}