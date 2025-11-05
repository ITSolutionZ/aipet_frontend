import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// ペットカードウィジェット
///
/// ペット管理画面で使用されるペット情報カード
class PetCardWidget extends StatelessWidget {
  final PetProfileEntity pet;
  final VoidCallback onTap;
  final VoidCallback onSharePressed;

  const PetCardWidget({
    super.key,
    required this.pet,
    required this.onTap,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.pureWhite,
              AppColors.pointOffWhite.withValues(alpha: 0.3),
              AppColors.pureWhite,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ペット画像
            _buildPetImage(),
            const SizedBox(width: 12),

            // ペット情報
            Expanded(child: _buildPetInfo()),

            // 共有ボタン
            _buildShareButton(),
          ],
        ),
      ),
    );
  }

  /// ペット画像セクション
  Widget _buildPetImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: pet.imagePath != null && pet.imagePath!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(),
            )
          : const Icon(Icons.pets, color: AppColors.pointGray, size: 30),
    );
  }

  /// ペット情報セクション
  Widget _buildPetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 16, color: AppColors.pointGray),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '나이 • ${pet.typeName}',
          style: const TextStyle(fontSize: 12, color: AppColors.pointGray),
        ),
        const SizedBox(height: 2),
        Text(
          '몸무게 • ${pet.weight}kg',
          style: const TextStyle(fontSize: 12, color: AppColors.pointGray),
        ),
        const SizedBox(height: 2),
        const Text(
          '등록요청자 • 없음',
          style: TextStyle(fontSize: 12, color: AppColors.pointGray),
        ),
        const SizedBox(height: 2),
        const Text(
          '의료병원 • 없음',
          style: TextStyle(fontSize: 12, color: AppColors.pointGray),
        ),
      ],
    );
  }

  /// 共有ボタン
  Widget _buildShareButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: onSharePressed,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_shared_outlined,
              size: 14,
              color: AppColors.pointBrown,
            ),
            SizedBox(width: 4),
            Text(
              '共同管理者を招待',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 画像をビルド
  Widget _buildImage() {
    if (pet.imagePath == null || pet.imagePath!.isEmpty) {
      return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
    }

    // 相対パスを絶対パスに変換
    final storageService = ImageStorageService();
    final absolutePath =
        storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;

    final imageType = ImageService.getImageType(absolutePath);

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        if (!file.existsSync()) {
          return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
        }
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.pets, color: AppColors.pointGray, size: 30);
          },
        );
    }
  }
}
