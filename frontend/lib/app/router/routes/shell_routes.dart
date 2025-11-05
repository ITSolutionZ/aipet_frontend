import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 프로젝트 모듈
import '../../../features/ai/ai.dart';
import '../../../features/allergy/allergy.dart';
import '../../../features/daily/daily.dart';
import '../../../features/facility/facility.dart';
import '../../../features/home/home.dart';
import '../../../features/notification/notification.dart';
import '../../../features/pet_profile/pet_profile.dart';
import '../../../features/scheduling/scheduling.dart';
import '../../../features/settings/presentation/presentation.dart';
import '../../../features/settings/settings.dart';
import '../../../features/walk/walk.dart';
import '../../../shared/shared.dart';
import 'route_constants.dart';

// import 'package:aipet_frontend/features/pet_activities/pet_activities.dart';

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

              // 신규 회원가입 후라면 Daily Pet Registration 화면으로 이동
              if (afterRegistration) {
                return RouteConstants.dailyPetRegistrationRoute;
              }

              // 일반적인 경우 홈 화면으로 이동 (펫이 없어도 홈 화면 유지)
              return RouteConstants.homeRoute;
            },
          ),
          GoRoute(
            path: 'pet-profile/:petId',
            name: 'pet-profile',
            builder: (context, state) {
              // 경로 파라미터에서 petId 추출
              final petId = state.pathParameters['petId'] ?? 'default';
              // クエリパラメータから編集モードフラグを取得
              final isEditMode =
                  state.uri.queryParameters['isEditMode'] == 'true';
              return PetProfileScreen(
                petId: petId,
                initialEditMode: isEditMode,
              );
            },
          ),
          GoRoute(
            path: 'pet-management',
            name: 'pet-management',
            builder: (context, state) => const PetManagementScreen(),
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

          // GoRoute(
          //   path: 'tricks',
          //   name: 'tricks',
          //   builder: (context, state) => const TricksScreen(),
          // ),
          GoRoute(
            path: 'qr',
            name: 'qr-code',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                child: const SizedBox.shrink(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      // 페이지 진입 시 바텀시트 표시
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        QRCodeBottomSheet.show(context);
                      });
                      return const SizedBox.shrink();
                    },
              );
            },
          ),
          GoRoute(
            path: 'allergy',
            name: 'allergy',
            builder: (context, state) => const AllergyMainScreen(),
            routes: [
              GoRoute(
                path: 'product-selection',
                name: 'allergy-product-selection',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return AllergyProductSelectionScreen(
                    hasAllergy: args['hasAllergy'] as bool,
                    petId: args['petId'] as String,
                  );
                },
              ),
              GoRoute(
                path: 'analysis-result',
                name: 'allergy-analysis-result',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return AllergyAnalysisResultScreen(
                    analysisResult:
                        args['analysisResult'] as Map<String, dynamic>,
                    petName: args['petName'] as String,
                    petId: args['petId'] as String,
                  );
                },
              ),
              GoRoute(
                path: 'recommended-products',
                name: 'allergy-recommended-products',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return AllergyRecommendedProductsScreen(
                    suspectedIngredients:
                        args['suspectedIngredients'] as List<String>,
                    petId: args['petId'] as String,
                    petName: args['petName'] as String,
                  );
                },
              ),
              GoRoute(
                path: 'saved-analyses',
                name: 'saved-analysis-list',
                builder: (context, state) => const SavedAnalysisListScreen(),
              ),
            ],
          ),

          // Daily Health Routes (하단 네비게이션 포함)
          GoRoute(
            path: 'daily',
            name: 'daily-health',
            builder: (context, state) => const DailyHealthScreen(),
          ),
          GoRoute(
            path: 'daily/input',
            name: 'daily-health-input',
            builder: (context, state) {
              DailyHealthRecord? existingRecord;
              if (state.extra != null && state.extra is DailyHealthRecord) {
                existingRecord = state.extra as DailyHealthRecord;
              }
              return DailyHealthInputScreen(existingRecord: existingRecord);
            },
          ),
          GoRoute(
            path: 'daily/history',
            name: 'daily-health-history',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('健康記録ヒストリー - 近日実装予定'))),
          ),
          GoRoute(
            path: 'daily/hospital-management',
            name: 'hospital-management',
            builder: (context, state) => const HospitalManagementScreen(),
          ),
          GoRoute(
            path: 'daily/reservation-status',
            name: 'reservation-status',
            builder: (context, state) => const ReservationStatusScreen(),
          ),
          // 시설 타입 선택 화면
          GoRoute(
            path: 'facility-type-selection',
            name: 'facility-type-selection',
            builder: (context, state) => const FacilityTypeSelectionScreen(),
          ),
          // 동물병원 목록 화면
          GoRoute(
            path: 'hospital-list',
            name: 'hospital-list',
            builder: (context, state) => const HospitalListScreen(),
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
                  final mealType =
                      state.uri.queryParameters['mealType'] ?? '朝食';
                  final time = state.uri.queryParameters['time'] ?? '08:00';
                  final amount = state.uri.queryParameters['amount'] ?? '100g';
                  final petId = state.uri.queryParameters['petId'] ?? '1';
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
                      final record = state.extra as Map<String, dynamic>?;
                      return EditWateringRecordScreen(
                        record:
                            record ??
                            {
                              'date': '2024-01-15',
                              'time': '08:30',
                              'amount': '200ml',
                              'type': '定期的な給水',
                              'notes': 'いつも通り完食',
                            },
                      );
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
          GoRoute(
            path: 'alarm-setup',
            name: 'alarm-setup',
            builder: (context, state) {
              final dateStr = state.uri.queryParameters['date'];
              final eventTypeStr = state.uri.queryParameters['eventType'];

              DateTime? initialDate;
              if (dateStr != null) {
                initialDate = DateTime.tryParse(dateStr);
              }

              CalendarEventType? eventType;
              if (eventTypeStr != null) {
                eventType = CalendarEventType.values.firstWhere(
                  (type) => type.name == eventTypeStr,
                  orElse: () => CalendarEventType.feeding,
                );
              }

              return AlarmSetupScreen(
                initialDate: initialDate,
                eventType: eventType,
              );
            },
          ),
          GoRoute(
            path: 'new-event',
            name: 'new-event',
            builder: (context, state) {
              final dateStr = state.uri.queryParameters['date'];
              final eventTypeStr = state.uri.queryParameters['eventType'];

              DateTime? initialDate;
              if (dateStr != null) {
                initialDate = DateTime.tryParse(dateStr);
              }

              CalendarEventType? eventType;
              if (eventTypeStr != null) {
                eventType = CalendarEventType.values.firstWhere(
                  (type) => type.name == eventTypeStr,
                  orElse: () => CalendarEventType.feeding,
                );
              }

              return NewEventSetupScreen(
                initialDate: initialDate,
                eventType: eventType,
              );
            },
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
          // 산책 기록 달력 화면
          GoRoute(
            path: 'calendar',
            name: 'walk-calendar',
            builder: (context, state) => const WalkCalendarScreen(),
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
          // 예약 상태 화면
          GoRoute(
            path: 'hospital-reservation',
            name: 'hospital-reservation',
            builder: (context, state) => const ReservationStatusScreen(),
          ),
          GoRoute(
            path: 'facility-fullscreen-map',
            name: 'facility-fullscreen-map',
            builder: (context, state) {
              final facilityId = state.uri.queryParameters['facilityId'] ?? '1';

              // 기본 시설 데이터 사용
              final facility = Facility(
                id: facilityId,
                name: 'ペットサロン ルナ',
                description: 'プレミアムペット美容サービス',
                address: '東京都港区六本木7-14-23',
                phone: '03-5678-9012',
                email: 'luna@pet-salon.jp',
                type: FacilityType.grooming,
                rating: 4.7,
                reviewCount: 195,
                imagePath: 'assets/images/placeholder.png',
                isFavorite: false,
                hasHistory: false,
                latitude: 35.6627,
                longitude: 139.7290,
              );

              return FacilityFullscreenMapScreen(facility: facility);
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
            path: 'biometric-security',
            name: 'biometric-security',
            builder: (context, state) => const BiometricSecurityScreen(),
          ),
          GoRoute(
            path: 'push-notification',
            name: 'push-notification',
            builder: (context, state) => const PushNotificationScreen(),
          ),
          GoRoute(
            path: 'local-alarm-settings',
            name: 'local-alarm-settings',
            builder: (context, state) => const LocalAlarmSettingsScreen(),
          ),
          GoRoute(
            path: 'alarm-time-settings',
            name: 'alarm-time-settings',
            builder: (context, state) => const AlarmTimeSettingsScreen(),
          ),
          GoRoute(
            path: 'database-dashboard',
            name: 'database-dashboard',
            builder: (context, state) => const DatabaseDashboardScreen(),
          ),
          GoRoute(
            path: 'app-info',
            name: 'app-info',
            builder: (context, state) => const AppInfoScreen(),
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
