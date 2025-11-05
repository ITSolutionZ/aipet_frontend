import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import '../controllers/daily_health_controller.dart';
import '../controllers/daily_health_screen_controller.dart';
import '../logic/daily_health_logic.dart';
import '../widgets/hospital_link_banner.dart';
import 'daily_health_screen_widgets/daily_health_screen_widgets.dart';


/// Daily Health 화면 - 완전히 리팩토링된 버전
///
/// 모든 UI 위젯이 별도 파일로 분리되어 가독성과 유지보수성이 크게 향상됨
class DailyHealthScreen extends ConsumerWidget {
  const DailyHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(dailyHealthScreenControllerProvider);
    final controller = ref.read(dailyHealthScreenControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: DailyHealthAppBar(logic: controller.logic),
      body: screenData.selectedPetId != null
          ? _HealthContentView(
              petId: screenData.selectedPetId!,
              logic: controller.logic,
            )
          : _NoPetHealthView(logic: controller.logic),
    );
  }
}

/// 건강 콘텐츠 뷰 (내부 위젯)
class _HealthContentView extends ConsumerWidget {
  final String petId;
  final DailyHealthLogic logic;

  const _HealthContentView({required this.petId, required this.logic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(dailyHealthScreenControllerProvider);
    final currentPetId = screenData.selectedPetId ?? petId;

    LoggerService.debug(
      '🔍 _HealthContentView - currentPetId: $currentPetId, screenData.selectedPetId: ${screenData.selectedPetId}',
    );

    // 펫 변경시 provider들을 강제로 새로고침
    final healthRecordAsync = ref.watch(
      dailyHealthRecordProvider(currentPetId),
    );
    final healthAnalysisAsync = ref.watch(
      dailyHealthAnalysisProvider(currentPetId),
    );

    return healthRecordAsync.when(
      data: (healthRecord) => healthAnalysisAsync.when(
        data: (analysis) => KeyedSubtree(
          key: ValueKey('health_content_$currentPetId'),
          child: _HealthRecordContentView(
            healthRecord: healthRecord,
            analysis: analysis,
            logic: logic,
            currentPetId: currentPetId,
          ),
        ),
        loading: () => DailyHealthLoadingState(logic: logic),
        error: (error, stack) => DailyHealthErrorState(
          error: error,
          petId: currentPetId,
          logic: logic,
        ),
      ),
      loading: () => DailyHealthLoadingState(logic: logic),
      error: (error, stack) => DailyHealthErrorState(
        error: error,
        petId: currentPetId,
        logic: logic,
      ),
    );
  }
}

/// 건강 기록 콘텐츠 뷰 (내부 위젯)
class _HealthRecordContentView extends ConsumerWidget {
  final DailyHealthRecord? healthRecord;
  final HealthAnalysis? analysis;
  final DailyHealthLogic logic;
  final String currentPetId;

  const _HealthRecordContentView({
    required this.healthRecord,
    required this.analysis,
    required this.logic,
    required this.currentPetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasHospital = ref.watch(hasRegisteredHospitalProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 병원 미등록 시 배너 표시
          if (!hasHospital) ...[
            HospitalLinkBanner(
              onTap: () => context.push('/home/calendar'),
              onDismiss: null,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          DailyHealthDateHeaderSection(logic: logic),
          const SizedBox(height: AppSpacing.md),
          DailyHealthActionButtons(logic: logic),
          const SizedBox(height: AppSpacing.lg),
          if (healthRecord != null) ...[
            DailyHealthRecordSection(
              healthRecord: healthRecord!,
              currentPetId: currentPetId,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (analysis != null) ...[
            DailyHealthAIAnalysisSection(analysis: analysis!),
            const SizedBox(height: AppSpacing.lg),
          ],
          DailyHealthQuickActionsGrid(logic: logic),
        ],
      ),
    );
  }
}

/// 펫이 없을 때 건강 화면 (등록 안내 + 기본 기능들)
class _NoPetHealthView extends ConsumerWidget {
  final DailyHealthLogic logic;

  const _NoPetHealthView({required this.logic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasHospital = ref.watch(hasRegisteredHospitalProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 펫 등록 안내 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.pets, size: 48, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'ペットを登録して健康管理を始めましょう',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'ペットの健康記録、予防接種スケジュール、\n病院予約などを管理できます',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => logic.navigateToPetRegistration(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                      ),
                    ),
                    child: const Text('ペット登録'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 병원 미등록 시 배너 표시
          if (!hasHospital) ...[
            HospitalLinkBanner(
              onTap: () => context.push('/home/calendar'),
              onDismiss: null,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 날짜 헤더
          DailyHealthDateHeaderSection(logic: logic),
          const SizedBox(height: AppSpacing.lg),

          // 기본 액션 그리드 (펫 없이도 접근 가능한 기능들)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '利用可能な機能',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1,
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.local_hospital,
                        title: '病院検索',
                        onTap: () => context.push('/home/calendar'),
                      ),
                      _buildQuickActionCard(
                        icon: Icons.schedule,
                        title: '予約管理',
                        onTap: () =>
                            context.push('/home/daily/hospital-management'),
                      ),
                      _buildQuickActionCard(
                        icon: Icons.info_outline,
                        title: '健康情報',
                        onTap: () => context.push('/home/ai'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          color: AppColors.backgroundGray,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
