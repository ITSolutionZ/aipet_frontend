import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/presentation/extensions/notification_type_ui_extension.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알림 필터 칩 위젯
class NotificationFilterChipsComponent extends StatelessWidget {
  final NotificationType? selectedFilter;
  final ValueChanged<NotificationType?> onFilterChanged;

  const NotificationFilterChipsComponent({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 주요 알림 타입만 표시 (기존 호환성 타입 제외)
    final filterTypes = [
      NotificationType.general,
      NotificationType.feeding,
      NotificationType.walk,
      NotificationType.health,
      NotificationType.reservation,
      NotificationType.system,
    ];

    return Container(
      margin: const const const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const const const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        children: [
          // 전체 필터
          Padding(
            padding: const const const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: const Text('全て'),
              selected: selectedFilter == null,
              showCheckmark: false,
              onSelected: (selected) {
                onFilterChanged(selected ? null : selectedFilter);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.pointBrown.withValues(alpha: 0.15),
              side: BorderSide(
                color: selectedFilter == null
                    ? AppColors.pointBrown
                    : AppColors.pointGray.withValues(alpha: 0.3),
                width: selectedFilter == null ? 1.5 : 1,
              ),
              labelStyle: TextStyle(
                color: selectedFilter == null
                    ? AppColors.pointBrown
                    : AppColors.pointGray,
                fontWeight: selectedFilter == null
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 14,
              ),
              padding: const const const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
          ),
          // 타입별 필터
          ...filterTypes.map(
            (type) => Padding(
              padding: const const const EdgeInsets.only(right: AppSpacing.sm),
              child: FilterChip(
                avatar: Icon(
                  type.icon,
                  size: 16,
                  color: selectedFilter == type
                      ? type.color
                      : AppColors.pointGray,
                ),
                label: Text(type.name),
                selected: selectedFilter == type,
                showCheckmark: false,
                onSelected: (selected) {
                  onFilterChanged(selected ? type : null);
                },
                backgroundColor: Colors.white,
                selectedColor: type.color.withValues(alpha: 0.15),
                side: BorderSide(
                  color: selectedFilter == type
                      ? type.color
                      : AppColors.pointGray.withValues(alpha: 0.3),
                  width: selectedFilter == type ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  color: selectedFilter == type
                      ? type.color
                      : AppColors.pointGray,
                  fontWeight: selectedFilter == type
                      ? FontWeight.w600
                      : FontWeight.normal,
                  fontSize: 14,
                ),
                padding: const const const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
