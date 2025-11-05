import '../../../../shared/shared.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';


/// 로그인 UseCase
///
/// 개발 모드: 간단한 검증만 수행
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    // 개발 모드: 간단한 검증
    if (email.isEmpty || password.isEmpty) {
      return Result.failure('メールアドレスとパスワードを入力してください');
    }

    try {
      return await _repository.signInWithEmailAndPassword(email, password);
    } catch (error) {
      return Result.failure('ログインに失敗しました: ${error.toString()}');
    }
  }
}
