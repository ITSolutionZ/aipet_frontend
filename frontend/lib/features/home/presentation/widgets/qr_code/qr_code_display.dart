import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';


import '../../../../../shared/shared.dart';
import 'qr_code_constants.dart';
import 'qr_code_pet_selector.dart';


/// QRコード表示ウィジェット
class QRCodeDisplay extends StatelessWidget {
  final PetProfileEntity pet;
  final QRCodeType qrType;

  const QRCodeDisplay({super.key, required this.pet, required this.qrType});

  @override
  Widget build(BuildContext context) {
    final qrData = _generateQRData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ペット情報
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(pet.typeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                pet.name,
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${pet.typeName} • ${pet.weight}kg',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // QRコード
          Container(
            width: QRCodeConstants.qrCodeSize,
            height: QRCodeConstants.qrCodeSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
              ),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: QRCodeConstants.qrCodeImageSize,
              backgroundColor: Colors.white,
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
                size: Size(
                  QRCodeConstants.embeddedLogoSize,
                  QRCodeConstants.embeddedLogoSize,
                ),
                color: AppColors.pointBrown,
              ),
              errorStateBuilder: (cxt, err) {
                return const Center(
                  child: Text(
                    'QR コード生成エラー',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.pointGray, fontSize: 12),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 説明テキスト
          Text(
            _getDescriptionText(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// QRデータを生成
  String _generateQRData() {
    switch (qrType) {
      case QRCodeType.petRegistration:
        return QRCodeConstants.generatePetQRData(
          petId: pet.id,
          petName: pet.name,
          petType: pet.type,
          petWeight: pet.weight,
        );
      case QRCodeType.reservation:
        return QRCodeConstants.generateReservationQRData(
          petId: pet.id,
          petName: pet.name,
          petType: pet.type,
          petWeight: pet.weight,
        );
    }
  }

  /// 説明テキストを取得
  String _getDescriptionText() {
    switch (qrType) {
      case QRCodeType.petRegistration:
        return 'このQRコードをスキャンして\n${pet.name}を共同管理者として追加できます';
      case QRCodeType.reservation:
        return '病院やサロンでこのQRコードを\nスキャンして予約できます';
    }
  }
}
