import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/pet_profile/presentation/controllers/vaccine_controller.dart';

/// 백신 관리 화면의 UI 위젯들
/// 로직과 UI 완전 분리

/// 날짜 포맷팅 헬퍼 함수
String _formatDate(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日';
}

/// 백신 관리 헤더 카드
class VaccineHeaderCard extends ConsumerWidget {
  const VaccineHeaderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccineState = ref.watch(vaccineControllerProvider('default_pet_id'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: AppColors.pointGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ワクチン管理',
                      style: AppFonts.titleMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '愛犬の健康を守るワクチン記録を管理',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // 통계 정보
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '完了',
                  '${vaccineState.vaccines.where((v) => v.isCompleted).length}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '予定',
                  '${vaccineState.vaccines.where((v) => !v.isCompleted).length}',
                ),
              ),
              Expanded(
                child: _buildStatItem('総数', '${vaccineState.vaccines.length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.titleLarge.copyWith(
            color: AppColors.pointGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// 백신 카드
class VaccineCard extends ConsumerWidget {
  final VaccineRecord vaccine;
  final VoidCallback? onTap;

  const VaccineCard({super.key, required this.vaccine, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: vaccine.isCompleted
                        ? AppColors.pointGreen.withValues(alpha: 0.1)
                        : AppColors.pointPink.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vaccine.isCompleted ? Icons.check_circle : Icons.schedule,
                    color: vaccine.isCompleted
                        ? AppColors.pointGreen
                        : AppColors.pointPink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccine.name,
                        style: AppFonts.titleMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        vaccine.description,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  vaccine.isCompleted ? '完了' : '予定',
                  style: AppFonts.bodySmall.copyWith(
                    color: vaccine.isCompleted
                        ? AppColors.pointGreen
                        : AppColors.pointPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('前回', _formatDate(vaccine.lastDate)),
                ),
                Expanded(
                  child: _buildInfoItem('次回', _formatDate(vaccine.nextDue)),
                ),
                Expanded(child: _buildInfoItem('間隔', vaccine.interval)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointDark.withValues(alpha: 0.7),
          ),
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

/// 백신 상세 모달
class VaccineDetailModal extends StatelessWidget {
  final VaccineRecord vaccine;

  const VaccineDetailModal({super.key, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(vaccine.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vaccine.description,
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailItem('前回接種日', _formatDate(vaccine.lastDate)),
            _buildDetailItem('次回予定日', _formatDate(vaccine.nextDue)),
            _buildDetailItem('接種間隔', vaccine.interval),
            _buildDetailItem('獣医師', vaccine.veterinarian.name),
            _buildDetailItem('クリニック', vaccine.veterinarian.clinic),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
            ),
          ),
        ],
      ),
    );
  }
}

/// 새 백신 추가 버튼
class AddVaccineButton extends ConsumerWidget {
  final String petId;

  const AddVaccineButton({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddVaccineDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新しいワクチン記録を追加'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pointBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
        ),
      ),
    );
  }

  void _showAddVaccineDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいワクチン記録'),
        content: const Text('ワクチン追加機能は開発中です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

/// 백신 목록
class VaccineList extends ConsumerWidget {
  final String petId;
  final Function(VaccineRecord)? onVaccineTap;

  const VaccineList({super.key, required this.petId, this.onVaccineTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccineState = ref.watch(vaccineControllerProvider(petId));

    if (vaccineState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vaccineState.error != null) {
      return Center(child: Text('エラーが発生しました: ${vaccineState.error}'));
    }

    if (vaccineState.vaccines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: AppColors.pointGray,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'ワクチン記録がありません',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '新しいワクチン記録を追加してください',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: vaccineState.vaccines
          .map(
            (vaccine) => VaccineCard(
              vaccine: vaccine,
              onTap: () => onVaccineTap?.call(vaccine),
            ),
          )
          .toList(),
    );
  }
}
