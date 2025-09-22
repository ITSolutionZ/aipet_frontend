import '../../../../shared/shared.dart';
import '../../data/services/auth_mode_service.dart';
import '../repositories/auth_repository.dart';

/// 로그인 UseCase
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// 이메일/비밀번호로 로그인
  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    try {
      if (AuthModeService.isMockMode) {
        // Mock 모드: 임시 사용자 생성
        AuthModeService.logTempLogin(email, '이메일 로그인');
        final tempUser = AuthModeService.createTempUser(email);
        return Result.success(
          AuthModeService.getTempLoginMessage('로그인'),
          tempUser,
        );
      }

      // 실제 로그인 로직
      // 입력 유효성 검사
      if (email.isEmpty || password.isEmpty) {
        return Result.failure('メールアドレスとパスワードを入力してください');
      }

      if (!_isValidEmail(email)) {
        return Result.failure('有効なメールアドレスを入力してください');
      }

      if (password.length < 6) {
        return Result.failure('パスワードは6文字以上で入力してください');
      }

      // Repository를 통한 로그인 실행
      final authResult = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('ログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('ログインに失敗しました: ${error.toString()}');
    }
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}
