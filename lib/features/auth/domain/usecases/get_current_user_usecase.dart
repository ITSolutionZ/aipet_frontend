import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
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
        return ResultFactory.success(user, 'ユーザー情報を取得しました');
      } else {
        return ResultFactory.success(null, 'ログインしていません');
      }
    } catch (error) {
      return ResultFactory.failure('ユーザー情報の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 사용자가 로그인되어 있는지 확인
  Future<Result<bool>> isLoggedIn() async {
    try {
      final user = await _repository.getCurrentUser();
      return ResultFactory.success(user != null, 'ログイン状態を確認しました');
    } catch (error) {
      return ResultFactory.failure('ログイン状態の確認に失敗しました: ${error.toString()}');
    }
  }

  /// 이메일 인증 상태 확인
  Future<Result<bool>> isEmailVerified() async {
    try {
      final user = await _repository.getCurrentUser();

      if (user != null) {
        return ResultFactory.success(user.isEmailVerified, 'メール認証状態を確認しました');
      } else {
        return ResultFactory.failure('ログインしていません');
      }
    } catch (error) {
      return ResultFactory.failure('メール認証状態の確認に失敗しました: ${error.toString()}');
    }
  }
}
