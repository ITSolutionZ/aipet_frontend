import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/presentation/controllers/qr_scanner_controller.dart';
import '../../../../../features/pet_profile/presentation/widgets/qr_scanner/qr_scanner_widgets.dart';

/// QR 코드 스캔 화면
///
/// 카메라를 사용하여 QR 코드를 스캔하는 화면입니다.
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qRScannerControllerProvider.notifier).requestCameraPermission();
    });
  }

  /// QR 코드 입력 처리
  void _handleQRCodeInput(String code) {
    final result = ref
        .read(qRScannerControllerProvider.notifier)
        .processQRCode(code);

    if (mounted) {
      if (result['success'] == true) {
        // 성공 시 결과를 이전 화면으로 전달
        context.pop(code);
      } else {
        // 실패 시 에러 메시지 표시
        SnackBarService.showError(context, result['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: null, // タイトルを削除
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = ref.watch(qRScannerControllerProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (!state.hasPermission) {
      return QRScannerPermissionDeniedView(
        onRetryPermission: () => ref
            .read(qRScannerControllerProvider.notifier)
            .requestCameraPermission(),
        onNavigateToLink: () => context.pop(),
      );
    }

    return QRScannerInputView(
      onShowQRInputDialog: _showQRInputDialog,
      onNavigateToLink: () => context.pop(),
    );
  }

  void _showQRInputDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          QRInputDialog(onQRCodeSubmitted: _handleQRCodeInput),
    );
  }
}
