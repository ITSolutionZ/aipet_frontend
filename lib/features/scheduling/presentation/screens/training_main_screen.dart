import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 학습/트레이닝 메인 화면
class TrainingMainScreen extends StatelessWidget {
  const TrainingMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SoftGradientAppBar(title: '学習・トレーニング'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ペットの学習とトレーニングを管理しましょう',
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
                    icon: Icons.school,
                    title: '基本トレーニング',
                    subtitle: '座る、待て、来いなど',
                    color: AppColors.pointBlue,
                    onTap: () => _navigateToBasicTraining(context),
                  ),
                  _buildMenuCard(
                    icon: Icons.psychology,
                    title: '高度な技',
                    subtitle: '複雑なコマンド',
                    color: AppColors.pointGreen,
                    onTap: () => _navigateToAdvancedSkills(context),
                  ),
                  _buildMenuCard(
                    icon: Icons.timer,
                    title: 'トレーニング記録',
                    subtitle: '進捗と成果',
                    color: AppColors.pointBrown,
                    onTap: () => _navigateToTrainingRecords(context),
                  ),
                  _buildMenuCard(
                    icon: Icons.calendar_today,
                    title: 'スケジュール',
                    subtitle: '練習予定',
                    color: AppColors.tonePeach,
                    onTap: () => _navigateToTrainingSchedule(context),
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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

  /// 기본 트레이닝 페이지로 이동
  void _navigateToBasicTraining(BuildContext context) {
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
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.pointGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                      icon: Icons.pets,
                      title: '座る',
                      difficulty: '初級',
                      description: 'お座りのコマンド',
                      onTap: () => _startTraining(context, '座る'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrainingCommand(
                      icon: Icons.pause_circle,
                      title: '待て',
                      difficulty: '初級',
                      description: 'その場で待つコマンド',
                      onTap: () => _startTraining(context, '待て'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrainingCommand(
                      icon: Icons.pets,
                      title: '来い',
                      difficulty: '初級',
                      description: '呼び寄せるコマンド',
                      onTap: () => _startTraining(context, '来い'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrainingCommand(
                      icon: Icons.stop,
                      title: '止まれ',
                      difficulty: '中級',
                      description: '動きを止めるコマンド',
                      onTap: () => _startTraining(context, '止まれ'),
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

  /// 고급 기술 페이지로 이동
  void _navigateToAdvancedSkills(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('高度な技'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの高度なスキルを練習しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _showAdvancedSkills(context),
              icon: const Icon(Icons.sports_gymnastics),
              label: const Text('芸を練習'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointGreen,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _showAgilityTraining(context),
              icon: const Icon(Icons.fitness_center),
              label: const Text('アジリティ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _showObedienceTraining(context),
              icon: const Icon(Icons.psychology),
              label: const Text('服従訓練'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
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

  /// 트레이닝 기록 페이지로 이동
  void _navigateToTrainingRecords(BuildContext context) {
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
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.pointGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                      onPressed: () => _viewDetailedRecords(context),
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

  /// 트레이닝 스케줄 페이지로 이동
  void _navigateToTrainingSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('練習スケジュール'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ペットの練習スケジュールを管理しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _createNewSchedule(context),
              icon: const Icon(Icons.add),
              label: const Text('新しいスケジュール'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tonePeach,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _viewWeeklySchedule(context),
              icon: const Icon(Icons.calendar_view_week),
              label: const Text('週間スケジュール'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBlue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () => _setTrainingReminders(context),
              icon: const Icon(Icons.notifications),
              label: const Text('リマインダー設定'),
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

  Widget _buildTrainingCommand({
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

  Widget _buildRecordItem({
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

  // 기본 트레이닝 관련 메서드들
  void _startTraining(BuildContext context, String command) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$command の練習'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$command のコマンドを練習しましょう'),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _recordTrainingSession(context, command),
              icon: const Icon(Icons.play_arrow),
              label: const Text('練習開始'),
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
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _recordTrainingSession(BuildContext context, String command) {
    Navigator.pop(context); // 이전 다이얼로그 닫기
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$command の練習セッションを記録しました')));
  }

  // 고급 기술 관련 메서드들
  void _showAdvancedSkills(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('芸の練習機能は開発中です')));
  }

  void _showAgilityTraining(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('アジリティ訓練機能は開発中です')));
  }

  void _showObedienceTraining(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('服従訓練機能は開発中です')));
  }

  // 기록 관련 메서드들
  void _viewDetailedRecords(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('詳細な記録機能は開発中です')));
  }

  // 스케줄 관련 메서드들
  void _createNewSchedule(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいスケジュール'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('練習スケジュールを作成しましょう'),
            SizedBox(height: AppSpacing.lg),
            TextField(
              decoration: InputDecoration(
                labelText: 'スケジュール名',
                hintText: '例: 毎日の基本練習',
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              decoration: InputDecoration(
                labelText: '練習内容',
                hintText: '座る、待て、来い',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('新しいスケジュールを作成しました')));
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _viewWeeklySchedule(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('週間スケジュール機能は開発中です')));
  }

  void _setTrainingReminders(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('リマインダー設定機能は開発中です')));
  }
}
