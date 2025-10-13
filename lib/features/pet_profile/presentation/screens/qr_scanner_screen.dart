import 'package:aipet_frontend/features/pet_profile/presentation/controllers/qr_scanner_controller.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/widgets/qr_scanner/qr_scanner_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.pointBrown.withValues(alpha: 0.9),
                AppColors.pointBrown.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'QR 코드 스캔',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
