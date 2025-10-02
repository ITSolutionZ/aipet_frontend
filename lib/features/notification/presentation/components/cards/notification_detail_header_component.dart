import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/presentation/extensions/notification_type_ui_extension.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알림 상세 헤더 컴포넌트
class NotificationDetailHeaderComponent extends StatelessWidget {
  final NotificationModel notification;
  final String Function(DateTime) formatDateTime;

  const NotificationDetailHeaderComponent({
    super.key,
    required this.notification,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타입 및 시간
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: notification.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: Icon(notification.type.icon, color: notification.type.color, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.type.name,
                          style: AppFonts.bodyMedium.copyWith(
                            color: notification.type.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formatDateTime(notification.createdAt),
                          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                        ),
                      ],
                    ),
                  ),
                  if (notification.petName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pointBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: Text(
                        notification.petName!,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 제목
              Text(
                notification.title,
                style: AppFonts.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 메시지
              Text(
                notification.body,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
