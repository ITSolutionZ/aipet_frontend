import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../controllers/controllers.dart';
import '../widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeDashboardController _dashboardController;
  late HomeNotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _dashboardController = HomeDashboardController(ref);
    _notificationController = HomeNotificationController(ref);

    // 화면이 로드된 후 펫 목록을 확인하여 리다이렉트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPetsAndRedirect();
    });
  }

  /// 펫 목록을 확인하고 홈 화면 초기화
  Future<void> _checkPetsAndRedirect() async {
    try {
      await _dashboardController.hasPets();
      await _initializeHomeScreen();
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
        _showErrorSnackBar('홈 화면을 불러오는 중 오류가 발생했습니다.');
      }
    }
  }

  /// 알림 아이콘 탭 처리
  Future<void> _handleNotificationTap() async {
    try {
      final notificationResult = await _notificationController
          .handleNotification();
      if (mounted) {
        _handleNotificationResult(notificationResult);
        context.go(RouteConstants.notificationListRoute);
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('알림을 확인하는 중 오류가 발생했습니다.');
      }
    }
  }

  /// 알림 결과 처리
  void _handleNotificationResult(dynamic notificationResult) {
    if (notificationResult.isSuccess && notificationResult.data != null) {
      final notifications = notificationResult.data as List<String>;
      if (notifications.isNotEmpty) {
        _showSuccessSnackBar(notificationResult.message);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      appBar: SoftGradientDrawerAppBar(
        title: 'ホーム',
        selectedPetInfo: Row(
          children: [
            _buildNotificationButton(),
            const SizedBox(width: AppSpacing.xs),
            _buildMenuButton(context),
          ],
        ),
      ),
      body: Column(children: [_buildMainContent()]),
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

  Widget _buildMenuButton(BuildContext context) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
        tooltip: 'メニュー',
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
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
          _buildNotificationCountBar(),
        ],
      ),
    );
  }

  Widget _buildNotificationCountBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.pointBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${NotificationMockData.unreadNotifications.length}件の通知があります',
            style: AppFonts.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              context.go(RouteConstants.notificationListRoute);
            },
            child: Text(
              '確認する',
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
