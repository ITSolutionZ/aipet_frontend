import '../../../../shared/shared.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';


/// 회원가입 UseCase
///
/// 개발 모드: 간단한 검증만 수행
class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    // 개발 모드: 간단한 검증
    if (email.isEmpty || password.isEmpty) {
      return Result.failure('メールアドレスとパスワードを入力してください');
    }

    if (password != confirmPassword) {
      return Result.failure('パスワードが一致しません');
    }

    try {
      final result = await _repository.createUserWithEmailAndPassword(
        email,
        password,
      );

      // 회원가입 성공 시 프로필 업데이트
      if (result.isSuccess && displayName != null && displayName.isNotEmpty) {
        await _repository.updateUserProfile(displayName: displayName);
      }

      return result;
    } catch (error) {
      return Result.failure('会員登録に失敗しました: ${error.toString()}');
    }
  }
}
