import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_widgets.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DailyHealthScreen extends ConsumerStatefulWidget {
  const DailyHealthScreen({super.key});

  @override
  ConsumerState<DailyHealthScreen> createState() => _DailyHealthScreenState();
}

class _DailyHealthScreenState extends ConsumerState<DailyHealthScreen> {
  String? _selectedPetId;

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return petsAsync.when(
      data: (pets) {
        // 첫 번째 펫을 기본 선택으로 설정
        if (_selectedPetId == null && pets.isNotEmpty) {
          _selectedPetId = pets.first.id;
        }

        final todayRecord = _selectedPetId != null
            ? ref.watch(todayHealthRecordProvider(_selectedPetId!))
            : const AsyncValue.data(null);

        return Scaffold(
          backgroundColor: AppColors.pointOffWhite,
          appBar: AppBar(
            backgroundColor: AppColors.pointOffWhite,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: PetSelectorWidget(
              selectedPetId: _selectedPetId,
              onPetSelected: (petId) {
                setState(() {
                  _selectedPetId = petId;
                });
              },
            ),
            centerTitle: true,
            actions: [
              Semantics(
                label: 'カレンダーボタン',
                button: true,
                hint: 'タップしてカレンダー画面を開きます',
                child: IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    // 캘린더 화면으로 이동
                  },
                ),
              ),
            ],
          ),
          body: todayRecord.when(
            data: (record) => _buildContent(context, record),
            loading: () => const LoadingStateWidget(),
            error: (error, stack) => ErrorStateWidget(
              error: error,
              onRetry: () {
                if (_selectedPetId != null) {
                  ref.invalidate(todayHealthRecordProvider(_selectedPetId!));
                }
              },
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        body: LoadingStateWidget(),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        body: ErrorStateWidget(
          error: error,
          onRetry: () => ref.invalidate(petProfilesNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyHealthRecord? record) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DateHeaderWidget(),
          const SizedBox(height: AppSpacing.lg),

          if (record != null) ...[
            TemperatureDisplayCard(record: record),
            const SizedBox(height: AppSpacing.md),
            HealthStatusCard(record: record),
            const SizedBox(height: AppSpacing.md),
            SymptomsCard(record: record),
            const SizedBox(height: AppSpacing.lg),
            _buildAIAnalysisSection(record),
          ] else ...[
            const EmptyStateWidget(
              icon: Icons.favorite_outline,
              title: '今日の健康記録がありません',
              subtitle: 'ペットの体温と健康状態を入力してください',
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          _buildActionButtons(record),
          const SizedBox(height: AppSpacing.lg),
          _buildHospitalGuidance(),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisSection(DailyHealthRecord record) {
    final analysis = ref.watch(healthAnalysisProvider(record.id));

    return analysis.when(
      data: (analysisData) => analysisData != null
          ? AIAnalysisCard(analysis: analysisData)
          : _buildAIAnalysisPending(),
      loading: () => _buildAIAnalysisLoading(),
      error: (error, stack) => _buildAIAnalysisError(),
    );
  }

  Widget _buildAIAnalysisPending() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: Colors.blue[600]),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AIレポート',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AIが健康状態を分析中です...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'AI分析ボタン',
            button: true,
            hint: 'タップしてAIによる健康状態分析を開始します',
            child: ElevatedButton(
              onPressed: () => _analyzeHealth(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('分析する'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisLoading() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Text(
            'AIが健康状態を分析しています...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisError() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
          Expanded(
            child: Text(
              'AI分析中にエラーが発生しました',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Semantics(
            label: '再試行ボタン',
            button: true,
            hint: 'タップしてAI分析を再試行します',
            child: TextButton(
              onPressed: () => _analyzeHealth(),
              child: const Text('再試行'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DailyHealthRecord? record) {
    return Row(
      children: [
        Expanded(
          child: ActionButtonWidget(
            text: record != null ? '健康状態を編集' : '健康状態を入力',
            icon: record != null ? Icons.edit : Icons.add,
            onPressed: () => _navigateToHealthInput(record),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
        Expanded(
          child: ActionButtonWidget(
            text: '記録を見る',
            icon: Icons.history,
            onPressed: () => _navigateToHistoryScreen(),
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalGuidance() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.green[700]),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '病院案内',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          Text(
            '健康に異常がある場合は、近くの動物病院で正確な診断を受けてください。',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.green[700]),
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
          Semantics(
            label: '病院検索ボタン',
            button: true,
            hint: 'タップして周辺の動物病院を検索します',
            child: ElevatedButton.icon(
              onPressed: () => _navigateToHospitalSearch(),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('周辺病院を探す'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHealthInput(DailyHealthRecord? record) {
    context.push('/home/daily/input', extra: record);
  }

  void _navigateToHistoryScreen() {
    context.push('/home/daily/history');
  }

  void _navigateToHospitalSearch() {
    context.push('/home/calendar');
  }

  void _analyzeHealth() {
    if (_selectedPetId == null) return;
    // AI 분석 실행
    ref
        .read(dailyHealthControllerProvider.notifier)
        .analyzeCurrentHealth(_selectedPetId!);
  }
}
