import '../../../../shared/shared.dart';
import '../../data/services/auth_mode_service.dart';
import '../repositories/auth_repository.dart';

/// 🎯 소셜 로그인 UseCase
///
/// 모든 소셜 로그인을 통합 관리
class SocialLoginUseCase {
  final AuthRepository _repository;

  const SocialLoginUseCase(this._repository);

  /// Google 로그인
  Future<Result<AuthUser>> loginWithGoogle() async {
    try {
      if (AuthModeService.isMockMode) {
        // Mock 모드: 임시 사용자 생성
        AuthModeService.logTempLogin('google@example.com', 'Google 로그인');
        final tempUser = AuthModeService.createTempSocialUser(
          'google',
          'google@example.com',
        );
        return Result.success(
          AuthModeService.getTempSocialLoginMessage('Google'),
          tempUser,
        );
      }

      // 실제 Firebase Google 로그인
      final authResult = await _repository.signInWithGoogle();

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('Googleログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('Googleログインに失敗しました: ${error.toString()}');
    }
  }

  /// Apple 로그인
  Future<Result<AuthUser>> loginWithApple() async {
    try {
      if (AuthModeService.isMockMode) {
        // Mock 모드: 임시 사용자 생성
        AuthModeService.logTempLogin('apple@example.com', 'Apple 로그인');
        final tempUser = AuthModeService.createTempSocialUser(
          'apple',
          'apple@example.com',
        );
        return Result.success(
          AuthModeService.getTempSocialLoginMessage('Apple'),
          tempUser,
        );
      }

      // 실제 Firebase Apple 로그인
      final authResult = await _repository.signInWithApple();

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('Appleログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('Appleログインに失敗しました: ${error.toString()}');
    }
  }

  /// LINE 로그인
  Future<Result<AuthUser>> loginWithLine() async {
    try {
      if (AuthModeService.isMockMode) {
        // Mock 모드: 임시 사용자 생성
        AuthModeService.logTempLogin('line@example.com', 'LINE 로그인');
        final tempUser = AuthModeService.createTempSocialUser(
          'line',
          'line@example.com',
        );
        return Result.success(
          AuthModeService.getTempSocialLoginMessage('LINE'),
          tempUser,
        );
      }

      // 실제 Firebase + LINE OAuth 로그인
      final authResult = await _repository.signInWithLine();

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('LINEログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('LINEログインに失敗しました: ${error.toString()}');
    }
  }
}
