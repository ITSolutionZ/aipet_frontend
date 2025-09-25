import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 로그인 UseCase
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// 이메일/비밀번호로 로그인
  ///
  /// [email] 사용자 이메일 주소
  /// [password] 사용자 비밀번호
  ///
  /// Returns: 로그인 결과 (성공 시 AuthUser 포함)
  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    try {
      // 입력 유효성 검사
      if (email.isEmpty || password.isEmpty) {
        return ResultFactory.failure('メールアドレスとパスワードを入力してください');
      }

      if (!_isValidEmail(email)) {
        return ResultFactory.failure('有効なメールアドレスを入力してください');
      }

      if (password.length < 6) {
        return ResultFactory.failure('パスワードは6文字以上で入力してください');
      }

      // Repository를 통한 로그인 실행
      final authResult = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      if (authResult.isSuccess && authResult.dataOrNull != null) {
        return ResultFactory.success(authResult.dataOrNull!, 'ログインが完了しました');
      } else {
        return ResultFactory.failure(authResult.errorOrNull ?? 'ログインに失敗しました');
      }
    } catch (error) {
      return ResultFactory.failure('ログインに失敗しました: ${error.toString()}');
    }
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }
}
