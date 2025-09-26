import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/home/presentation/controllers/home_dashboard_controller.dart';
import 'package:aipet_frontend/features/home/presentation/controllers/home_notification_controller.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/pet_profile_card_refactored.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 홈 화면 상태 관리
final homeScreenProvider =
    StateNotifierProvider<HomeScreenController, HomeScreenState>(
      (ref) => HomeScreenController(ref),
    );

class HomeScreenController extends StateNotifier<HomeScreenState> {
  final Ref ref;

  HomeScreenController(this.ref) : super(const HomeScreenState());

  void initialize(WidgetRef widgetRef) {
    final dashboardController = HomeDashboardController(widgetRef);
    final notificationController = HomeNotificationController(widgetRef);
    final scrollController = ScrollController();

    state = state.copyWith(
      dashboardController: dashboardController,
      notificationController: notificationController,
      scrollController: scrollController,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPetsAndRedirect();
      _showInitialNotificationSnackBar();
    });
  }

  Future<void> _checkPetsAndRedirect() async {
    if (state.dashboardController == null) return;

    try {
      final result = await state.dashboardController!.hasPets();
      if (result.isSuccess && result.dataOrNull == true) {
        await _initializeHomeScreen();
      } else {
        await _initializeHomeScreen();
      }
    } catch (error) {
      await _initializeHomeScreen();
    }
  }

  Future<void> _initializeHomeScreen() async {
    if (state.dashboardController == null) return;

    final result = await ErrorHandlingService.handleAsync(
      state.dashboardController!.initializeHome(),
      context: '홈 화면 초기화',
      showUserMessage: false,
    );

    if (result == null || !result.isSuccess) {
      state = state.copyWith(
        errorMessage: result?.errorOrNull ?? 'ホーム画面を読み込む中にエラーが発生しました。',
      );
    }
  }

  void _showInitialNotificationSnackBar() {
    // 알림 스낵바 표시 로직
  }

  @override
  void dispose() {
    state.scrollController?.dispose();
    super.dispose();
  }
}

class HomeScreenState {
  final HomeDashboardController? dashboardController;
  final HomeNotificationController? notificationController;
  final ScrollController? scrollController;
  final String? errorMessage;

  const HomeScreenState({
    this.dashboardController,
    this.notificationController,
    this.scrollController,
    this.errorMessage,
  });

  HomeScreenState copyWith({
    HomeDashboardController? dashboardController,
    HomeNotificationController? notificationController,
    ScrollController? scrollController,
    String? errorMessage,
  }) {
    return HomeScreenState(
      dashboardController: dashboardController ?? this.dashboardController,
      notificationController:
          notificationController ?? this.notificationController,
      scrollController: scrollController ?? this.scrollController,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeScreenProvider);

    // Initialize home screen after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeScreenProvider.notifier).initialize(ref);
    });

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: DynamicAppBarStyles.brown(
        scrollController: homeState.scrollController ?? ScrollController(),
        title: 'ホーム',
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'メニュー',
          ),
        ),
        actions: [_buildNotificationButton(context, ref)],
      ),
      body: CustomScrollView(
        controller: homeState.scrollController ?? ScrollController(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  const PetProfileCardRefactored(),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.pointBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Center(
                      child: Text(
                        'Weather Card',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppColors.pointGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                    child: const Center(
                      child: Text(
                        'Home Summary Grid',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        // Mock notification tap
        context.go(RouteConstants.notificationListRoute);
      },
      icon: const Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: AppColors.pointOffWhite,
            size: 24,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.circle, color: AppColors.pointPink, size: 8),
          ),
        ],
      ),
    );
  }
}
