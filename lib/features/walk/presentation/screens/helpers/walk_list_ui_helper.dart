import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 산책 리스트 UI 헬퍼
class WalkListUiHelper {
  /// 펫 선택 리스트 빌드 (펫이 없는 경우)
  static Widget buildEmptyPetButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
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
          width: 75,
          padding: const EdgeInsets.all(8),
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
              const SizedBox(height: 3),

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
              const SizedBox(height: 2),

              // 권장 산책 시간
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${pet.recommendedWalkTime}分',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
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
                    size: 22,
                  );
                },
              )
            : Icon(
                Icons.pets,
                color: isSelected ? AppColors.pointPink : AppColors.pointGray,
                size: 22,
              ),
      ),
    );
  }

  /// 산책 정보 카드 빌드
  static Widget buildWalkInfoCard({
    required int elapsedSeconds,
    required double distance,
    required int recommendedTime,
  }) {
    final hours = elapsedSeconds ~/ 3600;
    final seconds = elapsedSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 소요 시간
          _buildInfoItem(
            icon: Icons.timer,
            value: '$hours:${seconds.toString().padLeft(2, '0')}',
          ),

          // 거리
          _buildInfoItem(
            icon: Icons.straighten,
            value: distance < 1
                ? '${(distance * 1000).toStringAsFixed(0)}m'
                : '${distance.toStringAsFixed(2)}km',
          ),

          // 추천 시간
          _buildInfoItem(icon: Icons.flag_outlined, value: '$recommendedTime分'),
        ],
      ),
    );
  }

  /// 정보 아이템 빌드
  static Widget _buildInfoItem({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.pointBrown, size: 18),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointBrown,
          ),
        ),
      ],
    );
  }

  /// 활동 버튼 빌드
  static Widget buildActivityButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: 28,
            height: 28,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.pets,
                size: 28,
                color: AppColors.pointBrown,
              );
            },
          ),
        ),
      ),
    );
  }

  /// 시작 버튼 빌드
  static Widget buildStartButton({required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.pointBrown,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointBrown.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'スタート',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 산책 중 버튼들 빌드
  static Widget buildWalkingButtons({
    required bool isPaused,
    required VoidCallback onPause,
    required VoidCallback onEnd,
  }) {
    return Row(
      children: [
        // 일시정지/재시작 버튼
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isPaused
                  ? AppColors.pointGreen.withValues(alpha: 0.9)
                  : AppColors.pointBlue.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (isPaused ? AppColors.pointGreen : AppColors.pointBlue)
                      .withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: onPause,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              label: Text(
                isPaused ? '再開' : '一時停止',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 종료 버튼
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.pointPink,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pointPink.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: onEnd,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              icon: const Icon(Icons.stop, color: Colors.white),
              label: Text(
                '終了',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 상단 버튼 빌드 (리스트/위치)
  static Widget buildTopButtons({
    required VoidCallback onListTap,
    required VoidCallback onLocationTap,
  }) {
    return Column(
      children: [
        // 산책 기록 리스트 버튼
        _buildCircleButton(
          icon: Icons.list,
          color: AppColors.textPrimary,
          onPressed: onListTap,
        ),
        const SizedBox(height: 8),
        // 현재 위치로 이동 버튼
        _buildCircleButton(
          icon: Icons.my_location,
          color: AppColors.pointBrown,
          onPressed: onLocationTap,
        ),
      ],
    );
  }

  /// 원형 버튼 빌드
  static Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
