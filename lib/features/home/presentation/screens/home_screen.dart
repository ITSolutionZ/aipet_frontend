import 'package:aipet_frontend/features/home/data/data.dart';
import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/features/home/presentation/controllers/home_controller.dart';
import 'package:aipet_frontend/features/home/presentation/mixins/scroll_tracking_mixin.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/auto_banner_carousel.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/widgets.dart';
import 'package:aipet_frontend/shared/services/home_cache_manager.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final HomeCacheManager _cacheManager = HomeCacheManager();

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

    // 앱이 백그라운드에서 포그라운드로 돌아왔을 때 캐시 정리
    if (state == AppLifecycleState.resumed) {
      _cacheManager.cleanupExpiredCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(homeDashboardNotifierProvider);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 배너와 검색바
          SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.40 +
                50, // 배너 높이 축소 (30%)
            child: ClipRect(
              clipBehavior: Clip.none, // 검색바가 잘리지 않도록
              child: Transform.translate(
                offset: Offset(0, -MediaQuery.of(context).padding.top),
                child: BannerSection(
                  onSearchTap: _handleSearchTap,
                  onSearchChanged: _handleSearchChanged,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 펫이 없을 때 등록 안내
          if (!dashboard.hasPets) ...[
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.pets,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'まだペットが登録されていません',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '最初のペットを登録して、\nAIPetを始めましょう！',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton(
                        onPressed: () => context.push('/pet-type-selection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                          ),
                        ),
                        child: const Text('ペット登録'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

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

          // 오늘의 예약 (펫이 있고, 예약이 있을 경우)
          if (dashboard.hasPets && dashboard.hasTodayAppointments) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TodayAppointmentsWidget(
                appointments: dashboard.upcomingAppointments,
                onAppointmentTap: _handleAppointmentTap,
                onAppointmentComplete: _handleAppointmentComplete,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // 산책 요약 (펫이 있을 경우)
          if (dashboard.hasPets) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: WalkSummaryWidget(
                totalMinutes: dashboard.walkSummary.todayDuration.inMinutes,
                isWeeklyRecord: dashboard.walkSummary.isWeeklyRecord,
              ),
            ),
          ],

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
    // ドロワー状態をプロバイダーに保存
    ref.read(drawerStateProvider.notifier).state = true;
    _drawerAnimationController?.forward();
  }

  void _closeDrawer() {
    _drawerAnimationController?.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDrawerOpen = false;
        });
        // ドロワー状態をプロバイダーに保存
        ref.read(drawerStateProvider.notifier).state = false;
      }
    });
  }

  void _handleFavoriteTap() {
    // お気に入り画面へ移動
    context.push('/favorites');
  }

  void _handleNotificationTap() {
    // 알림 화면으로 이동
    context.push('/notification');
  }

  void _handleSearchTap() {
    // 펫 상품 검색 화면으로 이동
    context.push('/pet-search');
  }

  void _handleSearchChanged(String query) {
    final controller = ref.read(homeControllerProvider);
    controller.handleSearch(query);
  }

  void _handleAppointmentTap(AppointmentSummary appointment) {
    final controller = ref.read(homeControllerProvider);
    controller.navigateToAppointmentDetail(context, appointment);
  }

  void _handleAppointmentComplete(AppointmentSummary appointment) {
    final controller = ref.read(homeControllerProvider);
    controller.completeAppointment(context, appointment);
  }

  /// Pull-to-Refresh 핸들러
  Future<void> _handleRefresh() async {
    // debugPrint('🔄 HomeScreen: Pull-to-Refresh 시작');

    // 캐시 새로고침
    await _cacheManager.refreshHomeDashboard();

    // 대시보드 데이터 다시 로드
    ref.invalidate(homeDashboardNotifierProvider);

    // debugPrint('✅ HomeScreen: Pull-to-Refresh 완료');
  }
}
