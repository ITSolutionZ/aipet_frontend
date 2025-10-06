import 'dart:async';

import 'package:aipet_frontend/features/daily/data/providers/health_report_provider.dart';
import 'package:aipet_frontend/features/daily/data/providers/hospital_registration_provider.dart';
import 'package:aipet_frontend/features/daily/data/providers/vaccine_provider.dart';
import 'package:aipet_frontend/features/daily/data/providers/weekly_task_provider.dart';
import 'package:aipet_frontend/features/daily/data/services/health_data_collection_service.dart';
import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/domain/entities/health_analysis.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_screen_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/daily_health_widgets.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
      body: screenData.selectedPetId != null
          ? _buildHealthContent(screenData.selectedPetId!, controller.logic)
          : _buildEmptyState(controller.logic),
    );
  }

  PreferredSizeWidget _buildAppBar(DailyHealthLogic logic) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Consumer(
        builder: (context, ref, child) {
          final screenData = ref.watch(dailyHealthScreenControllerProvider);
          final controller = ref.read(
            dailyHealthScreenControllerProvider.notifier,
          );

          return AppBarPetSelectorWidget(
            selectedPetId: screenData.selectedPetId,
            onPetSelected: controller.updateSelectedPet,
          );
        },
      ),
      leadingWidth: 144, // 3개 아이템 너비 (48px × 3)
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

  Widget _buildHealthContent(String petId, DailyHealthLogic logic) {
    return Consumer(
      builder: (context, ref, child) {
        // 선택된 펫 ID를 watch하여 변경 시 자동으로 새로고침
        final screenData = ref.watch(dailyHealthScreenControllerProvider);

        // screenData.selectedPetId가 null이면 파라미터 petId 사용
        final currentPetId = screenData.selectedPetId ?? petId;

        debugPrint(
          '🔍 _buildHealthContent - currentPetId: $currentPetId, screenData.selectedPetId: ${screenData.selectedPetId}',
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
              child: _buildHealthRecordContent(
                healthRecord,
                analysis,
                logic,
                currentPetId,
              ),
            ),
            loading: () => _buildLoadingState(logic),
            error: (error, stack) =>
                _buildErrorState(error, currentPetId, logic),
          ),
          loading: () => _buildLoadingState(logic),
          error: (error, stack) => _buildErrorState(error, currentPetId, logic),
        );
      },
    );
  }

  Widget _buildHealthRecordContent(
    DailyHealthRecord? healthRecord,
    HealthAnalysis? analysis,
    DailyHealthLogic logic,
    String currentPetId,
  ) {
    return Consumer(
      builder: (context, ref, child) {
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
              _buildDateHeader(logic),
              const SizedBox(height: AppSpacing.md),
              _buildActionButtons(logic),
              const SizedBox(height: AppSpacing.lg),
              if (healthRecord != null) ...[
                _buildHealthRecordSection(healthRecord, currentPetId),
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
      },
    );
  }

  Widget _buildDateHeader(DailyHealthLogic logic) {
    return Consumer(
      builder: (context, ref, child) {
        final today = DateTime.now();
        final formattedDate = logic.formatDate(today);
        final weekday = logic.getWeekdayName(today.weekday);

        // 현재 선택된 펫의 타입과 생일 가져오기
        final screenData = ref.watch(dailyHealthScreenControllerProvider);
        final petsAsync = ref.watch(petProfilesNotifierProvider);

        return petsAsync.when(
          data: (pets) {
            String petType = 'dog'; // 기본값
            int weekOfYear = _getWeekOfYear(today); // 기본값

            if (pets.isNotEmpty && screenData.selectedPetId != null) {
              final selectedPet = pets.firstWhere(
                (pet) => pet.id == screenData.selectedPetId,
                orElse: () => pets.first,
              );
              petType = selectedPet.type;

              // 펫의 생일을 기준으로 주차 계산
              weekOfYear = _getWeeksSinceBirth(selectedPet.birthDate, today);
            }

            return Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedDate,
                          style: AppFonts.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWeeklyTaskRow(ref, petType, weekOfYear),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    weekday,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedDate,
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        height: 20,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  weekday,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          error: (error, stack) => Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedDate,
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildWeeklyTaskRow(ref, 'dog', _getWeekOfYear(today)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  weekday,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyTaskRow(WidgetRef ref, String petType, int weekOfYear) {
    final weeklyTaskAsync = ref.watch(
      weeklyTasksProvider(petType: petType, weekOfYear: weekOfYear),
    );

    return weeklyTaskAsync.when(
      data: (task) {
        // "\n" 문자열을 실제 개행 문자로 변환하고 공백으로 합침
        final normalizedTask = task
            .replaceAll('\\n', ' ')
            .replaceAll('\n', ' ');

        return Row(
          children: [
            Text(
              '$weekOfYear주차 : ',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                normalizedTask,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Text(
            '$weekOfYear주차 : ',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (error, stack) => Text(
        '$weekOfYear주차',
        style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  /// 해당 날짜가 그 해의 몇 번째 주인지 계산
  int _getWeekOfYear(DateTime date) {
    // 해당 연도의 1월 1일
    final firstDayOfYear = DateTime(date.year, 1, 1);

    // 1월 1일부터 현재 날짜까지의 일수
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;

    // 1월 1일의 요일 (월요일=1, 일요일=7)
    final firstDayWeekday = firstDayOfYear.weekday;

    // 첫 주의 일수 계산 (월요일 시작 기준)
    final daysInFirstWeek = 8 - firstDayWeekday;

    // 주차 계산
    if (daysSinceFirstDay < daysInFirstWeek) {
      return 1;
    } else {
      return ((daysSinceFirstDay - daysInFirstWeek) / 7).ceil() + 1;
    }
  }

  /// 펫의 생일부터 현재까지의 주차 계산
  int _getWeeksSinceBirth(DateTime birthDate, DateTime currentDate) {
    // 현재 연도의 생일을 기준으로 계산
    final thisYearBirthday = DateTime(
      currentDate.year,
      birthDate.month,
      birthDate.day,
    );

    // 올해 생일이 아직 지나지 않았다면 작년 생일 기준
    final referenceBirthday = currentDate.isBefore(thisYearBirthday)
        ? DateTime(currentDate.year - 1, birthDate.month, birthDate.day)
        : thisYearBirthday;

    // 생일부터 현재까지의 일수 계산
    final daysSinceBirth = currentDate.difference(referenceBirthday).inDays;

    // 주차 계산 (1주부터 시작)
    return (daysSinceBirth / 7).floor() + 1;
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

  Widget _buildHealthRecordSection(
    DailyHealthRecord healthRecord,
    String currentPetId,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final petsAsync = ref.watch(petProfilesNotifierProvider);

        // 현재 선택된 펫의 몸무게, 타입, 이름 가져오기
        double? currentWeight;
        String petType = 'dog'; // 기본값
        String petName = 'ペット'; // 기본값
        petsAsync.whenData((pets) {
          if (pets.isNotEmpty) {
            final selectedPet = pets.firstWhere(
              (pet) => pet.id == currentPetId,
              orElse: () => pets.first,
            );
            currentWeight = selectedPet.weight;
            petType = selectedPet.type;
            petName = selectedPet.name;
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const daily_widgets.SectionHeaderWidget(
              title: '今日の健康状態',
              subtitle: '最新の記録',
            ),
            const SizedBox(height: AppSpacing.md),
            TemperatureDisplayCard(
              healthRecord: healthRecord,
              petType: petType,
            ),
            const SizedBox(height: AppSpacing.md),
            WeightDisplayCard(weight: currentWeight),
            const SizedBox(height: AppSpacing.md),
            _buildVaccineHistorySection(ref, currentPetId, petName),
            const SizedBox(height: AppSpacing.md),
            HospitalVisitHistoryCard(
              petName: petName,
              hasVisitHistory: false,
              onManageHospital: () => context.push('/home/calendar'),
              onCheckReservation: () {
                // TODO: 예약 현황 화면으로 이동
              },
            ),
            const SizedBox(height: AppSpacing.md),
            HealthStatusCard(healthRecord: healthRecord),
            const SizedBox(height: AppSpacing.md),
            SymptomsCard(healthRecord: healthRecord),
          ],
        );
      },
    );
  }

  Widget _buildAIAnalysisSection(HealthAnalysis analysis) {
    return Consumer(
      builder: (context, ref, child) {
        final screenData = ref.watch(dailyHealthScreenControllerProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const daily_widgets.SectionHeaderWidget(
              title: 'AI健康分析',
              subtitle: '専門的なアドバイス',
            ),
            const SizedBox(height: AppSpacing.md),
            AIAnalysisCard(
              analysis: analysis,
              onDownloadReport: screenData.selectedPetId != null
                  ? (format) => _handleDownloadWithFormat(
                      context,
                      ref,
                      screenData.selectedPetId!,
                      format,
                    )
                  : null,
            ),
          ],
        );
      },
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

  /// 백신 내역 섹션
  Widget _buildVaccineHistorySection(
    WidgetRef ref,
    String petId,
    String petName,
  ) {
    final scheduledAsync = ref.watch(scheduledVaccinesProvider(petId));
    final completedAsync = ref.watch(completedVaccinesProvider(petId));

    return scheduledAsync.when(
      data: (scheduled) => completedAsync.when(
        data: (completed) => VaccineHistoryCard(
          petName: petName,
          scheduledVaccines: scheduled,
          completedVaccines: completed,
          onRegister: () {
            // TODO: 백신 등록 화면으로 이동
          },
        ),
        loading: () => _buildVaccineLoadingCard(petName),
        error: (error, stack) => VaccineHistoryCard(
          petName: petName,
          scheduledVaccines: scheduled,
          completedVaccines: const [],
        ),
      ),
      loading: () => _buildVaccineLoadingCard(petName),
      error: (error, stack) => VaccineHistoryCard(
        petName: petName,
        scheduledVaccines: const [],
        completedVaccines: const [],
      ),
    );
  }

  /// 백신 로딩 카드
  Widget _buildVaccineLoadingCard(String petName) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$petNameのワクチン接種',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// AI 건강 리포트 다운로드 처리
  void _handleDownloadWithFormat(
    BuildContext context,
    WidgetRef ref,
    String petId,
    ReportFormat format,
  ) async {
    bool dialogShown = false;

    try {
      // 로딩 다이얼로그 표시
      if (context.mounted) {
        unawaited(
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => PopScope(
              canPop: false,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _getLoadingMessage(format),
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '30秒ほどお待ちください',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        dialogShown = true;
      }

      // 펫 정보 가져오기
      final petsAsync = await ref.read(petProfilesNotifierProvider.future);
      final pet = petsAsync.firstWhere((p) => p.id == petId);

      // 형식에 따른 파일 생성
      late final String filePath;
      late final String subject;
      late final String mimeType;

      switch (format) {
        case ReportFormat.pdf:
          final pdfFile = await ref
              .read(generateHealthReportPdfProvider(pet).future)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  debugPrint('⏰ PDF generation timeout');
                  throw Exception('レポート生成がタイムアウトしました。もう一度お試しください。');
                },
              );
          filePath = pdfFile.path;
          subject = '${pet.name}の健康レポート(PDF)';
          mimeType = 'application/pdf';
          break;

        case ReportFormat.png:
          final pngFile = await ref
              .read(generateHealthReportPngProvider(pet).future)
              .timeout(
                const Duration(seconds: 45),
                onTimeout: () {
                  debugPrint('⏰ PNG generation timeout');
                  throw Exception('PNG生成がタイムアウトしました。もう一度お試しください。');
                },
              );
          filePath = pngFile.path;
          subject = '${pet.name}の健康レポート(PNG)';
          mimeType = 'image/png';
          break;

        case ReportFormat.json:
          final collectionService = HealthDataCollectionService();
          final healthData = await collectionService.collectMonthlyHealthData(
            pet,
          );
          final jsonFile = await collectionService.saveHealthDataAsJson(
            pet,
            healthData,
          );
          filePath = jsonFile.path;
          subject = '${pet.name}の健康データ(JSON)';
          mimeType = 'application/json';
          break;
      }

      // 공유 다이얼로그 표시
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(filePath, mimeType: mimeType)],
          subject: subject,
          text: _getShareText(format),
        );

        // 성공 메시지
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _getSuccessMessage(format),
                style: AppFonts.bodySmall.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.pointGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ PDF generation error: $e');
      debugPrint('Stack trace: $stackTrace');

      // 에러 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'レポート生成に失敗しました',
              style: AppFonts.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '詳細',
              textColor: Colors.white,
              onPressed: () {
                debugPrint('Error details: $e\n$stackTrace');
                // 에러 상세 정보를 다이얼로그로 표시
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('エラー詳細'),
                    content: SingleChildScrollView(child: Text(e.toString())),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('閉じる'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      // 로딩 다이얼로그 무조건 닫기
      if (dialogShown && context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          debugPrint('⚠️ Failed to close dialog: $e');
        }
      }
    }
  }

  /// 로딩 메시지를 형식에 따라 반환
  String _getLoadingMessage(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'AI健康レポートを生成中...';
      case ReportFormat.png:
        return 'PNG画像を生成中...';
      case ReportFormat.json:
        return 'JSONデータを生成中...';
    }
  }

  /// 공유 텍스트를 형식에 따라 반환
  String _getShareText(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return '1ヶ月間の健康分析レポートです';
      case ReportFormat.png:
        return '健康レポートの画像です';
      case ReportFormat.json:
        return '健康データのJSONファイルです';
    }
  }

  /// 성공 메시지를 형식에 따라 반환
  String _getSuccessMessage(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'PDFレポートを保存しました';
      case ReportFormat.png:
        return 'PNG画像を保存しました';
      case ReportFormat.json:
        return 'JSONデータを保存しました';
    }
  }
}
