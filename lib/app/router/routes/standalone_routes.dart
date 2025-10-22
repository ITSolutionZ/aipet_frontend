import 'package:aipet_frontend/features/board/data/models/board_post_model.dart';
import 'package:aipet_frontend/features/board/presentation/screens/board_detail_screen.dart';
import 'package:aipet_frontend/features/board/presentation/screens/board_list_screen.dart';
import 'package:aipet_frontend/features/contact/contact.dart';
import 'package:aipet_frontend/features/daily/presentation/screens/daily_pet_registration_screen.dart';
import 'package:aipet_frontend/features/daily/presentation/screens/reservation_status_screen_new.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/facility_calendar_screen.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/facility_list_screen.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/hospital_booking_screen.dart';
import 'package:aipet_frontend/features/facility/presentation/screens/hospital_detail_screen.dart';
import 'package:aipet_frontend/features/home/presentation/screens/favorites_screen.dart';
import 'package:aipet_frontend/features/notification/presentation/screens/notification_detail_screen.dart';
import 'package:aipet_frontend/features/notification/presentation/screens/notification_list_screen.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/screens/all_tricks_screen.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/screens/learn_trick_screen.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/screens/youtube_player_screen.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/screens/youtube_training_videos_screen.dart';
import 'package:aipet_frontend/features/pet_health/presentation/screens/weight_tracking_screen.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/screens/pet_profile_screen.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/features/scheduling/presentation/screens/add_event_screen.dart';
import 'package:aipet_frontend/features/shopping/presentation/screens/pet_search_screen.dart';
import 'package:aipet_frontend/features/walk/presentation/screens/live_walk_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';

/// 독립적인 전체화면 라우트 설정 (Shell 밖에 있는 화면들)
///
/// 펫 등록 플로우, 기타 독립적인 화면들을 포함합니다.
/// 이 라우트들은 하단 네비게이션 없이 전체화면으로 표시됩니다.
///
/// 주의: 설정 관련 라우트는 shell_routes.dart에서 관리됩니다.
/// 이 라우트들은 Shell과 독립적으로 실행되며, 전체화면 경험을 제공합니다.
class StandaloneRoutes {
  static List<RouteBase> get routes => [
    // Calendar Event Add/Edit Routes
    GoRoute(
      path: RouteConstants.addEventRoute,
      name: 'add-event',
      builder: (context, state) {
        // 쿼리 파라미터에서 선택된 날짜 가져오기
        final dateString =
            state.uri.queryParameters['date'] ??
            DateTime.now().toIso8601String();
        final selectedDate = DateTime.tryParse(dateString) ?? DateTime.now();

        return AddEventScreen(selectedDate: selectedDate);
      },
    ),
    GoRoute(
      path: RouteConstants.editEventRoute,
      name: 'edit-event',
      builder: (context, state) {
        // extra에서 이벤트 데이터와 선택된 날짜 가져오기
        final extra = state.extra as Map<String, dynamic>?;
        final event = extra?['event'] as CalendarEventEntity?;
        final selectedDate =
            extra?['selectedDate'] as DateTime? ?? DateTime.now();

        return AddEventScreen(selectedDate: selectedDate, initialEvent: event);
      },
    ),

    // Pet Profile (독립 라우트)
    GoRoute(
      path: '/pet-profile/:petId',
      name: 'pet-profile-standalone',
      builder: (context, state) {
        final petId = state.pathParameters['petId'] ?? 'default';
        return PetProfileScreen(petId: petId);
      },
    ),
    // Daily Health Pet Registration
    GoRoute(
      path: RouteConstants.dailyPetRegistrationRoute,
      name: 'daily-pet-registration',
      builder: (context, state) {
        // 쿼리 파라미터에서 petId 추출 (편집 모드용)
        final petId = state.uri.queryParameters['petId'];
        return DailyPetRegistrationScreen(petId: petId);
      },
    ),
    // Facility Calendar
    GoRoute(
      path: RouteConstants.facilityCalendarRoute,
      name: 'facility-calendar',
      builder: (context, state) => const FacilityCalendarScreen(),
    ),
    // Facility List
    GoRoute(
      path: RouteConstants.facilityListRoute,
      name: 'facility-list',
      builder: (context, state) => const FacilityListScreen(),
    ),
    // Hospital Detail
    GoRoute(
      path: '/hospital-detail/:hospitalId',
      name: 'hospital-detail',
      builder: (context, state) {
        final hospitalId = state.pathParameters['hospitalId'] ?? '0';
        return HospitalDetailScreen(hospitalId: hospitalId);
      },
    ),
    // Hospital Booking
    GoRoute(
      path: '/hospital-booking/:hospitalId',
      name: 'hospital-booking',
      builder: (context, state) {
        final hospitalId = state.pathParameters['hospitalId'] ?? '0';
        final hospitalName = state.uri.queryParameters['hospitalName'];
        return HospitalBookingScreen(
          hospitalId: hospitalId,
          hospitalName: hospitalName,
        );
      },
    ),
    // Hospital Reservation Status (독립 라우트)
    GoRoute(
      path: '/calendar/hospital-reservation',
      name: 'hospital-reservation-standalone',
      builder: (context, state) => const ReservationStatusScreen(),
    ),
    // 기타 독립 라우트
    GoRoute(
      path: RouteConstants.addFamilyManagerRoute,
      name: 'add-family-manager',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('家族管理者追加画面 - 近日公開'))),
    ),
    GoRoute(
      path: RouteConstants.weightTrackingRoute,
      name: 'weight-tracking',
      builder: (context, state) => const WeightTrackingScreen(),
    ),
    GoRoute(
      path: RouteConstants.healthRecordsRoute,
      name: 'health-records',
      builder: (context, state) {
        final petId = state.uri.queryParameters['petId'] ?? '1';
        return Scaffold(
          appBar: AppBar(title: const Text('健康記録')),
          body: Center(child: Text('ペットID: $petId の健康記録 - 近日公開')),
        );
      },
    ),
    GoRoute(
      path: RouteConstants.vaccinationRecordsRoute,
      name: 'vaccination-records',
      builder: (context, state) {
        final petId = state.uri.queryParameters['petId'] ?? '1';
        return Scaffold(
          appBar: AppBar(title: const Text('ワクチン記録')),
          body: Center(child: Text('ペットID: $petId のワクチン記録 - 近日公開')),
        );
      },
    ),
    GoRoute(
      path: RouteConstants.notificationListRoute,
      name: 'notifications',
      builder: (context, state) => const NotificationListScreen(),
    ),
    GoRoute(
      path: RouteConstants.notificationDetailRoute,
      name: 'notification-detail',
      builder: (context, state) {
        final notificationId = state.uri.queryParameters['id'] ?? '';
        return NotificationDetailScreen(notificationId: notificationId);
      },
    ),
    GoRoute(
      path: RouteConstants.eventDetailRoute,
      name: 'event-detail',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('イベント詳細画面 - 近日公開'))),
    ),
    GoRoute(
      path: RouteConstants.allTricksRoute,
      name: 'all-tricks',
      builder: (context, state) => const LearnTrickScreen(),
    ),
    GoRoute(
      path: RouteConstants.allTricksDetailRoute,
      name: 'all-tricks-detail',
      builder: (context, state) => const AllTricksScreen(),
    ),
    GoRoute(
      path: RouteConstants.trainingVideosRoute,
      name: 'training-videos',
      builder: (context, state) {
        final petId = state.uri.queryParameters['petId'] ?? 'pet1';
        return YouTubeTrainingVideosScreen(petId: petId);
      },
    ),
    GoRoute(
      path: RouteConstants.youtubePlayerRoute,
      name: 'youtube-player',
      builder: (context, state) {
        // extra에서 비디오, 타임라인, 북마크 데이터 가져오기
        final extra = state.extra as Map<String, dynamic>?;
        final video = extra?['video'] as YouTubeVideoEntity?;
        final startTimeSec = extra?['startTimeSec'] as int?;
        final timelineSections = extra?['timelineSections'] as List<YouTubeTimelineEntity>? ?? [];
        final bookmarks = extra?['bookmarks'] as List<VideoBookmarkEntity>? ?? [];

        if (video == null) {
          return const Scaffold(
            body: Center(child: Text('ビデオが見つかりません')),
          );
        }

        return YouTubePlayerScreen(
          video: video,
          startTimeSec: startTimeSec,
          timelineSections: timelineSections,
          bookmarks: bookmarks,
        );
      },
    ),
    GoRoute(
      path: RouteConstants.liveWalkRoute,
      name: 'live-walk',
      builder: (context, state) {
        // URL 쿼리 파라미터 또는 extra에서 petId, petName, petImage 가져오기
        String? petId = state.uri.queryParameters['petId'];
        String? petName = state.uri.queryParameters['petName'];
        String? petImage = state.uri.queryParameters['petImage'];

        if (state.extra != null && state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          petId ??= extra['petId'] as String?;
          petName ??= extra['petName'] as String?;
          petImage ??= extra['petImage'] as String?;
        }

        return LiveWalkScreen(
          petId: petId,
          petName: petName,
          petImage: petImage,
        );
      },
    ),
    // Pet Search
    GoRoute(
      path: RouteConstants.petSearchRoute,
      name: 'pet-search',
      builder: (context, state) => const PetSearchScreen(),
    ),
    // Favorites
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    // Board List
    GoRoute(
      path: RouteConstants.boardListRoute,
      name: 'board-list',
      builder: (context, state) => const BoardListScreen(),
    ),
    // Board Detail
    GoRoute(
      path: '/board/:postId',
      name: 'board-detail',
      builder: (context, state) {
        final postId = state.pathParameters['postId'] ?? '';
        final post = state.extra as BoardPost?;

        return BoardDetailScreen(postId: postId, post: post);
      },
    ),
    // Contact Form
    GoRoute(
      path: RouteConstants.contactFormRoute,
      name: 'contact-form',
      builder: (context, state) => const ContactFormScreen(),
    ),
  ];
}
