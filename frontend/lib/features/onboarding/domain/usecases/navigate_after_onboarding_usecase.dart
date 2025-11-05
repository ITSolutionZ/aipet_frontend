import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../../../app/router/app_router.dart';
import '../../../../../features/auth/auth.dart';
import '../repositories/onboarding_repository.dart';


/// ✅ Navigate after onboarding completion UseCase
///
/// Handles post-onboarding navigation with proper route determination
class NavigateAfterOnboardingUseCase
    extends RepositoryUseCaseNoParams<String, OnboardingRepository> {
  NavigateAfterOnboardingUseCase(super.repository);

  @override
  String get operationName => '온보딩 완료 후 네비게이션';

  @override
  Future<Result<String>> execute() async {
    // 인증 상태 확인하여 라우트 결정
    final isAuthenticated = await TokenStorageService.isAuthenticated();

    // 인증된 사용자: 홈 화면으로, 미인증: 로그인 화면으로
    final targetRoute = isAuthenticated
        ? AppRouter.homeRoute
        : AppRouter.loginRoute;

    return Result.success('온보딩 완료. 다음 화면: $targetRoute', targetRoute);
  }
}

/// ✅ Navigate using BuildContext after onboarding UseCase
///
/// Actual navigation execution with context
class NavigateWithContextUseCase {
  static Future<void> execute(BuildContext context, String route) async {
    if (context.mounted) {
      context.go(route);
    }
  }
}
