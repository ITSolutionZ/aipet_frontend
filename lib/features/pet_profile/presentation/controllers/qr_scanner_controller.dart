import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'qr_scanner_controller.freezed.dart';
part 'qr_scanner_controller.g.dart';

/// QR 스캐너 상태 관리
@riverpod
class QRScannerController extends _$QRScannerController {
  @override
  QRScannerState build() {
    return const QRScannerState();
  }

  /// 카메라 권한 요청
  Future<void> requestCameraPermission() async {
    state = state.copyWith(isLoading: true);
    // 임시로 항상 권한이 있다고 가정 (QR 스캐너 비활성화 상태)
    state = state.copyWith(hasPermission: true, isLoading: false);
  }

  /// QR 코드 검증
  bool isValidQRCode(String code) {
    return code.startsWith('pet_profile:') ||
        code.contains('aipet.app') ||
        code.contains('example.com');
  }

  /// QR 코드 처리
  Map<String, dynamic> processQRCode(String code) {
    if (isValidQRCode(code)) {
      return {
        'success': true,
        'data': code,
        'message': 'QRコードをスキャンしました: $code',
      };
    } else {
      return {'success': false, 'error': '無効なQRコードです'};
    }
  }
}

/// QR 스캐너 상태
@freezed
abstract class QRScannerState with _$QRScannerState {
  const factory QRScannerState({
    @Default(false) bool hasPermission,
    @Default(true) bool isLoading,
  }) = _QRScannerState;

  const QRScannerState._();
}
