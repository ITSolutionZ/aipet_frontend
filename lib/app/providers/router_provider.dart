import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// GoRouter 프로바이더
///
/// 앱의 라우터 인스턴스를 제공하며, 모든 라우팅 로직을 중앙에서 관리합니다.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter();
});

/// 현재 라우트 정보를 제공하는 프로바이더
///
/// 현재 활성화된 라우트의 경로를 실시간으로 추적합니다.
final currentRouteProvider = Provider<String>((ref) {
  final router = ref.watch(routerProvider);
  return router.routerDelegate.currentConfiguration.uri.path;
});
