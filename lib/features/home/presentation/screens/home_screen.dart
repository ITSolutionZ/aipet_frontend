import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/presentation/controllers/home_dashboard_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 임시 프로바이더 (실제 구현에서는 별도 파일로 분리)
final homeDashboardControllerProvider = FutureProvider<HomeDashboardEntity>((
  ref,
) async {
  final controller = HomeDashboardController(ref as WidgetRef);
  final result = await controller.initializeHome();
  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull);
  }
});

/// 🏠 홈 스크린
///
/// 앱의 메인 홈 화면으로 대시보드 정보를 표시합니다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(homeDashboardControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: SafeArea(
        child: dashboardState.when(
          data: (dashboard) => _buildDashboard(context, ref, dashboard),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorView(context, ref, error),
        ),
      ),
    );
  }

  /// 대시보드 UI 빌드
  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    HomeDashboardEntity dashboard,
  ) {
    if (!dashboard.hasPets) {
      return _buildEmptyPetState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(homeDashboardControllerProvider.future),
      child: SingleChildScrollView(
        padding: const const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(context, dashboard),
            const SizedBox(height: AppSpacing.lg),

            // 날씨 정보
            _buildWeatherCard(dashboard.weather),
            const SizedBox(height: AppSpacing.lg),

            // 펫 요약 카드들
            _buildPetSummaryGrid(dashboard.petProfiles),
            const SizedBox(height: AppSpacing.lg),

            // 오늘의 예약 (있을 경우)
            if (dashboard.hasTodayAppointments) ...[
              _buildTodayAppointments(dashboard.upcomingAppointments),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 산책 요약
            _buildWalkSummary(
              context,
              dashboard.walkSummary.todayDuration.inMinutes,
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 섹션
  Widget _buildHeader(BuildContext context, HomeDashboardEntity dashboard) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'おかえりなさい！',
              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '今日も一緒に頑張りましょう',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
      ],
    );
  }

  /// 펫이 없는 상태 UI
  Widget _buildEmptyPetState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'まだペットが登録されていません',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '最初のペットを登録して、\nAIPetを始めましょう！',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.push('/pet-type-selection'),
              child: const Text('ペット登録'),
            ),
          ],
        ),
      ),
    );
  }

  /// 날씨 카드
  Widget _buildWeatherCard(WeatherEntity weather) {
    return Container(
      padding: const const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(weather.iconCode, style: const TextStyle(fontSize: 40)),
          const const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather.temperature.round()}°C',
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  weather.location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (weather.isGoodForWalking)
            Container(
              padding: const const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.pointGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Text(
                '散歩日和',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.pointGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 펫 요약 그리드
  Widget _buildPetSummaryGrid(List<PetSummaryEntity> pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ペット一覧',
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) => _buildPetCard(pets[index]),
        ),
      ],
    );
  }

  /// 펫 카드
  Widget _buildPetCard(PetSummaryEntity pet) {
    return Container(
      padding: const const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: pet.profileImageUrl != null
                ? NetworkImage(pet.profileImageUrl!)
                : null,
            child: pet.profileImageUrl == null
                ? const Icon(Icons.pets, color: AppColors.primary, size: 30)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            pet.name,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${pet.age}歳',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘의 예약 섹션
  Widget _buildTodayAppointments(List<AppointmentSummary> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日の予約',
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        ...appointments.map(
          (appointment) => _buildAppointmentCard(appointment),
        ),
      ],
    );
  }

  /// 예약 카드
  Widget _buildAppointmentCard(AppointmentSummary appointment) {
    return Container(
      margin: const const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: AppColors.primary),
          const const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  appointment.petName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${appointment.scheduledTime.hour}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 산책 요약 섹션
  Widget _buildWalkSummary(BuildContext context, int totalMinutes) {
    return Container(
      padding: const const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: AppColors.primary, size: 32),
          const const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日の散歩',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$totalMinutes分',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => GoRouter.of(context).push('/walk'),
            child: const Text('詳細'),
          ),
        ],
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'データの読み込みに失敗しました',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => ref.invalidate(homeDashboardControllerProvider),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
