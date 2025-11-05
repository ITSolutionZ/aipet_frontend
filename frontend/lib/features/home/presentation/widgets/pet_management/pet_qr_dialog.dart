import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';


import '../../../../../shared/shared.dart';
/// ペットQRコードダイアログ
class PetQRDialog extends StatelessWidget {
  final PetProfileEntity pet;

  const PetQRDialog({super.key, required this.pet});

  /// ダイアログを表示
  static void show(BuildContext context, PetProfileEntity pet) {
    showDialog(
      context: context,
      builder: (context) => PetQRDialog(pet: pet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${pet.name}의 QR 코드',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: 20),

            // QRコード
            _buildQRCode(),

            const SizedBox(height: 20),
            const Text(
              'QRコードをスキャンしてペット情報を共有してください',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.pointGray),
            ),
            const SizedBox(height: 20),

            // ボタン
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pointGray),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '닫기',
                      style: TextStyle(color: AppColors.pointGray),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: QRコード共有機能を実装
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '공유',
                      style: TextStyle(color: AppColors.pureWhite),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// QRコードを構築
  Widget _buildQRCode() {
    final qrData =
        'pet_profile:${pet.id}|${pet.name}|${pet.type}|${pet.weight}kg|https://aipet.app/pet/${pet.id}';

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3)),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: 180,
        backgroundColor: AppColors.pureWhite,
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.pointDark,
        ),
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.pointDark,
        ),
        gapless: false,
        embeddedImage: const AssetImage(
          'assets/icons/logos/logo_notinclude_text.png',
        ),
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(40, 40),
          color: AppColors.pointBrown,
        ),
        errorStateBuilder: (cxt, err) {
          return const Center(
            child: Text(
              'QR コード生成 중 오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.pointGray, fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
