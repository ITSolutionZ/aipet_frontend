import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../../domain/domain.dart';

/// 알림 상세 메타데이터 컴포넌트
class NotificationDetailMetadataComponent extends StatelessWidget {
  final NotificationModel notification;
  final String Function(dynamic) formatCurrency;

  const NotificationDetailMetadataComponent({
    super.key,
    required this.notification,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (notification.metadata == null || notification.metadata!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '詳細情報',
                style: AppFonts.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._buildMetadataWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMetadataWidgets() {
    final metadata = notification.metadata!;
    final widgets = <Widget>[];

    // 알림 유형별 메타데이터 표시
    switch (notification.type) {
      case NotificationType.feeding:
        if (metadata['amount'] != null) {
          widgets.add(_buildMetadataRow('食事量', '${metadata['amount']}g'));
        }
        if (metadata['scheduledTime'] != null) {
          widgets.add(_buildMetadataRow('予定時間', metadata['scheduledTime']));
        }
        if (metadata['mealTime'] != null) {
          final mealTimeText = metadata['mealTime'] == 'morning'
              ? '朝'
              : metadata['mealTime'] == 'lunch'
              ? '昼'
              : '夜';
          widgets.add(_buildMetadataRow('食事時間', mealTimeText));
        }
        break;

      case NotificationType.walk:
        if (metadata['recommendedDuration'] != null) {
          widgets.add(
            _buildMetadataRow('推奨時間', '${metadata['recommendedDuration']}分'),
          );
        }
        if (metadata['weather'] != null) {
          widgets.add(_buildMetadataRow('天気', metadata['weather']));
        }
        if (metadata['temperature'] != null) {
          widgets.add(_buildMetadataRow('気温', '${metadata['temperature']}°C'));
        }
        break;

      case NotificationType.health:
      case NotificationType.medical:
        if (metadata['vaccineType'] != null) {
          widgets.add(_buildMetadataRow('ワクチン種類', metadata['vaccineType']));
        }
        if (metadata['appointmentDate'] != null &&
            metadata['appointmentTime'] != null) {
          widgets.add(
            _buildMetadataRow(
              '予約日時',
              '${metadata['appointmentDate']} ${metadata['appointmentTime']}',
            ),
          );
        }
        if (metadata['hospitalName'] != null) {
          widgets.add(_buildMetadataRow('病院名', metadata['hospitalName']));
        }
        break;

      case NotificationType.reservation:
      case NotificationType.grooming:
        if (metadata['facilityName'] != null) {
          widgets.add(_buildMetadataRow('施設名', metadata['facilityName']));
        }
        if (metadata['services'] != null) {
          final services = (metadata['services'] as List).join(', ');
          widgets.add(_buildMetadataRow('サービス', services));
        }
        if (metadata['price'] != null) {
          widgets.add(
            _buildMetadataRow('価格', '${formatCurrency(metadata['price'])}円'),
          );
        }
        break;

      case NotificationType.system:
      case NotificationType.emergency:
        if (metadata['averageIntake'] != null) {
          widgets.add(
            _buildMetadataRow('平均摂取率', '${metadata['averageIntake']}%'),
          );
        }
        if (metadata['daysObserved'] != null) {
          widgets.add(
            _buildMetadataRow('観察期間', '${metadata['daysObserved']}日'),
          );
        }
        break;

      default:
        break;
    }

    return widgets;
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
