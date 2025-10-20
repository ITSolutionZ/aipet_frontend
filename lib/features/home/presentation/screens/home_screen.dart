import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../controllers/home_controller.dart';
import '../mixins/scroll_tracking_mixin.dart';
import '../widgets/auto_banner_carousel.dart';
import '../widgets/pet_profile_banner.dart';
import '../widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

/// 🏠 홈 스크린
///
/// 앱의 메인 홈 화면으로 대시보드 정보를 표시합니다.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with
        ScrollTrackingMixin,
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _drawerAnimationController;
  Animation<Offset>? _drawerSlideAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _drawerSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _drawerAnimationController!,
            curve: Curves.easeInOut,
          ),
        );

    // 앱 라이프사이클 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _drawerAnimationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 백그라운드에서 포그라운드로 돌아왔을 때
    if (state == AppLifecycleState.resumed) {
      // TODO: 캐시 정리 로직 추가 필요시 구현
      debugPrint('앱이 포그라운드로 돌아왔습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(homeDashboardProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.pointOffWhite,
      extendBodyBehindAppBar: true,
      appBar: HomeAppBar(
        scrollOffset: scrollOffset,
        isDrawerOpen: _isDrawerOpen,
        onMenuTap: _handleMenuTap,
        onFavoriteTap: _handleFavoriteTap,
        onNotificationTap: _handleNotificationTap,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Stack(
          children: [
            // メインコンテンツ
            dashboardState.when(
              data: (dashboard) => _buildDashboard(dashboard),
              loading: () => Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 150,
                  height: 150,
                ),
              ),
              error: (error, stackTrace) => HomeErrorViewWidget(error: error),
            ),

            // ドロワーオーバーレイ（開いている時のみ表示）
            if (_isDrawerOpen)
              GestureDetector(
                onTap: _closeDrawer,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),

            // ドロワー
            if (_drawerSlideAnimation != null)
              SlideTransition(
                position: _drawerSlideAnimation!,
                child: const AppDrawer(),
              ),
          ],
        ),
      ),
    );
  }

  /// 대시보드 UI 빌드
  Widget _buildDashboard(HomeDashboardEntity dashboard) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // 배너가 전체 너비를 차지하도록 수정
        children: [
          // 펫 프로필 배너
          PetProfileBanner(scrollOffset: scrollOffset),

          // 검색바 (간격 줄임)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: HomeSearchBarWidget(
              onTap: _handleSearchTap,
              onChanged: _handleSearchChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.md), // 간격 줄임
          // 날씨 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: WeatherCardWidget(weather: dashboard.weather),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 빠른 메뉴 그리드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: HomeMenuGridWidget(
              menuItems: HomeMenuItems.getMenuItems(context),
              crossAxisCount: 5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // 자동 슬라이드 배너
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AutoBannerCarousel(
              bannerImages: BannerAssets.homeBannerImages,
              height:
                  (MediaQuery.of(context).size.width - (AppSpacing.lg * 2)) /
                  2, // 2:1 비율 유지
              autoSlideInterval: const Duration(seconds: 4),
              onTap: (index) {
                // 배너 탭 이벤트 처리
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 오늘의 일정 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  color: AppColors.pureWhite,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: AppColors.pointBlue,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '今日の予定',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.pointBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (dashboard.hasPets &&
                        dashboard.hasTodayAppointments) ...[
                      ...dashboard.upcomingAppointments
                          .take(3)
                          .map(
                            (appointment) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.pointBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      appointment.title,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                  Text(
                                    '${appointment.scheduledTime.hour}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ] else ...[
                      Text(
                        '今日の予定はありません',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 산책 서머리 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  color: AppColors.pureWhite,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          color: AppColors.pointGreen,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '散歩サマリー',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.pointGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (dashboard.hasPets) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '今日の散歩時間',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${dashboard.walkSummary.todayDuration.inMinutes}分',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.pointGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (dashboard.walkSummary.isWeeklyRecord) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.pointGreen,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.sm,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    '週間記録更新！',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else ...[
                      Text(
                        'ペットを登録して散歩を記録しましょう',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 하단 여백
          SizedBox(height: AppSpacing.xl + MediaQuery.of(context).padding.top),
        ],
      ),
    );
  }

  // 이벤트 핸들러들
  void _handleMenuTap() {
    // メニュー（ドロワー）を開く
    if (_isDrawerOpen) {
      _closeDrawer();
    } else {
      _openDrawer();
    }
  }

  void _openDrawer() {
    setState(() {
      _isDrawerOpen = true;
    });
    _drawerAnimationController?.forward();
  }

  void _closeDrawer() {
    _drawerAnimationController?.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDrawerOpen = false;
        });
      }
    });
  }

  void _handleFavoriteTap() {
    // お気に入り画面へ移動
    context.push('/favorites');
  }

  void _handleNotificationTap() {
    // 알림 목록 화면으로 이동
    context.push('/notifications');
  }

  void _handleSearchTap() {
    // 펫 상품 검색 화면으로 이동
    context.push('/pet-search');
  }

  void _handleSearchChanged(String query) {
    final controller = ref.read(homeControllerProvider);
    controller.handleSearch(query);
  }

  /// Pull-to-Refresh 핸들러
  Future<void> _handleRefresh() async {
    // debugPrint('🔄 HomeScreen: Pull-to-Refresh 시작');

    // 대시보드 데이터 다시 로드
    ref.invalidate(homeDashboardProvider);

    // debugPrint('✅ HomeScreen: Pull-to-Refresh 완료');
  }
}
