import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../controllers/home_controller.dart';
import '../widgets/appointment_card.dart';
import '../widgets/health_summary_section.dart';
import '../widgets/pet_profile_card.dart';
import '../widgets/walk_summary_section.dart';
import '../widgets/weather_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = HomeController(ref);

    // 화면이 로드된 후 펫 목록을 확인하여 리다이렉트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPetsAndRedirect();
    });
  }

  /// 펫 목록을 확인하고 홈 화면 초기화
  Future<void> _checkPetsAndRedirect() async {
    try {
      final hasPets = await _homeController.hasPets();
      if (!hasPets && mounted) {
        // 펫이 없어도 홈 화면 유지 (펫 등록 유도 UI 표시)
        await _initializeHomeScreen();
      } else {
        // 펫이 있으면 홈 화면 초기화
        await _initializeHomeScreen();
      }
    } catch (error) {
      // 에러 발생시 기본적으로 홈 화면 유지 (목업 데이터는 항상 펫이 있음)
      await _initializeHomeScreen();
    }
  }

  /// 홈 화면 초기화
  Future<void> _initializeHomeScreen() async {
    try {
      final result = await _homeController.initializeHome();
      if (mounted && !result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      // 초기화 실패시 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('홈 화면을 불러오는 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 알림 아이콘 탭 처리
  Future<void> _handleNotificationTap() async {
    try {
      final notificationResult = await _homeController.handleNotification();
      if (mounted) {
        if (notificationResult.isSuccess && notificationResult.data != null) {
          final notifications = notificationResult.data as List<String>;
          if (notifications.isNotEmpty) {
            // 알림이 있으면 스낵바로 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(notificationResult.message),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
        // 알림 목록으로 이동
        context.go(RouteConstants.notificationListRoute);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림을 확인하는 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // 상단 헤더
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.sm,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.8),
            ),
            child: Row(
              children: [
                // 햄버거 메뉴
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: const Icon(
                      Icons.menu,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                // 제목
                const Text(
                  'ホーム',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fredoka',
                  ),
                ),

                const Spacer(),

                // 알림 아이콘
                IconButton(
                  onPressed: () {
                    _handleNotificationTap();
                  },
                  icon: const Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      // 알림 배지 (실제로는 알림 개수에 따라 동적으로 표시)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(Icons.circle, color: Colors.red, size: 8),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 프로필 아바타
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 메인 콘텐츠
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 펫 프로필 카드
                  PetProfileCard(),
                  SizedBox(height: AppSpacing.lg),

                  // 날씨 카드
                  WeatherCard(),
                  SizedBox(height: AppSpacing.lg),

                  // 산책 요약 섹션
                  WalkSummarySection(),
                  SizedBox(height: AppSpacing.lg),

                  // 예약 카드
                  AppointmentCard(),
                  SizedBox(height: AppSpacing.lg),

                  // 건강 요약 섹션
                  HealthSummarySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
