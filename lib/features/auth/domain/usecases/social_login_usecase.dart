import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 🎯 소셜 로그인 UseCase
///
/// 모든 소셜 로그인을 통합 관리
class SocialLoginUseCase {
  final AuthRepository _repository;

  const SocialLoginUseCase(this._repository);

  /// Google 로그인
  ///
  /// Google Sign-In을 통한 로그인을 수행합니다.
  ///
  /// Returns: 로그인 결과 (성공 시 AuthUser 포함)
  Future<Result<AuthUser>> loginWithGoogle() async {
    try {
      // Firebase Google 로그인
      final authResult = await _repository.signInWithGoogle();

      if (authResult.isSuccess && authResult.dataOrNull != null) {
        return Result.success(
          authResult.dataOrNull!,
          'Googleログインが完了しました',
        );
      } else {
        return Result.failure(
          authResult.errorOrNull ?? 'Googleログインに失敗しました',
        );
      }
    } catch (error) {
      return Result.failure('Googleログインに失敗しました: ${error.toString()}');
    }
  }

  /// Apple 로그인
  ///
  /// Apple Sign-In을 통한 로그인을 수행합니다.
  ///
  /// Returns: 로그인 결과 (성공 시 AuthUser 포함)
  Future<Result<AuthUser>> loginWithApple() async {
    try {
      // Firebase Apple 로그인
      final authResult = await _repository.signInWithApple();

      if (authResult.isSuccess && authResult.dataOrNull != null) {
        return Result.success(
          authResult.dataOrNull!,
          'Appleログインが完了しました',
        );
      } else {
        return Result.failure(
          authResult.errorOrNull ?? 'Appleログインに失敗しました',
        );
      }
    } catch (error) {
      return Result.failure('Appleログインに失敗しました: ${error.toString()}');
    }
  }

  /// LINE 로그인
  ///
  /// LINE OAuth 2.0을 통한 로그인을 수행합니다.
  ///
  /// Returns: 로그인 결과 (성공 시 AuthUser 포함)
  Future<Result<AuthUser>> loginWithLine() async {
    try {
      // Firebase + LINE OAuth 로그인
      final authResult = await _repository.signInWithLine();

      if (authResult.isSuccess && authResult.dataOrNull != null) {
        return Result.success(authResult.dataOrNull!, 'LINEログインが完了しました');
      } else {
        return Result.failure(
          authResult.errorOrNull ?? 'LINEログインに失敗しました',
        );
      }
    } catch (error) {
      return Result.failure('LINEログインに失敗しました: ${error.toString()}');
    }
  }
}
