import '../../../../shared/shared.dart';
import '../repositories/auth_repository.dart';

/// 로그아웃 UseCase
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// 로그아웃 실행
  Future<Result<void>> call() async {
    try {
      await _repository.signOut();
      return Result.success('ログアウトしました');
    } catch (error) {
      return Result.failure('ログアウトに失敗しました: ${error.toString()}');
    }
  }
}