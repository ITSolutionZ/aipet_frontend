import 'package:aipet_frontend/features/ai/presentation/screens/ai_chat_history_list_screen.dart';
import 'package:aipet_frontend/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:aipet_frontend/features/ai/presentation/screens/ai_favorite_messages_screen.dart';
import 'package:aipet_frontend/features/facility/facility.dart';
import 'package:aipet_frontend/features/home/presentation/presentation.dart';
import 'package:aipet_frontend/features/notification/presentation/screens/notification_screens.dart';
import 'package:aipet_frontend/features/pet_activities/pet_activities.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/screens/link_registration_screen.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/screens/pet_profile_screen_refactored.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/screens/qr_scanner_screen.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/screens/sharing_profiles_screen.dart';
import 'package:aipet_frontend/features/scheduling/presentation/presentation.dart';
import 'package:aipet_frontend/features/scheduling/presentation/screens/today_appointments_screen.dart';
import 'package:aipet_frontend/features/settings/presentation/screens/settings_screens.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/screens/walk_detail_screen.dart';
import 'package:aipet_frontend/features/walk/presentation/screens/walk_list_screen.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/scheduling/scheduling_mock_service.dart';
import 'package:aipet_frontend/shared/widgets/navigation/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';

/// 메인 앱 Shell 라우트 설정 (하단 네비게이션이 있는 화면들)
///
/// 이 Shell은 MainNavigationScreen을 통해 하단 네비게이션을 제공하며,
/// 홈, 스케줄링, AI, 산책, 캘린더, 설정 탭을 포함합니다.
///
/// 모든 메인 앱 화면은 이 Shell 내에서 실행되며, 하단 네비게이션을 통해
/// 탭 간 이동이 가능합니다.
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
              return PetProfileScreenRefactored(petId: petId);
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
                  final defaults =
                      SchedulingMockService.getDefaultFeedingScheduleParams();
                  final mealType =
                      state.uri.queryParameters['mealType'] ??
                      defaults['mealType']!;
                  final time =
                      state.uri.queryParameters['time'] ?? defaults['time']!;
                  final amount =
                      state.uri.queryParameters['amount'] ??
                      defaults['amount']!;
                  final petId =
                      state.uri.queryParameters['petId'] ?? defaults['petId']!;
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
            routes: [
              GoRoute(
                path: 'schedule',
                name: 'watering-schedule',
                builder: (context, state) => const WateringScheduleScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'watering-schedule-edit',
                    builder: (context, state) {
                      final mealType =
                          state.uri.queryParameters['mealType'] ?? '朝の給水';
                      final time = state.uri.queryParameters['time'] ?? '08:00';
                      final amount =
                          state.uri.queryParameters['amount'] ?? '200ml';
                      return WateringScheduleEditScreen(
                        scheduleId:
                            state.uri.queryParameters['scheduleId'] ?? '',
                        mealType: mealType,
                        currentTime: time,
                        currentAmount: amount,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'records',
                name: 'watering-records',
                builder: (context, state) => const WateringRecordsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-watering-record',
                    builder: (context, state) =>
                        const AddWateringRecordScreen(),
                  ),
                  GoRoute(
                    path: 'edit',
                    name: 'edit-watering-record',
                    builder: (context, state) {
                      // TODO: 실제 record 데이터를 전달하는 방식으로 개선 필요
                      final mockRecord = {
                        'date': '2024-01-15',
                        'time': '08:30',
                        'amount': '200ml',
                        'type': '定期的な給水',
                        'notes': 'いつも通り完食',
                      };
                      return EditWateringRecordScreen(record: mockRecord);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'analysis',
                name: 'watering-analysis',
                builder: (context, state) => const WateringAnalysisScreen(),
              ),
              GoRoute(
                path: 'settings',
                name: 'watering-settings',
                builder: (context, state) => const WateringSettingsScreen(),
              ),
            ],
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
        routes: [
          // AI 즐겨찾기 메시지
          GoRoute(
            path: 'favorite-messages',
            name: 'ai-favorite-messages',
            builder: (context, state) => const AiFavoriteMessagesScreen(),
          ),
          // AI 채팅 히스토리
          GoRoute(
            path: 'chat-history',
            name: 'ai-chat-history',
            builder: (context, state) => const AiChatHistoryListScreen(),
          ),
        ],
      ),

      // 산책 탭
      GoRoute(
        path: RouteConstants.walkRoute,
        name: 'walk',
        builder: (context, state) =>
            const WalkListScreen(showBackButton: false),
        routes: [
          // 산책 상세 화면
          GoRoute(
            path: 'detail',
            name: 'walk-detail',
            builder: (context, state) {
              final walkRecord = state.extra as WalkRecordEntity?;
              if (walkRecord == null) {
                return const Scaffold(
                  body: Center(child: Text('산책 기록을 찾을 수 없습니다.')),
                );
              }
              return WalkDetailScreen(walkRecord: walkRecord);
            },
          ),
        ],
      ),

      // 홈에서 산책 카드로 이동하는 라우트
      GoRoute(
        path: RouteConstants.walkFromHomeRoute,
        name: 'walk-from-home',
        builder: (context, state) => const WalkListScreen(showBackButton: true),
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
            path: 'facility-fullscreen-map',
            name: 'facility-fullscreen-map',
            builder: (context, state) {
              final facilityId = state.uri.queryParameters['facilityId'] ?? '1';
              // TODO: 실제 시설 데이터로 교체 필요
              final mockFacility = Facility(
                id: facilityId,
                name: 'Shinny Fur Saloon',
                description: '전문적인 펫 트리밍 서비스',
                address: '70 North Street',
                phone: '079 1234 7777',
                email: 'contactshinnyfur@gmail.com',
                type: FacilityType.grooming,
                rating: 4.6,
                reviewCount: 230,
                imagePath: 'assets/images/placeholder.png',
                isFavorite: false,
                hasHistory: false,
                latitude: 35.6092,
                longitude: 139.7301,
              );
              return FacilityFullscreenMapScreen(facility: mockFacility);
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

      // 오늘의 예약 독립 라우트
      GoRoute(
        path: RouteConstants.todayAppointmentsRoute,
        name: 'today-appointments',
        builder: (context, state) => const TodayAppointmentsScreen(),
      ),
    ],
  );
}
