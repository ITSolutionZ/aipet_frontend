import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';

/// 정보 카드 컴포넌트 (범용)
class InfoCardComponent extends StatelessWidget {
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const InfoCardComponent({
    super.key,
    this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          onTap: () {
            context.push(RouteConstants.pushNotificationRoute);
          },
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pointBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.pointBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    '通知設定を行い、役立つ通知を\n受け取ってください。',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.pointDark,
                      height: 1.4,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.pointGray,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
