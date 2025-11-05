import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../scheduling/data/services/feeding_local_storage_service.dart';


/// 오늘의 예약 화면
class TodayAppointmentsScreen extends ConsumerStatefulWidget {
  const TodayAppointmentsScreen({super.key});

  @override
  ConsumerState<TodayAppointmentsScreen> createState() =>
      _TodayAppointmentsScreenState();
}

class _TodayAppointmentsScreenState
    extends ConsumerState<TodayAppointmentsScreen> {
  List<Map<String, dynamic>> _todayAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appointments = await FeedingLocalStorageService.getTodayMeals();
    setState(() {
      _todayAppointments = appointments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todayAppointments = _todayAppointments;

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
                    return _buildMealCard(appointment, context);
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

  Widget _buildMealCard(Map<String, dynamic> meal, BuildContext context) {
    final now = DateTime.now();
    final scheduledTime = meal['scheduledTime'] as DateTime;
    final isCompleted = meal['isCompleted'] as bool;
    final isPast = scheduledTime.isBefore(now);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isCompleted || isPast) {
      statusColor = AppColors.pointGreen;
      statusText = '完了';
      statusIcon = Icons.check_circle;
    } else if (scheduledTime.difference(now).inMinutes <= 30) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.pointBrown.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.pointBrown,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateTimeUtils.formatTime(scheduledTime),
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                      Text(
                        meal['scheduleName'] as String,
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
          ],
        ),
      ),
    );
  }
}
