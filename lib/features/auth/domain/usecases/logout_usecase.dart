import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/auth_repository.dart';

/// 로그아웃 UseCase
///
/// 개발 모드: 로컬 상태만 초기화
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<void>> call() async {
    try {
      await _repository.signOut();
      return Result.success('ログアウトが完了しました');
    } catch (error) {
      return Result.failure('ログアウトに失敗しました: ${error.toString()}');
    }
  }
}
