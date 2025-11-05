import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import 'qr_code_constants.dart';


/// QRコードスキャンセクションウィジェット
///
/// スキャンボタンと説明を含む共通UI
class QRCodeScanSection extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final IconData buttonIcon;
  final String description;
  final VoidCallback onScanPressed;

  const QRCodeScanSection({
    super.key,
    required this.title,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.description,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // タイトル
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // QRスキャンアイコン
        Container(
          width: QRCodeConstants.scanIconSize,
          height: QRCodeConstants.scanIconSize,
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            size: QRCodeConstants.scanIconInnerSize,
            color: AppColors.pointBrown,
          ),
        ),

        const SizedBox(height: 24),

        // スキャンボタン
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onScanPressed,
            icon: Icon(buttonIcon),
            label: Text(buttonLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 説明テキスト
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
