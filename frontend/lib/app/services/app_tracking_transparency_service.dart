import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// App Tracking Transparency (ATT) 서비스
///
/// iOS 14.5 이상에서 사용자 추적 권한을 요청하는 서비스를 제공합니다.
class AppTrackingTransparencyService {
  static final AppTrackingTransparencyService _instance =
      AppTrackingTransparencyService._internal();
  factory AppTrackingTransparencyService() => _instance;
  AppTrackingTransparencyService._internal();

  /// ATT 권한 요청
  ///
  /// iOS에서만 동작하며, Android에서는 아무 작업도 수행하지 않습니다.
  /// 권한 요청은 앱이 완전히 로드된 후에 호출해야 합니다.
  static Future<void> requestTrackingPermission() async {
    // iOS에서만 실행
    if (!Platform.isIOS) {
      if (kDebugMode) {
        debugPrint('ℹ️ ATT: Android 플랫폼이므로 권한 요청을 건너뜁니다.');
      }
      return;
    }

    try {
      // iOS 14.5 이상에서만 사용 가능
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (kDebugMode) {
        debugPrint('📱 ATT 현재 상태: $status');
      }

      // 권한이 아직 요청되지 않은 경우에만 요청
      if (status == TrackingStatus.notDetermined) {
        if (kDebugMode) {
          debugPrint('📱 ATT 권한 요청 시작...');
        }

        final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();

        if (kDebugMode) {
          debugPrint('📱 ATT 권한 요청 결과: $newStatus');
        }

        // 권한 상태에 따른 처리
        switch (newStatus) {
          case TrackingStatus.authorized:
            if (kDebugMode) {
              debugPrint('✅ ATT: 사용자가 추적 권한을 허용했습니다.');
            }
            break;
          case TrackingStatus.denied:
            if (kDebugMode) {
              debugPrint('⚠️ ATT: 사용자가 추적 권한을 거부했습니다.');
            }
            break;
          case TrackingStatus.restricted:
            if (kDebugMode) {
              debugPrint('⚠️ ATT: 추적 권한이 제한되어 있습니다.');
            }
            break;
          case TrackingStatus.notDetermined:
            if (kDebugMode) {
              debugPrint('ℹ️ ATT: 추적 권한 상태가 결정되지 않았습니다.');
            }
            break;
          case TrackingStatus.notSupported:
            if (kDebugMode) {
              debugPrint('ℹ️ ATT: 이 기기에서 추적이 지원되지 않습니다.');
            }
            break;
        }
      } else {
        if (kDebugMode) {
          debugPrint('ℹ️ ATT: 이미 권한 상태가 결정되었습니다: $status');
        }
      }
    } catch (e) {
      // ATT 권한 요청 실패 시에도 앱은 계속 실행
      if (kDebugMode) {
        debugPrint('⚠️ ATT 권한 요청 실패: $e');
      }
    }
  }

  /// 현재 추적 권한 상태 확인
  ///
  /// iOS에서만 동작하며, Android에서는 null을 반환합니다.
  static Future<TrackingStatus?> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ ATT 상태 확인 실패: $e');
      }
      return null;
    }
  }

  /// 추적 권한이 허용되었는지 확인
  static Future<bool> isTrackingAuthorized() async {
    final status = await getTrackingStatus();
    return status == TrackingStatus.authorized;
  }
}
