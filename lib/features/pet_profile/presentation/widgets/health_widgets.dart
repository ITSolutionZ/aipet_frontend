import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 건강 관리 카드 위젯
class HealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const HealthCard({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const const EdgeInsets.all(AppSpacing.lg),
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
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const const SizedBox(width: AppSpacing.lg),

            // 제목
            Expanded(
              child: Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 추가 버튼
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.pointBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 건강 탭 위젯
class HealthTab extends StatelessWidget {
  final String petId;

  const HealthTab({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          HealthCard(
            icon: Icons.security,
            title: '保険',
            iconColor: AppColors.pointBlue,
            onTap: () {
              // 보험 정보 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          HealthCard(
            icon: Icons.medical_services,
            title: 'Vaccines',
            iconColor: AppColors.pointGreen,
            onTap: () {
              // 백신 화면으로 이동
              Navigator.pushNamed(
                context,
                '/vaccines',
                arguments: {'petId': petId},
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          HealthCard(
            icon: Icons.medication,
            title: '寄生虫治療',
            iconColor: AppColors.pointPink,
            onTap: () {
              // 구충제/기생충 치료 정보 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          HealthCard(
            icon: Icons.hearing,
            title: '医療介入',
            iconColor: Colors.orange,
            onTap: () {
              // 의료 시술/수술 정보 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          HealthCard(
            icon: Icons.healing,
            title: 'その他の治療',
            iconColor: Colors.red,
            onTap: () {
              // 기타 치료 정보 화면으로 이동
            },
          ),
        ],
      ),
    );
  }
}

/// 의료 기록 카드
class MedicalRecordCard extends StatelessWidget {
  final String title;
  final String date;
  final String? description;
  final String? veterinarian;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const MedicalRecordCard({
    super.key,
    required this.title,
    required this.date,
    this.description,
    this.veterinarian,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const const EdgeInsets.all(AppSpacing.md),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    date,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (veterinarian != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.pointBlue,
                        ),
                        const const SizedBox(width: AppSpacing.xs),
                        Text(
                          veterinarian!,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.pointGray,
              ),
          ],
        ),
      ),
    );
  }
}

/// 건강 상태 요약 카드
class HealthSummaryCard extends StatelessWidget {
  final Map<String, dynamic> healthData;

  const HealthSummaryCard({super.key, required this.healthData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pointGreen.withValues(alpha: 0.1),
            AppColors.pointBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.pointGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.pointGreen,
                  size: 20,
                ),
              ),
              const const SizedBox(width: AppSpacing.md),
              Text(
                '健康状態',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildHealthMetric(
                  '最後の検診',
                  healthData['lastCheckup'] ?? '未設定',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildHealthMetric(
                  '次回予定',
                  healthData['nextCheckup'] ?? '未設定',
                  Icons.schedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.pointGreen),
            const const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
