import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/auth/data/services/token_storage_service.dart';
import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ✅ Navigate after onboarding completion UseCase
///
/// Handles post-onboarding navigation with proper route determination
class NavigateAfterOnboardingUseCase extends BaseUseCaseNoParams<String> {
  const NavigateAfterOnboardingUseCase(super.repository);

  @override
  Future<Result<String>> call() async {
    try {
      // 인증 상태 확인하여 라우트 결정
      final isAuthenticated = await TokenStorageService.isAuthenticated();

      // 인증된 사용자: 홈 화면으로, 미인증: 로그인 화면으로
      final targetRoute = isAuthenticated
          ? AppRouter.homeRoute
          : AppRouter.loginRoute;

      return Result.success(targetRoute, '온보딩 완료 후 네비게이션이 준비되었습니다');
    } catch (e) {
      // 에러 발생 시 안전하게 로그인 화면으로
      return Result.success(AppRouter.loginRoute, '네비게이션 설정 중 오류가 발생했습니다: $e');
    }
  }

  /// Navigate with BuildContext
  static Future<Result<void>> navigateWithContext(
    BuildContext context,
    String route,
  ) async {
    try {
      context.go(route);
      return Result.success(null.toString(), '네비게이션이 완료되었습니다');
    } catch (e) {
      return Result.failure('네비게이션 실행 중 오류가 발생했습니다: $e');
    }
  }
}
