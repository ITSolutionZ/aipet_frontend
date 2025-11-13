import 'package:aipet_frontend/features/pet_profile/domain/services/co_owner_qr_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 共同養育者招待QRコード表示画面
class CoOwnerQrScreen extends StatefulWidget {
  final PetProfileEntity pet;
  final String ownerId;
  final String ownerName;

  const CoOwnerQrScreen({
    super.key,
    required this.pet,
    required this.ownerId,
    required this.ownerName,
  });

  @override
  State<CoOwnerQrScreen> createState() => _CoOwnerQrScreenState();
}

class _CoOwnerQrScreenState extends State<CoOwnerQrScreen> {
  late String _qrData;
  late DateTime _expiresAt;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
    _startExpirationTimer();
  }

  void _generateQrCode() {
    _qrData = CoOwnerQrService.generateQrData(
      petId: widget.pet.id,
      ownerId: widget.ownerId,
      ownerName: widget.ownerName,
      petName: widget.pet.name,
    );
    _expiresAt = DateTime.now().add(const Duration(hours: 1));
  }

  void _startExpirationTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        final now = DateTime.now();
        if (now.isAfter(_expiresAt)) {
          setState(() {
            _isExpired = true;
          });
        } else {
          _startExpirationTimer();
        }
      }
    });
  }

  void _regenerateQrCode() {
    setState(() {
      _generateQrCode();
      _isExpired = false;
    });
    _startExpirationTimer();
  }

  String _getRemainingTime() {
    final now = DateTime.now();
    final remaining = _expiresAt.difference(now);

    if (remaining.isNegative) {
      return '期限切れ';
    }

    final minutes = remaining.inMinutes;
    if (minutes > 0) {
      return '残り$minutes分';
    }

    return '残り${remaining.inSeconds}秒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('共同養育者を招待'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildQrCodeSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildInstructionsSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.pointBrown.withValues(alpha: 0.1),
            AppColors.pointGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_2,
            size: 48,
            color: AppColors.pointBrown,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '「${widget.pet.name}」の\n共同養育者を招待',
            style: AppFonts.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'このQRコードをスキャンして\n共同養育者として登録できます',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isExpired)
            _buildExpiredOverlay()
          else
            QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 280.0,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              embeddedImage: const AssetImage('assets/icons/logo_notinclude_text.png'),
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(60, 60),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _isExpired
                  ? AppColors.pointRed.withValues(alpha: 0.1)
                  : AppColors.pointGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isExpired ? Icons.error : Icons.access_time,
                  size: 16,
                  color: _isExpired ? AppColors.pointRed : AppColors.pointGreen,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _getRemainingTime(),
                  style: AppFonts.bodySmall.copyWith(
                    color:
                        _isExpired ? AppColors.pointRed : AppColors.pointGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredOverlay() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.pointRed,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'QRコードの有効期限が\n切れました',
            style: AppFonts.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '新しいQRコードを生成してください',
            style: AppFonts.bodySmall.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.pointBlue,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '使い方',
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInstructionStep(
            number: '1',
            text: '招待したい人にこのQRコードを見せる',
          ),
          _buildInstructionStep(
            number: '2',
            text: '相手のアプリで「QRコードで追加」を選択',
          ),
          _buildInstructionStep(
            number: '3',
            text: 'このQRコードをスキャンして登録完了',
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.pointBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, size: 16, color: AppColors.pointBlue),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'QRコードは1時間で自動的に無効になります',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.pointBrown,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppFonts.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isExpired)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _regenerateQrCode,
              icon: const Icon(Icons.refresh),
              label: const Text('新しいQRコードを生成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('閉じる'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.pointGray,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
