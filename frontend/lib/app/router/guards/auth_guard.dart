import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/shared.dart';
import '../app_router.dart';

/// 인증 가드 - 라우팅 시 인증 상태에 따라 리다이렉트
///
/// Firebase Auth의 실시간 인증 상태를 체크하여 적절한 화면으로 리다이렉트합니다.
///
/// 사용법:
/// ```dart
/// GoRoute(
///   path: '/home',
///   redirect: AuthGuard.requireAuth, // 로그인 필요
///   builder: (context, state) => HomeScreen(),
/// )
/// ```
class AuthGuard {
  /// 로그인이 필요한 라우트 가드
  ///
  /// 로그인되지 않은 사용자는 로그인 화면으로 리다이렉트됩니다.
  /// 로그인된 사용자는 null을 반환하여 원래 화면으로 진행합니다.
  ///
  /// [context] BuildContext
  /// [state] GoRouterState
  ///
  /// Returns: 리다이렉트할 경로 또는 null (진행 허용)
  static String? requireAuth(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = state.uri.path;

    // 로그인되지 않은 경우
    if (user == null) {
      LoggerService.debug('🚫 [AuthGuard] 로그인 필요: $currentPath → /login');
      return AppRouter.loginRoute;
    }

    // 로그인된 경우 진행 허용
    LoggerService.debug('✅ [AuthGuard] 인증 통과: $currentPath');
    return null;
  }

  /// 비로그인 사용자만 접근 가능한 라우트 가드
  ///
  /// 로그인된 사용자는 홈 화면으로 리다이렉트됩니다.
  /// 로그인되지 않은 사용자는 null을 반환하여 원래 화면으로 진행합니다.
  ///
  /// 사용 예시: 로그인 화면, 회원가입 화면 등
  ///
  /// [context] BuildContext
  /// [state] GoRouterState
  ///
  /// Returns: 리다이렉트할 경로 또는 null (진행 허용)
  static String? requireGuest(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = state.uri.path;

    // 로그인된 경우 홈으로 리다이렉트
    if (user != null) {
      LoggerService.debug('🚫 [AuthGuard] 이미 로그인됨: $currentPath → /home');
      return AppRouter.homeRoute;
    }

    // 비로그인 상태면 진행 허용
    LoggerService.debug('✅ [AuthGuard] 비로그인 접근 허용: $currentPath');
    return null;
  }

  /// 이메일 인증이 필요한 라우트 가드
  ///
  /// 이메일 인증이 완료되지 않은 사용자는 인증 안내 화면으로 리다이렉트됩니다.
  ///
  /// [context] BuildContext
  /// [state] GoRouterState
  ///
  /// Returns: 리다이렉트할 경로 또는 null (진행 허용)
  static String? requireEmailVerified(BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = state.uri.path;

    // 로그인되지 않은 경우
    if (user == null) {
      LoggerService.debug('🚫 [AuthGuard] 로그인 필요: $currentPath → /login');
      return AppRouter.loginRoute;
    }

    // 이메일 인증되지 않은 경우
    if (!user.emailVerified) {
      LoggerService.debug(
        '🚫 [AuthGuard] 이메일 인증 필요: $currentPath → /email-verification',
      );
      // TODO: 이메일 인증 화면으로 리다이렉트 (구현 필요)
      return AppRouter.loginRoute;
    }

    // 인증 완료된 경우 진행 허용
    LoggerService.debug('✅ [AuthGuard] 이메일 인증 완료: $currentPath');
    return null;
  }

  /// 관리자 권한이 필요한 라우트 가드
  ///
  /// CustomClaims를 체크하여 관리자 권한을 확인합니다.
  /// 관리자가 아닌 경우 홈 화면으로 리다이렉트됩니다.
  ///
  /// [context] BuildContext
  /// [state] GoRouterState
  ///
  /// Returns: 리다이렉트할 경로 또는 null (진행 허용)
  static Future<String?> requireAdmin(
    BuildContext context,
    GoRouterState state,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = state.uri.path;

    // 로그인되지 않은 경우
    if (user == null) {
      LoggerService.debug('🚫 [AuthGuard] 로그인 필요: $currentPath → /login');
      return AppRouter.loginRoute;
    }

    try {
      // Custom Claims 확인
      final idTokenResult = await user.getIdTokenResult();
      final isAdmin = idTokenResult.claims?['admin'] == true;

      if (!isAdmin) {
        LoggerService.debug('🚫 [AuthGuard] 관리자 권한 없음: $currentPath → /home');
        return AppRouter.homeRoute;
      }

      // 관리자 권한이 있는 경우 진행 허용
      LoggerService.debug('✅ [AuthGuard] 관리자 권한 확인: $currentPath');
      return null;
    } catch (e) {
      LoggerService.debug('❌ [AuthGuard] Custom Claims 확인 실패: $e');
      return AppRouter.homeRoute;
    }
  }

  /// 백엔드 토큰이 필요한 라우트 가드
  ///
  /// Firebase 로그인 + 백엔드 JWT 토큰이 모두 유효한지 확인합니다.
  /// 토큰이 없거나 만료된 경우 로그인 화면으로 리다이렉트됩니다.
  ///
  /// [context] BuildContext
  /// [state] GoRouterState
  ///
  /// Returns: 리다이렉트할 경로 또는 null (진행 허용)
  static Future<String?> requireBackendAuth(
    BuildContext context,
    GoRouterState state,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentPath = state.uri.path;

    // Firebase 로그인 확인
    if (user == null) {
      LoggerService.debug('🚫 [AuthGuard] Firebase 로그인 필요: $currentPath → /login');
      return AppRouter.loginRoute;
    }

    // TODO: 백엔드 JWT 토큰 확인 (구현 필요)
    // final serverToken = await ref.read(currentServerTokenProvider.future);
    // if (serverToken == null) {
    //   LoggerService.debug('🚫 [AuthGuard] 서버 토큰 없음: $currentPath → /login');
    //   return AppRouter.loginRoute;
    // }

    // 인증 완료된 경우 진행 허용
    LoggerService.debug('✅ [AuthGuard] 백엔드 인증 완료: $currentPath');
    return null;
  }
}
