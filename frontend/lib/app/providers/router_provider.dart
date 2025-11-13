import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 싱글톤 라우터 인스턴스 (키 중복 방지용)
GoRouter? _routerInstance;

/// 메인 라우터 프로바이더 (싱글톤 패턴으로 키 중복 방지)
///
/// 앱의 라우터 인스턴스를 제공하며, 모든 라우팅 로직을 중앙에서 관리합니다.
/// GlobalKey 중복 문제를 방지하기 위해 싱글톤 패턴을 사용합니다.
final routerProvider = Provider<GoRouter>((ref) {
  _routerInstance ??= AppRouter.createRouter();
  return _routerInstance!;
});

/// 현재 라우트 정보를 제공하는 프로바이더
///
/// 현재 활성화된 라우트의 경로를 실시간으로 추적합니다.
final currentRouteProvider = Provider<String>((ref) {
  final router = ref.watch(routerProvider);
  return router.routerDelegate.currentConfiguration.uri.path;
});
