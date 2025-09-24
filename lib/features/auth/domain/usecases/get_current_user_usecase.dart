import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 현재 사용자 정보 가져오기 UseCase
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  /// 현재 로그인된 사용자 정보 가져오기
  Future<Result<AuthUser?>> call() async {
    try {
      final user = await _repository.getCurrentUser();

      if (user != null) {
        return Result.success('ユーザー情報を取得しました', user);
      } else {
        return Result.success('ログインしていません', null);
      }
    } catch (error) {
      return Result.failure('ユーザー情報の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 사용자가 로그인되어 있는지 확인
  Future<Result<bool>> isLoggedIn() async {
    try {
      final user = await _repository.getCurrentUser();
      return Result.success('ログイン状態を確認しました', user != null);
    } catch (error) {
      return Result.failure('ログイン状態の確認に失敗しました: ${error.toString()}');
    }
  }

  /// 이메일 인증 상태 확인
  Future<Result<bool>> isEmailVerified() async {
    try {
      final user = await _repository.getCurrentUser();

      if (user != null) {
        return Result.success('メール認証状態を確認しました', user.isEmailVerified);
      } else {
        return Result.failure('ログインしていません');
      }
    } catch (error) {
      return Result.failure('メール認証状態の確認に失敗しました: ${error.toString()}');
    }
  }
}
