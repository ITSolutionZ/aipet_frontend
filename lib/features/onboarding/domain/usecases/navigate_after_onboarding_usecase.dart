import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
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
      // Business logic: Determine where to navigate after onboarding

      // For now, navigate to login screen
      // TODO: Check authentication status to determine route
      const targetRoute = AppRouter.loginRoute;

      return ResultFactory.success(targetRoute, '온보딩 완료 후 네비게이션이 준비되었습니다');
    } catch (e) {
      return ResultFactory.failure('네비게이션 설정 중 오류가 발생했습니다: $e');
    }
  }

  /// Navigate with BuildContext
  static Future<Result<void>> navigateWithContext(
    BuildContext context,
    String route,
  ) async {
    try {
      context.go(route);
      return ResultFactory.success(null, '네비게이션이 완료되었습니다');
    } catch (e) {
      return ResultFactory.failure('네비게이션 실행 중 오류가 발생했습니다: $e');
    }
  }
}
