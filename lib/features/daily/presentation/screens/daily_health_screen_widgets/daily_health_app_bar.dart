import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_screen_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/app_bar_pet_selector_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily Health 화면 앱바
class DailyHealthAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final DailyHealthLogic logic;

  const DailyHealthAppBar({super.key, required this.logic});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenData = ref.watch(dailyHealthScreenControllerProvider);
    final controller = ref.read(dailyHealthScreenControllerProvider.notifier);

    return AppBar(
      backgroundColor: AppColors.pureWhite,
      foregroundColor: AppColors.pointBrown,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: AppBarPetSelectorWidget(
        selectedPetId: screenData.selectedPetId,
        onPetSelected: controller.updateSelectedPet,
      ),
      leadingWidth: 144, // 3개 아이템 너비 (48px × 3)
      actions: [
        IconButton(
          onPressed: () => logic.navigateToCalendarScreen(context),
          icon: const Icon(Icons.calendar_today, color: AppColors.pointBrown),
          tooltip: 'カレンダー',
        ),
      ],
    );
  }
}
