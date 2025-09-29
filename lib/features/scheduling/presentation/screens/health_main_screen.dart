import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 건강 관리 메인 화면
class HealthMainScreen extends StatelessWidget {
  const HealthMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SoftGradientAppBar(title: '健康管理'),
      body: Padding(
        padding: const const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペットの健康状態を管理しましょう',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  _buildMenuCard(
                    icon: Icons.medical_services,
                    title: '健康チェック',
                    subtitle: '定期的な健康診断',
                    color: AppColors.pointBrown,
                    onTap: () => _navigateToHealthCheck(context),
                  ),
                  _buildMenuCard(
                    icon: Icons.medication,
                    title: '投薬管理',
                    subtitle: '薬のスケジュール',
                    color: AppColors.pointBrown,
                    onTap: () => _navigateToMedicationManagement(context),
                  ),
                  _buildMenuCard(
                    icon: Icons.fitness_center,
                    title: '運動記録',
                    subtitle: '運動量と活動',
                    color: AppColors.pointGreen,
                    onTap: () => _navigateToExerciseRecord(context),
                  ),
                  _buildMenuCard(
                    icon: Icons.analytics,
                    title: '健康分析',
                    subtitle: '健康データの分析',
                    color: AppColors.pointBlue,
                    onTap: () => _navigateToHealthAnalysis(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppFonts.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 건강 체크 페이지로 이동
  void _navigateToHealthCheck(BuildContext context) {
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
              Container(
                width: 40,
                height: 4,
                margin: const const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.pointGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const const EdgeInsets.all(AppSpacing.lg),
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
                      icon: Icons.thermostat,
                      title: '体温測定',
                      subtitle: '正常体温: 38-39°C',
                      onTap: () => _showTemperatureDialog(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildHealthCheckItem(
                      icon: Icons.favorite,
                      title: '心拍数チェック',
                      subtitle: '正常心拍数: 70-120 bpm',
                      onTap: () => _showHeartRateDialog(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildHealthCheckItem(
                      icon: Icons.water_drop,
                      title: '水分摂取量',
                      subtitle: '1日あたりの水分摂取を記録',
                      onTap: () => _showWaterIntakeDialog(context),
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

  /// 투약 관리 페이지로 이동
  void _navigateToMedicationManagement(BuildContext context) {
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
              onPressed: () => _showAddMedicationDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('薬を追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _showMedicationSchedule(context),
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

  /// 운동 기록 페이지로 이동
  void _navigateToExerciseRecord(BuildContext context) {
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
              Container(
                width: 40,
                height: 4,
                margin: const const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.pointGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const const EdgeInsets.all(AppSpacing.lg),
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
                      icon: Icons.directions_walk,
                      title: '散歩',
                      subtitle: '今日の散歩を記録',
                      onTap: () => _recordWalk(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildExerciseItem(
                      icon: Icons.sports,
                      title: '遊び',
                      subtitle: '運動や遊びの時間',
                      onTap: () => _recordPlay(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildExerciseItem(
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

  /// 건강 분석 페이지로 이동
  void _navigateToHealthAnalysis(BuildContext context) {
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
              onPressed: () => _showHealthTrends(context),
              icon: const Icon(Icons.trending_up),
              label: const Text('健康トレンド'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _showHealthReport(context),
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

  Widget _buildHealthCheckItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const const EdgeInsets.all(AppSpacing.sm),
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

  Widget _buildExerciseItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const const EdgeInsets.all(AppSpacing.sm),
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

  // 건강 체크 관련 다이얼로그들
  void _showTemperatureDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '体温測定',
      label: '体温 (°C)',
      hint: '38.5',
      onSave: (value) {
        final temp = double.tryParse(value);
        if (temp != null && temp >= 35 && temp <= 42) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('体温 $temp°C を記録しました')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('有効な体温を入力してください (35-42°C)')),
          );
        }
      },
    );
  }

  void _showHeartRateDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '心拍数チェック',
      label: '心拍数 (bpm)',
      hint: '90',
      onSave: (value) {
        final rate = int.tryParse(value);
        if (rate != null && rate >= 60 && rate <= 200) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('心拍数 ${rate}bpm を記録しました')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('有効な心拍数を入力してください (60-200 bpm)')),
          );
        }
      },
    );
  }

  void _showWaterIntakeDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '水分摂取量',
      label: '摂取量 (ml)',
      hint: '200',
      onSave: (value) {
        final amount = int.tryParse(value);
        if (amount != null && amount > 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('水分摂取量 ${amount}ml を記録しました')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('有効な摂取量を入力してください')));
        }
      },
    );
  }

  // 운동 기록 관련 다이얼로그들
  void _recordWalk(BuildContext context) {
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

  void _recordPlay(BuildContext context) {
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

  void _viewActivityHistory(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('活動履歴機能は開発中です')));
  }

  // 투약 관리 관련 다이얼로그들
  void _showAddMedicationDialog(BuildContext context) {
    _showInputDialog(
      context: context,
      title: '薬を追加',
      label: '薬の名前',
      hint: 'フロントライン',
      onSave: (value) {
        if (value.trim().isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$value を追加しました')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('薬の名前を入力してください')));
        }
      },
    );
  }

  void _showMedicationSchedule(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('投薬スケジュール機能は開発中です')));
  }

  // 건강 분석 관련 다이얼로그들
  void _showHealthTrends(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('健康トレンド分析機能は開発中です')));
  }

  void _showHealthReport(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('健康レポート機能は開発中です')));
  }

  // 공통 입력 다이얼로그
  void _showInputDialog({
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
