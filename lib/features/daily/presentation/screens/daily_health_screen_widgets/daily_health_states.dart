import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/loading_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily Health 화면 빈 상태
class DailyHealthEmptyState extends StatelessWidget {
  final DailyHealthLogic logic;

  const DailyHealthEmptyState({
    super.key,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.pets,
      title: logic.emptyStateTitle,
      subtitle: logic.emptyStateSubtitle,
      actionText: logic.emptyStateActionText,
      onActionPressed: () => logic.navigateToPetRegistration(context),
    );
  }
}

/// Daily Health 화면 로딩 상태
class DailyHealthLoadingState extends StatelessWidget {
  final DailyHealthLogic logic;

  const DailyHealthLoadingState({
    super.key,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingStateWidget(message: logic.loadingMessage);
  }
}

/// Daily Health 화면 에러 상태
class DailyHealthErrorState extends ConsumerWidget {
  final Object error;
  final String petId;
  final DailyHealthLogic logic;

  const DailyHealthErrorState({
    super.key,
    required this.error,
    required this.petId,
    required this.logic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorStateWidget(
      error: error,
      onRetry: () {
        ref.invalidate(dailyHealthRecordProvider(petId));
        ref.invalidate(dailyHealthAnalysisProvider(petId));
      },
    );
  }
}

