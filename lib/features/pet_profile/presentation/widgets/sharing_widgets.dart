import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// QR 코드 생성 탭 위젯
class GenerateCodeTab extends StatelessWidget {
  final List<PetProfileEntity> pets;
  final Function(PetProfileEntity) onPetTap;

  const GenerateCodeTab({super.key, required this.pets, required this.onPetTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 펫 프로필 목록
          ...pets.map((pet) => SharingPetCard(pet: pet, onTap: () => onPetTap(pet))),
          const SizedBox(height: AppSpacing.xl),

          // 설명 텍스트
          Text(
            'Generate a QR code and invite link for each pet and easily synchronise data with other users',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// QR 코드 스캔 탭 위젯
class ScanCodeTab extends StatelessWidget {
  final Function(String) onCodeScanned;

  const ScanCodeTab({super.key, required this.onCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR 스캐너 버튼
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: AppColors.pointBrown, width: 2, style: BorderStyle.solid),
            ),
            child: GestureDetector(
              onTap: () {
                // QR 스캐너 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _QRScannerScreen(onScanned: onCodeScanned),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 80, color: AppColors.pointBrown),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tap to Scan',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      color: AppColors.pointBrown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 설명 텍스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Scan QR codes to add pets shared by other users',
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 공유용 펫 프로필 카드
class SharingPetCard extends StatelessWidget {
  final PetProfileEntity pet;
  final VoidCallback onTap;

  const SharingPetCard({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 펫 프로필 이미지
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(pet.imagePath ?? 'assets/images/dogs/shiba.png'),
              backgroundColor: AppColors.pointBrown,
            ),
            const SizedBox(width: AppSpacing.md),

            // 펫 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.lg,
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${_getTypeString(pet.type)}${pet.breed != null ? ' | ${pet.breed}' : ''}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // 성별 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: _getGenderColor(pet), shape: BoxShape.circle),
              child: Icon(_getGenderIcon(pet), color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeString(String type) {
    switch (type) {
      case 'dog':
        return '犬';
      case 'cat':
        return '猫';
      default:
        return type;
    }
  }

  Color _getGenderColor(PetProfileEntity pet) {
    final gender = pet.additionalInfo?['gender'];
    return gender == 'male' ? AppColors.pointBlue : Colors.pink;
  }

  IconData _getGenderIcon(PetProfileEntity pet) {
    final gender = pet.additionalInfo?['gender'];
    return gender == 'male' ? Icons.male : Icons.female;
  }
}

/// QR 코드 모달 위젯
class QRCodeModal extends StatelessWidget {
  final PetProfileEntity pet;
  final String qrData;

  const QRCodeModal({super.key, required this.pet, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(pet.imagePath ?? 'assets/images/dogs/shiba.png'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                      Text(
                        pet.breed ?? '',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // QR 코드
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3)),
              ),
              child: Container(
                width: 200.0,
                height: 200.0,
                color: Colors.grey.withValues(alpha: 0.3),
                child: const Center(
                  child: Text(
                    'QR Code\n(패키지 필요)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 설명 텍스트
            Text(
              'このQRコードをスキャンして${pet.name}の情報を共有',
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 공유 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // 공유 기능 구현
                },
                icon: const Icon(Icons.share),
                label: const Text('共有'),
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
          ],
        ),
      ),
    );
  }
}

/// 간단한 QR 스캐너 화면 (실제 구현에서는 별도 파일로 분리)
class _QRScannerScreen extends StatelessWidget {
  final Function(String) onScanned;

  const _QRScannerScreen({required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR スキャナー'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'QR Scanner Implementation\n(qr_code_scanner package required)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
