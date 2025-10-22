import 'package:aipet_frontend/features/walk/presentation/widgets/map_widget.dart';
import 'package:aipet_frontend/shared/core/services/snackbar_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 위치 관련 헬퍼
class WalkListLocationHelper {
  /// 현재 위치로 지도 이동
  static Future<void> moveToCurrentLocation({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      // 전역 provider에서 지도 컨트롤러 가져오기
      final mapController = ref.read(globalMapControllerProvider);

      if (mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 아직 초기화되지 않았습니다');
        if (context.mounted) {
          _showLocationErrorSnackBar(context, message: '地図が読み込まれていません');
        }
        return;
      }

      // 현재 위치 가져오기
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('位置情報の取得がタイムアウトしました');
            },
          );

      debugPrint('📍 현재 위치: ${position.latitude}, ${position.longitude}');

      // 지도 카메라를 현재 위치로 이동
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );

      if (context.mounted) {
        _showLocationSuccessSnackBar(context);
      }
    } catch (e) {
      debugPrint('❌ 현재 위치 이동 에러: $e');
      if (context.mounted) {
        _showLocationErrorSnackBar(context, message: '現在地の取得に失敗しました');
      }
    }
  }

  /// 위치 성공 스낵바
  static void _showLocationSuccessSnackBar(BuildContext context) {
    SnackBarService.showSuccess(
      context,
      '現在地に移動しました',
      duration: const Duration(seconds: 1),
    );
  }

  /// 위치 에러 스낵바
  static void _showLocationErrorSnackBar(
    BuildContext context, {
    required String message,
  }) {
    SnackBarService.showError(context, message);
  }
}
