import 'package:aipet_frontend/home/data/providers/home_providers.dart';
import 'package:aipet_frontend/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/scheduling/scheduling_mock_service.dart'
    as SchedulingMock;
import 'package:aipet_frontend/shared/widgets/soft_gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 오늘의 예약 화면
class TodayAppointmentsScreen extends ConsumerWidget {
  const TodayAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final todayAppointments =
        SchedulingMock.SchedulingMockService.getMockTodayMealsForSchedule();

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: '今日の予約'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: const Icon(
                          Icons.today,
                          color: AppColors.pointBrown,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '今日の予約',
                              style: AppFonts.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.pointDark,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${DateTime.now().month}月${DateTime.now().day}日',
                              style: AppFonts.bodyMedium.copyWith(
                                color: AppColors.pointGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.large),
                        ),
                        child: Text(
                          '${todayAppointments.length}件',
                          style: AppFonts.titleMedium.copyWith(
                            color: AppColors.pointBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 예약 목록
            if (todayAppointments.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: todayAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = todayAppointments[index];
                    return _buildAppointmentCard(
                      appointment as AppointmentSummary,
                      context,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.pointGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.event_available,
                size: 40,
                color: AppColors.pointGray,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '今日の予約はありません',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ゆっくりペットと過ごす日ですね',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    AppointmentSummary appointment,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final isPast = appointment.scheduledTime.isBefore(now);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isPast) {
      statusColor = AppColors.pointGray;
      statusText = '完了';
      statusIcon = Icons.check_circle;
    } else if (appointment.scheduledTime.difference(now).inMinutes <= 30) {
      statusColor = AppColors.pointPink;
      statusText = '間もなく';
      statusIcon = Icons.access_time;
    } else {
      statusColor = AppColors.pointBlue;
      statusText = '予定';
      statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 행: 시간과 상태
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      appointment.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(
                    _getTypeIcon(appointment.type),
                    color: _getTypeColor(appointment.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appointment.scheduledTime.hour.toString().padLeft(2, '0')}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')}',
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                      Text(
                        appointment.type,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        statusText,
                        style: AppFonts.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 예약 제목과 펫 이름
            Text(
              appointment.title,
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.pets, size: 16, color: AppColors.pointGray),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  appointment.petName,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case '健康診断':
      case '医療':
        return AppColors.pointGreen;
      case 'グルーミング':
        return AppColors.pointBrown;
      case '訓練':
        return AppColors.pointBlue;
      default:
        return AppColors.pointGray;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '健康診断':
      case '医療':
        return Icons.medical_services;
      case 'グルーミング':
        return Icons.content_cut;
      case '訓練':
        return Icons.school;
      default:
        return Icons.event;
    }
  }
}
