import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/config/app_config.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../controllers/home_dashboard_controller.dart';
import '../controllers/home_notification_controller.dart';
import '../widgets/home_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeDashboardController _dashboardController;
  late HomeNotificationController _notificationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _dashboardController = HomeDashboardController(ref);
    _notificationController = HomeNotificationController(ref);
    _scrollController = ScrollController();

    // 화면이 로드된 후 펫 목록을 확인하여 리다이렉트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPetsAndRedirect();
      _showInitialNotificationSnackBar();
    });
  }

  /// 펫 목록을 확인하고 홈 화면 초기화
  Future<void> _checkPetsAndRedirect() async {
    try {
      final result = await _dashboardController.hasPets();
      if (result.isSuccess && result.data == true) {
        await _initializeHomeScreen();
      } else {
        await _initializeHomeScreen();
      }
    } catch (error) {
      await _initializeHomeScreen();
    }
  }

  /// 홈 화면 초기화
  Future<void> _initializeHomeScreen() async {
    try {
      final result = await _dashboardController.initializeHome();
      if (mounted && !result.isSuccess) {
        _showErrorSnackBar(result.message);
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('ホーム画面を読み込む中にエラーが発生しました。');
      }
    }
  }

  /// 알림 아이콘 탭 처리
  Future<void> _handleNotificationTap() async {
    try {
      final result = await _notificationController.handleNotification();
      if (mounted) {
        if (result.isSuccess) {
          _handleNotificationResult(result.data ?? []);
          _showNotificationSnackBar();
          context.go(RouteConstants.notificationListRoute);
        } else {
          _showErrorSnackBar(result.message);
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('通知を確認する中にエラーが発生しました。');
      }
    }
  }

  /// 알림 결과 처리
  void _handleNotificationResult(List<String> notifications) {
    if (notifications.isNotEmpty) {
      _showSuccessSnackBar('${notifications.length}件の通知があります');
    }
  }

  /// 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointPink),
    );
  }

  /// 성공 스낵바 표시
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pointBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 알림 스낵바 표시
  void _showNotificationSnackBar() {
    final notificationCount =
        NotificationMockService.getMockNotifications().length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '$notificationCount件の通知があります',
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointBlue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '確認する',
          textColor: Colors.white,
          onPressed: () {
            context.go(RouteConstants.notificationListRoute);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 초기 알림 스낵바 표시 (알림이 있을 때만)
  void _showInitialNotificationSnackBar() {
    final notificationCount =
        NotificationMockService.getMockNotifications().length;

    // 알림이 있을 때만 스낵바 표시
    if (notificationCount > 0) {
      if (AppConfig.current.environment == 'test') {
        // 테스트 환경에서는 즉시 실행
        if (mounted) {
          _showNotificationSnackBar();
        }
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showNotificationSnackBar();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: 'ホーム',
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'メニュー',
          ),
        ),
        actions: [_buildNotificationButton()],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: const [
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.md),
                  PetProfileCard(),
                  SizedBox(height: AppSpacing.lg),
                  WeatherCard(),
                  SizedBox(height: AppSpacing.lg),
                  HomeSummaryGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      onPressed: _handleNotificationTap,
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
