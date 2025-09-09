import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 마이크로칩 등록 배너 위젯
class MicrochipRegistrationBanner extends StatelessWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onDismiss;

  const MicrochipRegistrationBanner({
    super.key,
    this.onRegisterTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 이미지 섹션
          Container(
            width: double.infinity,
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.large),
                topRight: Radius.circular(AppRadius.large),
              ),
              child: Image.asset(
                'assets/images/modal/microchip2.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.pointOffWhite,
                    child: const Icon(
                      Icons.pets,
                      size: 60,
                      color: AppColors.pointBrown,
                    ),
                  );
                },
              ),
            ),
          ),

          // 하단 콘텐츠 섹션
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pointOffWhite,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Text(
                    'うちの子のIDは',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.xl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // 부제목
                Text(
                  '小さなチップで大きな安心を',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 마이크로칩 필요 이유
                Text(
                  'マイクロチップが必要な理由3つ',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 이유 목록
                _buildReasonItem('迷子になったら、素早く家族を探せます'),
                const SizedBox(height: AppSpacing.sm),
                _buildReasonItem('ワクチンや、健康情報がスムーズに獣医にも'),
                const SizedBox(height: AppSpacing.sm),
                _buildReasonItem('小さなサイズでうちの子が気になることはない'),

                const SizedBox(height: AppSpacing.lg),

                // 등록 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRegisterTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                    ),
                    child: Text(
                      '登録する',
                      style: AppFonts.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 닫기 버튼
                if (onDismiss != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: onDismiss,
                      child: Text(
                        '後で',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: const Icon(Icons.pets, size: 16, color: AppColors.pointBrown),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
