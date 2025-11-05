import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import 'qr_code_constants.dart';
import 'qr_code_pet_selector.dart';
import 'qr_code_scan_section.dart';


/// 予約タブウィジェット
///
/// ペット予約用QRコードの表示とスキャン機能を提供
class QRCodeReservationTab extends StatelessWidget {
  final List<PetProfileEntity> activePets;
  final Function(BuildContext, String) onScanPressed;

  const QRCodeReservationTab({
    super.key,
    required this.activePets,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 自分のペットQRコードセクション
          if (activePets.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.pointBrown.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.pointBrown,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ペットの予約QRコード',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '予約に使用するペットを選択してください',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QRCodePetSelector(
                    pets: activePets,
                    qrType: QRCodeType.reservation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
          ],

          // QRスキャンセクション
          QRCodeScanSection(
            title: '予約用のQRコードをスキャンしてください。',
            buttonLabel: '予約用QRスキャン',
            buttonIcon: Icons.calendar_today,
            description: '動物病院やペットサロンで発行された予約用QRコードをスキャンしてください。',
            onScanPressed: () =>
                onScanPressed(context, QRCodeConstants.typeReservation),
          ),
        ],
      ),
    );
  }
}
