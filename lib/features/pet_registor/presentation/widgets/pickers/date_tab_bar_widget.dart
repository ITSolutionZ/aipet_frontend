import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class DateTabBarWidget extends StatelessWidget {
  final TabController tabController;

  const DateTabBarWidget({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppColors.pointBrown,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.pointGray,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.cake, size: 14), SizedBox(width: 4), Text('誕生日')],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.home, size: 14), SizedBox(width: 4), Text('家に来た日')],
            ),
          ),
        ],
      ),
    );
  }
}
