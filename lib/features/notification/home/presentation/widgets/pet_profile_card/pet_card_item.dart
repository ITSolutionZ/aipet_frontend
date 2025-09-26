import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 개별 펫 카드 아이템
class PetCardItem extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback? onTap;

  const PetCardItem({super.key, required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/pet/profile/${pet.id}'),
      child: WhiteCard.panel(
        child: Column(
          children: [
            // Pet 이미지
            _buildPetImage(),
            const SizedBox(height: AppSpacing.md),

            // Pet 정보
            _buildPetInfo(),
            const SizedBox(height: AppSpacing.md),

            // 액션 버튼들
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: pet.imagePath?.isNotEmpty == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: Image.asset(
                pet.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultImage(),
              ),
            )
          : _buildDefaultImage(),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: const Icon(Icons.pets, color: AppColors.pointBrown, size: 32),
    );
  }

  Widget _buildPetInfo() {
    return Column(
      children: [
        Text(
          pet.name,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${pet.breed ?? pet.typeDisplay} • ${pet.ageDisplay}',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.edit,
          label: '編集',
          onTap: () => context.push('/pet/edit/${pet.id}'),
        ),
        _buildActionButton(
          icon: Icons.medical_services,
          label: '健康',
          onTap: () => context.push('/pet/health/${pet.id}'),
        ),
        _buildActionButton(
          icon: Icons.share,
          label: '共有',
          onTap: () => context.push('/pet/share/${pet.id}'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.pointBrown, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppFonts.caption.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}
