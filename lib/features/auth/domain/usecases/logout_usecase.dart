import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 로그아웃 UseCase
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// 로그아웃 실행
  Future<Result<void>> call() async {
    try {
      await _repository.signOut();
      return ResultFactory.success(null, 'ログアウトしました');
    } catch (error) {
      return ResultFactory.failure('ログアウトに失敗しました: ${error.toString()}');
    }
  }
}
