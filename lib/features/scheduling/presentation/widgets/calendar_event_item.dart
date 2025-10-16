import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/calendar_event_entity.dart';

class CalendarEventItem extends StatelessWidget {
  final CalendarEventEntity event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CalendarEventItem({
    super.key,
    required this.event,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 이벤트 타입 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getEventColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Center(
                  child: Text(
                    event.type.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 이벤트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppFonts.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.type.displayName,
                      style: AppFonts.bodySmall.copyWith(
                        color: _getEventColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (event.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // 시간 정보とアラーム
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 알람 카테고리 표시
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getAlarmCategoryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getAlarmCategoryColor().withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      event.type.alarmCategory.displayName,
                      style: AppFonts.bodySmall.copyWith(
                        color: _getAlarmCategoryColor(),
                        fontWeight: FontWeight.w500,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // アラームアイコン
                  if (event.hasAlarm) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alarm,
                          size: 14,
                          color: AppColors.pointBrown,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.alarmSettings.length}',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointBrown,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  // 時間表示
                  Text(
                    DateFormat('HH:mm', 'ja_JP').format(event.startTime),
                    style: AppFonts.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!event.isAllDay!) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm', 'ja_JP').format(event.endTime),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ],
              ),

              // 액션 버튼
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('편집'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.pointRed),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: AppColors.pointRed)),
                      ],
                    ),
                  ),
                ],
                child: const Icon(Icons.more_vert, color: AppColors.pointGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventColor() {
    switch (event.type) {
      case CalendarEventType.feeding:
        return AppColors.pointGreen;
      case CalendarEventType.medication:
        return AppColors.pointPink;
      case CalendarEventType.walking:
        return AppColors.pointBrown;
      case CalendarEventType.exercise:
        return AppColors.pointOrange;
      case CalendarEventType.system:
        return AppColors.pointBlue;
      case CalendarEventType.watering:
        return AppColors.pointBlue;
      case CalendarEventType.grooming:
        return AppColors.tonePeach;
      case CalendarEventType.veterinary:
        return AppColors.pointRed;
      case CalendarEventType.training:
        return AppColors.pointBlue;
      case CalendarEventType.other:
        return AppColors.pointGray;
    }
  }

  /// 알람 카테고리별 색상 반환
  Color _getAlarmCategoryColor() {
    switch (event.type.alarmCategory) {
      case AlarmCategory.meal:
        return AppColors.pointGreen;
      case AlarmCategory.walk:
        return AppColors.pointBrown;
      case AlarmCategory.system:
        return AppColors.pointBlue;
    }
  }
}
