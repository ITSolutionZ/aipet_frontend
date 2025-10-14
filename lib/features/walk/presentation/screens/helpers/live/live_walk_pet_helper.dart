import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Live Walk 펫 관련 헬퍼
class LiveWalkPetHelper {
  /// 빈 펫 버튼 빌드 (펫 등록 유도)
  static Widget buildEmptyPetButton({required BuildContext context}) {
    return GestureDetector(
      onTap: () => context.push('/daily-pet-registration'),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.pointBrown.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  /// 펫 카드 빌드
  static Widget buildPetCard({
    required dynamic pet,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.pointPink.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: isSelected
                ? Border.all(color: AppColors.pointPink, width: 3)
                : Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 펫 아바타
              _buildPetAvatar(pet, isSelected),
              const SizedBox(height: 4),

              // 펫 이름
              Text(
                pet.name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),

              // 몸무게
              Text(
                '${pet.weight}kg',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                '30分 권장',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 펫 아바타 빌드
  static Widget _buildPetAvatar(dynamic pet, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white
            : AppColors.pointGray.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: pet.imagePath?.isNotEmpty == true
            ? Image.asset(
                pet.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.pets,
                    color: isSelected
                        ? AppColors.pointPink
                        : AppColors.pointGray,
                    size: 25,
                  );
                },
              )
            : Icon(
                Icons.pets,
                color: isSelected ? AppColors.pointPink : AppColors.pointGray,
                size: 25,
              ),
      ),
    );
  }
}
