import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/onboarding_repository.dart';

/// ✅ Navigate to next onboarding page UseCase
///
/// Handles page progression with validation and state management
class NextPageUseCase
    extends RepositoryUseCaseNoParams<void, OnboardingRepository> {
  NextPageUseCase(super.repository);

  @override
  String get operationName => '다음 페이지 이동';

  @override
  Future<Result<void>> execute() async {
    // Business logic: Save progress before moving to next page
    final stateResult = await repository.loadOnboardingState();
    if (!stateResult.isSuccess) {
      return Result.failure('현재 상태를 로드할 수 없습니다');
    }

    final currentState = stateResult.dataOrNull!;
    final nextPage = currentState.currentPage + 1;

    // Save progress
    final saveResult = await repository.saveOnboardingProgress(nextPage);
    if (!saveResult.isSuccess) {
      return saveResult;
    }

    return Result.success('다음 페이지로 이동했습니다', null);
  }
}

/// ✅ Navigate to previous onboarding page UseCase
class PreviousPageUseCase
    extends RepositoryUseCaseNoParams<void, OnboardingRepository> {
  PreviousPageUseCase(super.repository);

  @override
  String get operationName => '이전 페이지 이동';

  @override
  Future<Result<void>> execute() async {
    // Business logic: Save progress before moving to previous page
    final stateResult = await repository.loadOnboardingState();
    if (!stateResult.isSuccess) {
      return Result.failure('현재 상태를 로드할 수 없습니다');
    }

    final currentState = stateResult.dataOrNull!;
    if (currentState.currentPage <= 0) {
      return Result.failure('첫 번째 페이지입니다');
    }

    final previousPage = currentState.currentPage - 1;

    // Save progress
    final saveResult = await repository.saveOnboardingProgress(previousPage);
    if (!saveResult.isSuccess) {
      return saveResult;
    }

    return Result.success('이전 페이지로 이동했습니다', null);
  }
}

/// ✅ Navigate to specific onboarding page UseCase
class GoToPageUseCase
    extends RepositoryUseCase<void, int, OnboardingRepository> {
  GoToPageUseCase(super.repository);

  @override
  String get operationName => '페이지 이동';

  @override
  Future<Result<void>> execute(int targetPage) async {
    if (targetPage < 0) {
      return Result.failure('유효하지 않은 페이지입니다');
    }

    // Save progress
    final saveResult = await repository.saveOnboardingProgress(targetPage);
    if (!saveResult.isSuccess) {
      return saveResult;
    }

    return Result.success('페이지 $targetPage로 이동했습니다', null);
  }
}
