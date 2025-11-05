import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import 'training_dialog_helper.dart';


/// 트레이닝 BottomSheet 헬퍼
class TrainingSheetHelper {
  /// 기본 트레이닝 BottomSheet
  static void showBasicTrainingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '基本トレーニング',
                      style: AppFonts.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ペットの基本的なコマンドを練習しましょう',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTrainingCommand(
                      context: context,
                      icon: Icons.pets,
                      title: '座る',
                      difficulty: '初級',
                      description: 'お座りのコマンド',
                      onTap: () => TrainingDialogHelper.showStartTrainingDialog(
                        context,
                        '座る',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrainingCommand(
                      context: context,
                      icon: Icons.pause_circle,
                      title: '待て',
                      difficulty: '初級',
                      description: 'その場で待つコマンド',
                      onTap: () => TrainingDialogHelper.showStartTrainingDialog(
                        context,
                        '待て',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrainingCommand(
                      context: context,
                      icon: Icons.pets,
                      title: '来い',
                      difficulty: '初級',
                      description: '呼び寄せるコマンド',
                      onTap: () => TrainingDialogHelper.showStartTrainingDialog(
                        context,
                        '来い',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrainingCommand(
                      context: context,
                      icon: Icons.stop,
                      title: '止まれ',
                      difficulty: '中級',
                      description: '動きを止めるコマンド',
                      onTap: () => TrainingDialogHelper.showStartTrainingDialog(
                        context,
                        '止まれ',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 트레이닝 기록 BottomSheet
  static void showTrainingRecordsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'トレーニング記録',
                      style: AppFonts.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ペットの練習の進捗と成果を確認しましょう',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecordItem(
                      title: '今週の練習時間',
                      value: '2時間 30分',
                      icon: Icons.access_time,
                      color: AppColors.pointBlue,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildRecordItem(
                      title: '習得済みコマンド',
                      value: '5個',
                      icon: Icons.check_circle,
                      color: AppColors.pointGreen,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildRecordItem(
                      title: '練習日数',
                      value: '12日',
                      icon: Icons.calendar_today,
                      color: AppColors.pointBrown,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () =>
                          SnackBarService.showInfo(context, '詳細な記録機能は開発中です'),
                      icon: const Icon(Icons.history),
                      label: const Text('詳細な記録を見る'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointBrown,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Private Helper Methods ===

  /// BottomSheet 핸들
  static Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pointGray,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 트레이닝 커맨드 아이템
  static Widget _buildTrainingCommand({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String difficulty,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.pointBlue),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.pointGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                difficulty,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  /// 기록 아이템
  static Widget _buildRecordItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
