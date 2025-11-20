import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// App Tracking Transparency (ATT) サービス
///
/// iOS 14.5 以上でユーザー追跡権限を要求するサービスを提供します。
class AppTrackingTransparencyService {
  static final AppTrackingTransparencyService _instance =
      AppTrackingTransparencyService._internal();
  factory AppTrackingTransparencyService() => _instance;
  AppTrackingTransparencyService._internal();

  /// ATT 権限要求
  ///
  /// iOSでのみ動作し、Androidでは何も行いません。
  /// 権限要求はアプリが完全にロードされた後に呼び出す必要があります。
  static Future<void> requestTrackingPermission() async {
    // iOSでのみ実行
    if (!Platform.isIOS) {
      if (kDebugMode) {
        debugPrint('ℹ️ ATT: Android プラットフォームのため権限要求をスキップします。');
      }
      return;
    }

    try {
      // iOS 14.5 以上でのみ使用可能
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (kDebugMode) {
        debugPrint('📱 ATT 現在の状態: $status');
      }

      // 権限がまだ要求されていない場合のみ要求
      if (status == TrackingStatus.notDetermined) {
        if (kDebugMode) {
          debugPrint('📱 ATT 権限要求開始...');
        }

        final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();

        if (kDebugMode) {
          debugPrint('📱 ATT 権限要求結果: $newStatus');
        }

        // 権限状態に応じた処理
        switch (newStatus) {
          case TrackingStatus.authorized:
            if (kDebugMode) {
              debugPrint('✅ ATT: ユーザーが追跡権限を許可しました。');
            }
            break;
          case TrackingStatus.denied:
            if (kDebugMode) {
              debugPrint('⚠️ ATT: ユーザーが追跡権限を拒否しました。');
            }
            break;
          case TrackingStatus.restricted:
            if (kDebugMode) {
              debugPrint('⚠️ ATT: 追跡権限が制限されています。');
            }
            break;
          case TrackingStatus.notDetermined:
            if (kDebugMode) {
              debugPrint('ℹ️ ATT: 追跡権限の状態が決定されていません。');
            }
            break;
          case TrackingStatus.notSupported:
            if (kDebugMode) {
              debugPrint('ℹ️ ATT: このデバイスでは追跡がサポートされていません。');
            }
            break;
        }
      } else {
        if (kDebugMode) {
          debugPrint('ℹ️ ATT: すでに権限状態が決定されています: $status');
        }
      }
    } catch (e) {
      // ATT 権限要求失敗時にもアプリは続行
      if (kDebugMode) {
        debugPrint('⚠️ ATT 権限要求失敗: $e');
      }
    }
  }

  /// 現在の追跡権限状態を確認
  ///
  /// iOSでのみ動作し、Androidではnullを返します。
  static Future<TrackingStatus?> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return null;
    }

    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ ATT 状態確認失敗: $e');
      }
      return null;
    }
  }

  /// 追跡権限が許可されているかを確認
  static Future<bool> isTrackingAuthorized() async {
    final status = await getTrackingStatus();
    return status == TrackingStatus.authorized;
  }
}
