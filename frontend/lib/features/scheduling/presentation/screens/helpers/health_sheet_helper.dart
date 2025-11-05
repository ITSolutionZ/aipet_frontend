import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import 'health_dialog_helper.dart';


/// 건강 관리 BottomSheet 헬퍼
class HealthSheetHelper {
  /// 건강 체크 BottomSheet
  static void showHealthCheckSheet(BuildContext context) {
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
                      '健康チェック',
                      style: AppFonts.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ペットの健康状態をチェックしましょう',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildHealthCheckItem(
                      context: context,
                      icon: Icons.thermostat,
                      title: '体温測定',
                      subtitle: '正常体温: 38-39°C',
                      onTap: () =>
                          HealthDialogHelper.showTemperatureDialog(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildHealthCheckItem(
                      context: context,
                      icon: Icons.favorite,
                      title: '心拍数チェック',
                      subtitle: '正常心拍数: 70-120 bpm',
                      onTap: () =>
                          HealthDialogHelper.showHeartRateDialog(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildHealthCheckItem(
                      context: context,
                      icon: Icons.water_drop,
                      title: '水分摂取量',
                      subtitle: '1日あたりの水分摂取を記録',
                      onTap: () =>
                          HealthDialogHelper.showWaterIntakeDialog(context),
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

  /// 운동 기록 BottomSheet
  static void showExerciseRecordSheet(BuildContext context) {
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
                      '運動記録',
                      style: AppFonts.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pointDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ペットの運動と活動を記録しましょう',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildExerciseItem(
                      context: context,
                      icon: Icons.directions_walk,
                      title: '散歩',
                      subtitle: '今日の散歩を記録',
                      onTap: () => _recordWalk(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildExerciseItem(
                      context: context,
                      icon: Icons.sports,
                      title: '遊び',
                      subtitle: '運動や遊びの時間',
                      onTap: () => _recordPlay(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildExerciseItem(
                      context: context,
                      icon: Icons.timeline,
                      title: '活動記録',
                      subtitle: '過去の活動を見る',
                      onTap: () => _viewActivityHistory(context),
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

  /// 투약 관리 다이얼로그
  static void showMedicationManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('投薬管理'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの薬のスケジュールを管理しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () =>
                  HealthDialogHelper.showAddMedicationDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('薬を追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () =>
                  HealthDialogHelper.showMedicationSchedule(context),
              icon: const Icon(Icons.schedule),
              label: const Text('スケジュール確認'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 건강 분석 다이얼로그
  static void showHealthAnalysisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('健康分析'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの健康データを分析しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => HealthDialogHelper.showHealthTrends(context),
              icon: const Icon(Icons.trending_up),
              label: const Text('健康トレンド'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => HealthDialogHelper.showHealthReport(context),
              icon: const Icon(Icons.assessment),
              label: const Text('健康レポート'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // === Private Helper Methods ===

  /// BottomSheet 핸들 위젯
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

  /// 건강 체크 아이템
  static Widget _buildHealthCheckItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.pointBrown),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  /// 운동 아이템
  static Widget _buildExerciseItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.pointGreen),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  /// 산책 기록
  static void _recordWalk(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '散歩記録',
      label: '散歩時間 (分)',
      hint: '30',
      onSave: (value) {
        final duration = int.tryParse(value);
        if (duration != null && duration > 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$duration分の散歩を記録しました')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('有効な時間を入力してください')));
        }
      },
    );
  }

  /// 놀이 기록
  static void _recordPlay(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '遊び記録',
      label: '遊び時間 (分)',
      hint: '15',
      onSave: (value) {
        final duration = int.tryParse(value);
        if (duration != null && duration > 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$duration分の遊びを記録しました')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('有効な時間を入力してください')));
        }
      },
    );
  }

  /// 활동 히스토리 보기
  static void _viewActivityHistory(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('活動履歴機能は開発中です')));
  }

  /// 공통 입력 다이얼로그
  static void _showInputDialog({
    required BuildContext context,
    required String title,
    required String label,
    required String hint,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label, hintText: hint),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
