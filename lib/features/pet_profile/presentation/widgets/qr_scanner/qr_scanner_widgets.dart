import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// QR 스캐너 화면의 UI 위젯들
/// 로직과 UI 완전 분리

/// 권한 거부 화면
class QRScannerPermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetryPermission;
  final VoidCallback onNavigateToLink;

  const QRScannerPermissionDeniedView({
    super.key,
    required this.onRetryPermission,
    required this.onNavigateToLink,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '카메라 권한이 필요합니다',
              style: AppFonts.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'QR 코드를 스캔하기 위해 카메라 접근 권한을 허용해주세요.',
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onRetryPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
              ),
              child: Text(
                '권한 다시 요청',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: onNavigateToLink,
              child: Text(
                '링크로 등록하기',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR 스캐너 화면 (현재는 수동 입력)
class QRScannerInputView extends StatelessWidget {
  final VoidCallback onShowQRInputDialog;
  final VoidCallback onNavigateToLink;

  const QRScannerInputView({
    super.key,
    required this.onShowQRInputDialog,
    required this.onNavigateToLink,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'QRコード入力',
              style: AppFonts.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'QRコードを手動で入力してください',
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onShowQRInputDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                ),
              ),
              child: Text(
                'QRコードを入力',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: onNavigateToLink,
              child: Text(
                'リンクで登録',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR 코드 입력 다이얼로그
class QRInputDialog extends StatefulWidget {
  final Function(String) onQRCodeSubmitted;

  const QRInputDialog({super.key, required this.onQRCodeSubmitted});

  @override
  State<QRInputDialog> createState() => _QRInputDialogState();
}

class _QRInputDialogState extends State<QRInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('QRコード入力'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'QRコードを入力してください',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.of(context).pop();
            widget.onQRCodeSubmitted(value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.of(context).pop();
              widget.onQRCodeSubmitted(_controller.text);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
