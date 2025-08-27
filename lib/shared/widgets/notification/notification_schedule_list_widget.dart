import 'package:flutter/material.dart';

import '../../../features/notification/domain/entities/notification_model.dart';
import '../../../features/notification/domain/entities/notification_schedule.dart';
import '../../design/color.dart';
import '../../design/font.dart';
import '../../design/radius.dart';
import '../../design/spacing.dart';
import '../../mock_data/mock_data_service.dart';

/// 알림 스케줄 목록 위젯
class NotificationScheduleListWidget extends StatefulWidget {
  final List<NotificationSchedule> schedules;
  final Function(NotificationSchedule)? onScheduleTap;
  final Function(String)? onScheduleToggle;
  final Function(String)? onScheduleDelete;
  final bool isLoading;
  final String? emptyMessage;

  const NotificationScheduleListWidget({
    super.key,
    required this.schedules,
    this.onScheduleTap,
    this.onScheduleToggle,
    this.onScheduleDelete,
    this.isLoading = false,
    this.emptyMessage,
  });

  @override
  State<NotificationScheduleListWidget> createState() =>
      _NotificationScheduleListWidgetState();
}

class _NotificationScheduleListWidgetState
    extends State<NotificationScheduleListWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pointBlue),
      );
    }

    if (widget.schedules.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: widget.schedules.length,
      itemBuilder: (context, index) {
        final schedule = widget.schedules[index];
        return _buildScheduleItem(schedule);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule, size: 64, color: AppColors.pointGray),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.emptyMessage ?? '예약된 알림이 없습니다',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '새로운 알림 스케줄을 추가해보세요',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(NotificationSchedule schedule) {
    return Dismissible(
      key: Key(schedule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        widget.onScheduleDelete?.call(schedule.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onScheduleTap?.call(schedule),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleIcon(schedule),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScheduleHeader(schedule),
                        const SizedBox(height: AppSpacing.xs),
                        _buildScheduleDetails(schedule),
                        const SizedBox(height: AppSpacing.sm),
                        _buildScheduleStatus(schedule),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildScheduleActions(schedule),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 다음 실행 시간 포맷팅
  String _formatNextTrigger(DateTime? nextTrigger) {
    if (nextTrigger == null) return '설정되지 않음';

    final now = DateTime.now();
    final difference = nextTrigger.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else {
      return '곧';
    }
  }

  /// 요일 텍스트 생성
  String _getWeekDaysText(List<int> weekDays) {
    final dayNames = MockDataService.getMockDayNames();
    final selectedDays = weekDays.map((day) => dayNames[day - 1]).toList();
    return selectedDays.join(', ');
  }

  /// 스케줄 타입별 색상 반환
  Color _getScheduleTypeColor(ScheduleType type) {
    switch (type) {
      case ScheduleType.once:
        return AppColors.pointBlue;
      case ScheduleType.daily:
        return AppColors.pointGreen;
      case ScheduleType.weekly:
        return AppColors.pointOlive;
      case ScheduleType.monthly:
        return AppColors.pointPink;
      case ScheduleType.custom:
        return AppColors.pointBrown;
    }
  }

  /// 스케줄 타입별 아이콘 반환
  Widget _buildScheduleIcon(NotificationSchedule schedule) {
    switch (schedule.type) {
      case NotificationType.general:
        return const Icon(Icons.notifications, color: AppColors.pointBlue);
      case NotificationType.reservation:
        return const Icon(Icons.calendar_today, color: AppColors.pointGreen);
      case NotificationType.feeding:
        return const Icon(Icons.restaurant, color: AppColors.pointOlive);
      case NotificationType.medication:
        return const Icon(Icons.medication, color: AppColors.pointPink);
      case NotificationType.health:
        return const Icon(Icons.favorite, color: AppColors.pointPink);
      case NotificationType.walk:
        return const Icon(Icons.directions_walk, color: AppColors.pointBrown);
      case NotificationType.system:
        return const Icon(Icons.settings, color: AppColors.pointGray);
      case NotificationType.reminder:
        return const Icon(Icons.alarm, color: AppColors.pointPink);
      case NotificationType.food:
        return const Icon(Icons.fastfood, color: AppColors.pointOlive);
      case NotificationType.appointment:
        return const Icon(Icons.event, color: AppColors.pointBlue);
      case NotificationType.medical:
        return const Icon(Icons.medical_services, color: AppColors.pointPink);
      case NotificationType.grooming:
        return const Icon(Icons.content_cut, color: AppColors.pointBrown);
      case NotificationType.emergency:
        return const Icon(Icons.warning, color: AppColors.pointPink);
    }
  }

  Widget _buildScheduleHeader(NotificationSchedule schedule) {
    return Row(
      children: [
        Expanded(
          child: Text(
            schedule.title,
            style: AppFonts.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _getScheduleTypeColor(
              schedule.scheduleType,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            _getScheduleTypeText(schedule.scheduleType),
            style: AppFonts.caption.copyWith(
              color: _getScheduleTypeColor(schedule.scheduleType),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleDetails(NotificationSchedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          schedule.description,
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.pointDark.withValues(alpha: 0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: AppColors.pointGray),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${schedule.time}',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (schedule.scheduleType == ScheduleType.weekly &&
                schedule.weekDays != null) ...[
              const Icon(
                Icons.calendar_view_week,
                size: 16,
                color: AppColors.pointGray,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _getWeekDaysText(schedule.weekDays!),
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleStatus(NotificationSchedule schedule) {
    final nextTrigger = schedule.calculateNextExecutionTime();
    final isEnabled = schedule.isActive;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.pointGreen : AppColors.pointGray,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          isEnabled ? '활성' : '비활성',
          style: AppFonts.caption.copyWith(
            color: isEnabled ? AppColors.pointGreen : AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '다음: ${_formatNextTrigger(nextTrigger)}',
            style: AppFonts.caption.copyWith(color: AppColors.pointGray),
          ),
        ],
      ],
    );
  }

  Widget _buildScheduleActions(NotificationSchedule schedule) {
    return Column(
      children: [
        Switch(
          value: schedule.isActive,
          onChanged: (value) {
            widget.onScheduleToggle?.call(schedule.id);
          },
          activeColor: AppColors.pointBlue,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Icon(Icons.chevron_right, color: AppColors.pointGray, size: 20),
      ],
    );
  }

  String _getScheduleTypeText(ScheduleType type) {
    switch (type) {
      case ScheduleType.once:
        return '한 번';
      case ScheduleType.daily:
        return '매일';
      case ScheduleType.weekly:
        return '매주';
      case ScheduleType.monthly:
        return '매월';
      case ScheduleType.custom:
        return '사용자';
    }
  }
}
