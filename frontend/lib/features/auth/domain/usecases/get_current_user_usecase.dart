import '../../../../shared/shared.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';


/// 현재 사용자 조회 UseCase
///
/// 개발 모드: 로컬 상태 반환
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<AuthUser?>> call() async {
    try {
      final user = await _repository.getCurrentUser();
      return Result.success('ユーザー情報を取得しました', user);
    } catch (error) {
      return Result.failure('ユーザー情報の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 로그인 상태 확인
  Future<Result<bool>> isLoggedIn() async {
    try {
      final isAuth = await _repository.isAuthenticated();
      return Result.success('認証状態を確認しました', isAuth);
    } catch (error) {
      return Result.failure('認証状態の確認に失敗しました: ${error.toString()}');
    }
  }

  /// 이메일 인증 상태 확인
  Future<Result<bool>> isEmailVerified() async {
    try {
      final user = await _repository.getCurrentUser();
      return Result.success('メール認証状態を確認しました', user?.isEmailVerified ?? false);
    } catch (error) {
      return Result.failure('メール認証状態の確認に失敗しました: ${error.toString()}');
    }
  }
}
