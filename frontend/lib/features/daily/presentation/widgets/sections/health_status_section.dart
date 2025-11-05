import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/utils/health_status_utils.dart';
import 'package:aipet_frontend/shared/widgets/forms/radio_group_field.dart';
import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// 헬스 상태 선택 섹션 위젯
class HealthStatusSection extends StatelessWidget {
  final HealthStatus selectedStatus;
  final ValueChanged<HealthStatus?> onChanged;

  const HealthStatusSection({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final healthStatusOptions = HealthStatus.values
        .map(
          (status) => RadioOption<HealthStatus>(
            value: status,
            label: HealthStatusUtils.getHealthStatusText(status),
            leading: Icon(
              HealthStatusUtils.getHealthStatusIcon(status),
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        )
        .toList();

    return SectionCardContainer(
      title: '全体的な健康状態',
      child: RadioGroupField<HealthStatus>(
        label: '',
        value: selectedStatus,
        options: healthStatusOptions,
        onChanged: onChanged,
        direction: Axis.vertical,
      ),
    );
  }
}
