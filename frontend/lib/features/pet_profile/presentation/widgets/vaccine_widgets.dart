import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 백신 카드 위젯
class VaccineCard extends StatelessWidget {
  final Map<String, dynamic> vaccine;
  final VoidCallback onTap;

  const VaccineCard({super.key, required this.vaccine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = vaccine['isCompleted'] as bool? ?? false;
    final nextDue = vaccine['nextDue'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 상태 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.pointGreen.withValues(alpha: 0.1)
                    : AppColors.pointPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.schedule,
                color: isCompleted ? AppColors.pointGreen : AppColors.pointPink,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // 백신 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine['name'] ?? 'Unknown Vaccine',
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    vaccine['description'] ?? 'No description',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                  ),
                  if (nextDue != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Next: $nextDue',
                      style: AppFonts.bodySmall.copyWith(
                        color: isCompleted
                            ? AppColors.pointGreen
                            : AppColors.pointPink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 완료 상태 배지
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pointGreen,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  '完了',
                  style: AppFonts.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 백신 상세 모달
class VaccineDetailModal extends StatelessWidget {
  final Map<String, dynamic> vaccine;

  const VaccineDetailModal({super.key, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
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
                Expanded(
                  child: Text(
                    vaccine['name'] ?? 'Unknown Vaccine',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pointDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // 내용
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 백신 정보
                    _buildDetailSection('ワクチン情報', [
                      _buildDetailRow('名前', vaccine['name'] ?? 'Unknown'),
                      _buildDetailRow(
                        '説明',
                        vaccine['description'] ?? 'No description',
                      ),
                      _buildDetailRow(
                        '状態',
                        vaccine['isCompleted'] == true ? '完了' : '未完了',
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.lg),

                    // 일정 정보
                    _buildDetailSection('スケジュール', [
                      _buildDetailRow('最後の接種', vaccine['lastDate'] ?? '未設定'),
                      _buildDetailRow('次回予定', vaccine['nextDue'] ?? '未設定'),
                      _buildDetailRow('間隔', vaccine['interval'] ?? '未設定'),
                    ]),

                    const SizedBox(height: AppSpacing.lg),

                    // 수의사 정보
                    VeterinarianCard(
                      veterinarian:
                          vaccine['veterinarian'] as Map<String, dynamic>? ??
                          {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 편집 기능
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.pointBrown),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: Text(
                      '編集',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 접종 완료 처리
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointGreen,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: Text(
                      '접종 완료',
                      style: AppFonts.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 수의사 카드 위젯
class VeterinarianCard extends StatelessWidget {
  final Map<String, dynamic> veterinarian;

  const VeterinarianCard({super.key, required this.veterinarian});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '獣医師情報',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pointBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.pointBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      veterinarian['name'] ?? '未設定',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (veterinarian['clinic'] != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        veterinarian['clinic'],
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
