import 'package:aipet_frontend/shared/shared.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

/// 소셜 로그인 UseCase
///
/// 개발 모드: Mock 구현 (추후 Firebase Auth 연동)
class SocialLoginUseCase {
  final AuthRepository _repository;

  SocialLoginUseCase(this._repository);

  Future<Result<AuthUser>> loginWithGoogle() async {
    try {
      return await _repository.signInWithGoogle();
    } catch (error) {
      return Result.failure('Googleログインに失敗しました: ${error.toString()}');
    }
  }

  Future<Result<AuthUser>> loginWithApple() async {
    try {
      return await _repository.signInWithApple();
    } catch (error) {
      return Result.failure('Appleログインに失敗しました: ${error.toString()}');
    }
  }

  Future<Result<AuthUser>> loginWithLine() async {
    try {
      return await _repository.signInWithLine();
    } catch (error) {
      return Result.failure('LINEログインに失敗しました: ${error.toString()}');
    }
  }
}
