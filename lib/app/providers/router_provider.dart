import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// GoRouter 프로바이더
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter();
});

/// 현재 라우트 정보를 제공하는 프로바이더
final currentRouteProvider = Provider<String>((ref) {
  final router = ref.watch(routerProvider);
  return router.routerDelegate.currentConfiguration.uri.path;
});
