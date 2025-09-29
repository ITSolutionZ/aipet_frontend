import 'package:aipet_frontend/features/onboarding/domain/usecases/base_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// ✅ Navigate to next onboarding page UseCase
///
/// Handles page progression with validation and state management
class NextPageUseCase extends BaseUseCaseNoParams<void> {
  const NextPageUseCase(super.repository);

  @override
  Future<Result<void>> call() async {
    try {
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

      return Result.success(null, '다음 페이지로 이동했습니다');
    } catch (e) {
      return Result.failure('페이지 이동 중 오류가 발생했습니다: $e');
    }
  }
}

/// ✅ Navigate to previous onboarding page UseCase
class PreviousPageUseCase extends BaseUseCaseNoParams<void> {
  const PreviousPageUseCase(super.repository);

  @override
  Future<Result<void>> call() async {
    try {
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

      return Result.success(null, '이전 페이지로 이동했습니다');
    } catch (e) {
      return Result.failure('페이지 이동 중 오류가 발생했습니다: $e');
    }
  }
}

/// ✅ Navigate to specific onboarding page UseCase
class GoToPageUseCase extends BaseUseCase<void, int> {
  const GoToPageUseCase(super.repository);

  @override
  Future<Result<void>> call(int targetPage) async {
    try {
      if (targetPage < 0) {
        return Result.failure('유효하지 않은 페이지입니다');
      }

      // Save progress
      final saveResult = await repository.saveOnboardingProgress(targetPage);
      if (!saveResult.isSuccess) {
        return saveResult;
      }

      return Result.success(null, '페이지 $targetPage로 이동했습니다');
    } catch (e) {
      return Result.failure('페이지 이동 중 오류가 발생했습니다: $e');
    }
  }
}
