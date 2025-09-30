import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 홈 화면 헤더 위젯
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('おかえりなさい！', style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold)),
            Text(
              '今日も一緒に頑張りましょう',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
}
