import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/ai/presentation/screens/ai_chat_screen.dart';
import '../../../features/facility/presentation/screens/screens.dart';
import '../../../features/home/presentation/presentation.dart';
import '../../../features/notification/presentation/screens/screens.dart';
import '../../../features/pet_activities/pet_activities.dart';
import '../../../features/pet_profile/presentation/presentation.dart';
import '../../../features/scheduling/presentation/presentation.dart';
import '../../../shared/mock_data/mock_data_service.dart';
import '../../../features/settings/presentation/screens/screens.dart';
import '../../../features/walk/presentation/screens/screens.dart';
import '../../../shared/widgets/navigation/main_navigation_screen.dart';
import 'route_constants.dart';

/// 메인 앱 Shell 라우트 설정 (하단 네비게이션이 있는 화면들)
///
/// 이 Shell은 MainNavigationScreen을 통해 하단 네비게이션을 제공하며,
/// 홈, 스케줄링, AI, 산책, 캘린더, 설정 탭을 포함합니다.
class ShellRoutes {
  static ShellRoute get shellRoute => ShellRoute(
    builder: (context, state, child) {
      return MainNavigationScreen(child: child);
    },
    routes: [
      // 홈 탭
      GoRoute(
        path: RouteConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // 홈 탭 하위 라우트
          GoRoute(
            path: 'pet-empty',
            name: 'pet-empty',
            redirect: (context, state) {
              // 쿼리 파라미터 확인
              final afterRegistration =
                  state.uri.queryParameters['afterRegistration'] == 'true';

              // 신규 회원가입 후라면 펫 등록 플로우로 이동
              if (afterRegistration) {
                return RouteConstants.petTypeSelectionRoute;
              }

              // 일반적인 경우 홈 화면으로 이동 (펫이 없어도 홈 화면 유지)
              return RouteConstants.homeRoute;
            },
          ),
          GoRoute(
            path: 'pet-profile',
            name: 'pet-profile',
            builder: (context, state) {
              // 쿼리 파라미터에서 petId 추출
              final petId = state.uri.queryParameters['petId'] ?? 'default';
              return PetProfileScreen(petId: petId);
            },
          ),
          GoRoute(
            path: 'sharing-profiles',
            name: 'sharing-profiles',
            builder: (context, state) => const SharingProfilesScreen(),
          ),
          GoRoute(
            path: 'qr-scanner',
            name: 'qr-scanner',
            builder: (context, state) => const QRScannerScreen(),
          ),
          GoRoute(
            path: 'link-registration',
            name: 'link-registration',
            builder: (context, state) => const LinkRegistrationScreen(),
          ),

          GoRoute(
            path: 'tricks',
            name: 'tricks',
            builder: (context, state) => const TricksScreen(),
          ),
        ],
      ),

      // 스케줄링 탭
      GoRoute(
        path: RouteConstants.schedulingRoute,
        name: 'scheduling',
        builder: (context, state) => const SchedulingScreen(),
        routes: [
          GoRoute(
            path: 'feeding-schedule',
            name: 'feeding-schedule',
            builder: (context, state) {
              final petId = state.uri.queryParameters['petId'] ?? '1';
              return FeedingScheduleScreen(petId: petId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'feeding-schedule-edit',
                builder: (context, state) {
                  final defaults = MockDataService.getDefaultFeedingScheduleParams();
                  final mealType =
                      state.uri.queryParameters['mealType'] ?? defaults['mealType']!;
                  final time = state.uri.queryParameters['time'] ?? defaults['time']!;
                  final amount = state.uri.queryParameters['amount'] ?? defaults['amount']!;
                  final petId = state.uri.queryParameters['petId'] ?? defaults['petId']!;
                  return FeedingScheduleEditScreen(
                    mealType: mealType,
                    currentTime: time,
                    currentAmount: amount,
                    petId: petId,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'feeding-records',
            name: 'feeding-records',
            builder: (context, state) => const FeedingRecordsScreen(),
          ),
          GoRoute(
            path: 'feeding-analysis',
            name: 'feeding-analysis',
            builder: (context, state) {
              final petId = state.uri.queryParameters['petId'] ?? '1';
              return FeedingAnalysisScreen(petId: petId);
            },
          ),
          GoRoute(
            path: 'add-feeding-record',
            name: 'add-feeding-record',
            builder: (context, state) => const AddFeedingRecordScreen(),
          ),
          GoRoute(
            path: 'training',
            name: 'training',
            builder: (context, state) => const TrainingMainScreen(),
          ),
          GoRoute(
            path: 'watering',
            name: 'watering',
            builder: (context, state) => const WateringMainScreen(),
          ),
          GoRoute(
            path: 'health',
            name: 'health',
            builder: (context, state) => const HealthMainScreen(),
          ),
        ],
      ),

      // AI 탭
      GoRoute(
        path: RouteConstants.aiRoute,
        name: 'ai',
        builder: (context, state) => const AiChatScreen(),
      ),

      // 산책 탭
      GoRoute(
        path: RouteConstants.walkRoute,
        name: 'walk',
        builder: (context, state) => const WalkListScreen(),
      ),

      // 캘린더 탭
      GoRoute(
        path: RouteConstants.calendarRoute,
        name: 'calendar',
        builder: (context, state) => const FacilityListScreen(),
        routes: [
          GoRoute(
            path: 'grooming-reservation',
            name: 'grooming-reservation',
            builder: (context, state) => const GroomingReservationScreen(),
          ),
          GoRoute(
            path: 'hospital-reservation',
            name: 'hospital-reservation',
            builder: (context, state) => const HospitalReservationScreen(),
          ),
          GoRoute(
            path: 'facility-detail',
            name: 'facility-detail',
            builder: (context, state) {
              final facilityId = state.uri.queryParameters['facilityId'] ?? '1';
              return FacilityDetailScreen(facilityId: facilityId);
            },
          ),
          GoRoute(
            path: 'booking',
            name: 'booking',
            builder: (context, state) {
              final facilityId = state.uri.queryParameters['facilityId'] ?? '1';
              return BookingScreen(facilityId: facilityId);
            },
          ),
        ],
      ),

      // 설정 탭
      GoRoute(
        path: RouteConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile-edit',
            name: 'profile-edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: 'account-delete',
            name: 'account-delete',
            builder: (context, state) => const AccountDeleteScreen(),
          ),
          GoRoute(
            path: 'push-notification',
            name: 'push-notification',
            builder: (context, state) => const PushNotificationScreen(),
          ),
          GoRoute(
            path: 'alarm-time-settings',
            name: 'alarm-time-settings',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Alarm Time Settings Screen - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
