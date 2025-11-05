import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import 'qr_code_constants.dart';
import 'qr_code_pet_selector.dart';
import 'qr_code_scan_section.dart';


/// ペット登録タブウィジェット
///
/// ペット共有用QRコードの表示とスキャン機能を提供
class QRCodePetRegistrationTab extends StatelessWidget {
  final List<PetProfileEntity> activePets;
  final Function(BuildContext, String) onScanPressed;

  const QRCodePetRegistrationTab({
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
                        Icons.pets,
                        size: 20,
                        color: AppColors.pointBrown,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '私のペットを共有',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '他の人に共有したいペットを選択してください',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  QRCodePetSelector(
                    pets: activePets,
                    qrType: QRCodeType.petRegistration,
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
            title: 'ペット登録用のQRコードをスキャンしてください。',
            buttonLabel: 'ペット登録用QRスキャン',
            buttonIcon: Icons.qr_code_scanner,
            description: '他の人が共有したペット登録用QRコードをスキャンしてください。',
            onScanPressed: () =>
                onScanPressed(context, QRCodeConstants.typePetRegistration),
          ),
        ],
      ),
    );
  }
}
