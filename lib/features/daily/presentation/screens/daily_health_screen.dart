import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_screen_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Daily health specific widgets
import '../widgets/daily_health_common_widgets.dart' as daily_widgets;

/// 리팩토링된 Daily Health 화면 - UI와 로직 분리
class DailyHealthScreen extends ConsumerWidget {
  const DailyHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(dailyHealthScreenControllerProvider);
    final controller = ref.read(dailyHealthScreenControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: _buildAppBar(controller.logic),
      body: Column(
        children: [
          _buildPetSelector(screenData, controller),
          Expanded(
            child: screenData.selectedPetId != null
                ? _buildHealthContent(screenData.selectedPetId!, controller.logic)
                : _buildEmptyState(controller.logic),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(DailyHealthLogic logic) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        logic.appBarTitle,
        style: AppFonts.titleMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Builder(
          builder: (context) => IconButton(
            onPressed: () => logic.navigateToHistoryScreen(context),
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: '健康記録ヒストリー',
          ),
        ),
      ],
    );
  }

  Widget _buildPetSelector(
    DailyHealthScreenData screenData,
    DailyHealthScreenController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: PetSelectorWidget(
        selectedPetId: screenData.selectedPetId,
        onPetSelected: controller.updateSelectedPet,
      ),
    );
  }

  Widget _buildHealthContent(String petId, DailyHealthLogic logic) {
    return Consumer(
      builder: (context, ref, child) {
        final healthRecordAsync = ref.watch(dailyHealthRecordProvider(petId));
        final healthAnalysisAsync = ref.watch(dailyHealthAnalysisProvider(petId));

        return healthRecordAsync.when(
          data: (healthRecord) => healthAnalysisAsync.when(
            data: (analysis) => _buildHealthRecordContent(healthRecord, analysis, logic),
            loading: () => _buildLoadingState(logic),
            error: (error, stack) => _buildErrorState(error, petId, logic),
          ),
          loading: () => _buildLoadingState(logic),
          error: (error, stack) => _buildErrorState(error, petId, logic),
        );
      },
    );
  }

  Widget _buildHealthRecordContent(
    DailyHealthRecord? healthRecord,
    HealthAnalysis? analysis,
    DailyHealthLogic logic,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(logic),
          const SizedBox(height: AppSpacing.md),
          _buildActionButtons(logic),
          const SizedBox(height: AppSpacing.lg),
          if (healthRecord != null) ...[
            _buildHealthRecordSection(healthRecord),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (analysis != null) ...[
            _buildAIAnalysisSection(analysis),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildQuickActionsSection(logic),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DailyHealthLogic logic) {
    final today = DateTime.now();
    final formattedDate = logic.formatDate(today);
    final weekday = logic.getWeekdayName(today.weekday);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: AppFonts.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            weekday,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DailyHealthLogic logic) {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => logic.navigateToHealthInput(context, null),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                '記録を追加',
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => logic.navigateToHospitalSearch(context),
              icon: const Icon(Icons.local_hospital, color: AppColors.primary),
              label: Text(
                '病院を探す',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecordSection(DailyHealthRecord healthRecord) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const daily_widgets.SectionHeaderWidget(
          title: '今日の健康状態',
          subtitle: '最新の記録',
        ),
        const SizedBox(height: AppSpacing.md),
        TemperatureDisplayCard(healthRecord: healthRecord),
        const SizedBox(height: AppSpacing.md),
        HealthStatusCard(healthRecord: healthRecord),
        const SizedBox(height: AppSpacing.md),
        SymptomsCard(healthRecord: healthRecord),
      ],
    );
  }

  Widget _buildAIAnalysisSection(HealthAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const daily_widgets.SectionHeaderWidget(
          title: 'AI健康分析',
          subtitle: '専門的なアドバイス',
        ),
        const SizedBox(height: AppSpacing.md),
        AIAnalysisCard(analysis: analysis),
      ],
    );
  }

  Widget _buildQuickActionsSection(DailyHealthLogic logic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const daily_widgets.SectionHeaderWidget(
          title: 'クイックアクション',
          subtitle: 'よく使う機能',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildQuickActionGrid(logic),
      ],
    );
  }

  Widget _buildQuickActionGrid(DailyHealthLogic logic) {
    return Builder(
      builder: (context) {
        final quickActions = logic.getQuickActions(
          onTemperatureRecord: () => logic.navigateToHealthInput(context, null),
          onSymptomRecord: () => logic.navigateToHealthInput(context, null),
          onMedicationRecord: () => logic.navigateToHealthInput(context, null),
          onHospitalBooking: () => logic.navigateToHospitalSearch(context),
        );

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return _buildQuickActionCard(
              title: action.title,
              icon: action.icon,
              color: action.color,
              onTap: action.onTap,
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
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
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(DailyHealthLogic logic) {
    return Builder(
      builder: (context) => EmptyStateWidget(
        icon: Icons.pets,
        title: logic.emptyStateTitle,
        subtitle: logic.emptyStateSubtitle,
        actionText: logic.emptyStateActionText,
        onActionPressed: () => logic.navigateToPetRegistration(context),
      ),
    );
  }

  Widget _buildLoadingState(DailyHealthLogic logic) {
    return LoadingStateWidget(message: logic.loadingMessage);
  }

  Widget _buildErrorState(Object error, String petId, DailyHealthLogic logic) {
    return Consumer(
      builder: (context, ref, child) => ErrorStateWidget(
        error: error,
        onRetry: () {
          ref.invalidate(dailyHealthRecordProvider(petId));
          ref.invalidate(dailyHealthAnalysisProvider(petId));
        },
      ),
    );
  }

}
