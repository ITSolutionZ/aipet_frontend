import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/notification/presentation/screens/notification_detail_screen.dart';
import '../../../features/notification/presentation/screens/notification_list_screen.dart';
import '../../../features/pet_activities/presentation/screens/all_tricks_screen.dart';
import '../../../features/pet_activities/presentation/screens/youtube_training_videos_screen.dart';
import '../../../features/pet_health/presentation/screens/weight_tracking_screen.dart';
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
  ];
}
