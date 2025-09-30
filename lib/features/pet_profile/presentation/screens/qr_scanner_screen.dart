import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 🎯 QR Scanner State Provider
final qrScannerStateProvider = StateNotifierProvider<QRScannerController, QRScannerState>(
  (ref) => QRScannerController(),
);

class QRScannerController extends StateNotifier<QRScannerState> {
  QRScannerController() : super(const QRScannerState());

  Future<void> requestCameraPermission() async {
    state = state.copyWith(isLoading: true);
    // 임시로 항상 권한이 있다고 가정 (QR 스캐너 비활성화 상태)
    state = state.copyWith(hasPermission: true, isLoading: false);
  }
}

class QRScannerState {
  final bool hasPermission;
  final bool isLoading;

  const QRScannerState({this.hasPermission = false, this.isLoading = true});

  QRScannerState copyWith({bool? hasPermission, bool? isLoading}) {
    return QRScannerState(
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

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
      ref.read(qrScannerStateProvider.notifier).requestCameraPermission();
    });
  }

  /// QR 코드 입력 처리
  void _handleQRCodeInput(String code) {
    // 결과를 이전 화면으로 전달
    if (mounted) {
      context.pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
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
    final state = ref.watch(qrScannerStateProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (!state.hasPermission) {
      return _buildPermissionDenied();
    }

    return _buildScanner();
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '카메라 권한이 필요합니다',
              style: AppFonts.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'QR 코드를 스캔하기 위해 카메라 접근 권한을 허용해주세요.',
              style: AppFonts.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => ref.read(qrScannerStateProvider.notifier).requestCameraPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
              ),
              child: Text(
                '권한 다시 요청',
                style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => context.pop(),
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

  Widget _buildScanner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'QRコード入力',
              style: AppFonts.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'QRコードを手動で入力してください',
              style: AppFonts.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => _showQRInputDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
              ),
              child: Text(
                'QRコードを入力',
                style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => context.pop(),
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

  void _showQRInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QRコード入力'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'QRコードを入力してください',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.of(context).pop();
              _handleQRCodeInput(value);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.of(context).pop();
                _handleQRCodeInput(controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
