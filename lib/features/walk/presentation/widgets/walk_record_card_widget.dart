import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class WalkRecordCardWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WalkRecordCardWidget({
    super.key,
    required this.walkRecord,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // 이 산책에 참여한 펫만 가져오기
    final pets = PetMockData.getMockPets();
    final walkPet = pets.firstWhere(
      (p) => p.id == walkRecord.petId,
      orElse: () => pets.first,
    );

    // 이 산책에 참여한 펫 리스트
    final walkPets = [walkPet];

    // 시작시간 - 끝시간 포맷
    final timeRange = _formatTimeRange();

    // 산책 제안 시간 대비 퍼센트 계산
    final recommendedMinutes = walkPet.recommendedWalkTime;
    final actualMinutes = walkRecord.calculatedDuration.inMinutes;
    final percentage = recommendedMinutes > 0
        ? ((actualMinutes / recommendedMinutes) * 100).round()
        : 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
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
            // 왼쪽: 펫 아바타들 (겹쳐서 표시)
            _buildPetAvatars(walkPets),

            const SizedBox(width: AppSpacing.md),

            // 중앙: 시간 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeRange,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      // 소요시간
                      _buildInfoChip(
                        icon: Icons.timer,
                        text: walkRecord.formattedDuration,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // 거리
                      _buildInfoChip(
                        icon: Icons.straighten,
                        text: walkRecord.formattedDistance,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // 제안 시간 대비 퍼센트
                      _buildInfoChip(
                        icon: Icons.emoji_events,
                        text: '$percentage%',
                        color: _getPercentageColor(percentage),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 오른쪽: 화살표 아이콘
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// 펫 아바타들 빌드 (여러 마리 겹쳐서 표시)
  Widget _buildPetAvatars(List pets) {
    if (pets.isEmpty) {
      return _buildSinglePetAvatar(null);
    }

    if (pets.length == 1) {
      return _buildSinglePetAvatar(pets.first);
    }

    // 2마리 이상: 겹쳐서 표시
    return SizedBox(
      width: 70, // 2개 겹칠 공간
      height: 50,
      child: Stack(
        children: [
          // 두 번째 펫 (뒤쪽)
          Positioned(
            right: 0,
            child: _buildSinglePetAvatar(
              pets[1],
              size: 50,
              borderColor: Colors.white,
            ),
          ),
          // 첫 번째 펫 (앞쪽)
          Positioned(
            left: 0,
            child: _buildSinglePetAvatar(
              pets[0],
              size: 50,
              borderColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 단일 펫 아바타 빌드
  Widget _buildSinglePetAvatar(
    dynamic pet, {
    double size = 50,
    Color borderColor = Colors.transparent,
  }) {
    final hasImage = pet?.imagePath != null && pet!.imagePath!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        border: Border.all(color: borderColor, width: 2),
        image: hasImage
            ? DecorationImage(
                image: AssetImage(pet!.imagePath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasImage
          ? ClipOval(
              child: Image.asset(
                'assets/icons/aipet_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.pets,
                    color: AppColors.pointBrown,
                    size: size * 0.48,
                  );
                },
              ),
            )
          : null,
    );
  }

  /// 정보 칩 빌드
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppColors.pointBrown).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.pointBrown),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color ?? AppColors.pointBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 시작시간 - 끝시간 포맷
  String _formatTimeRange() {
    final startHour = walkRecord.startTime.hour.toString().padLeft(2, '0');
    final startMinute = walkRecord.startTime.minute.toString().padLeft(2, '0');

    if (walkRecord.endTime != null) {
      final endHour = walkRecord.endTime!.hour.toString().padLeft(2, '0');
      final endMinute = walkRecord.endTime!.minute.toString().padLeft(2, '0');
      return '$startHour:$startMinute - $endHour:$endMinute';
    }

    return '$startHour:$startMinute - 進行中';
  }

  /// 퍼센트에 따른 색상
  Color _getPercentageColor(int percentage) {
    if (percentage >= 100) return AppColors.pointGreen;
    if (percentage >= 70) return AppColors.pointBrown;
    return AppColors.pointPink;
  }
}
