import 'package:flutter/foundation.dart';

import '../../../../shared/shared.dart';
import '../repositories/auth_repository.dart';

/// 로그인 UseCase
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// 이메일/비밀번호로 로그인
  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: 개발 완료 후 삭제할 임시 로그인 우회 로직
      // 현재는 아무 입력값이나 넣어도 로그인 성공 처리
      debugPrint('🚨 LoginUseCase: 임시 로그인 우회 - 이메일: $email');

      // 임시로 성공 처리 (Mock 사용자 생성)
      final now = DateTime.now();
      final mockUser = AuthUser(
        uid: 'temp_user_${now.millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0], // 이메일에서 사용자명 추출
        isEmailVerified: true,
        creationTime: now,
        lastSignInTime: now,
        customData: {
          'isTempLogin': true,
          'tempLoginTime': now.toIso8601String(),
        },
      );

      return Result.success('임시 로그인이 완료되었습니다', mockUser);

      /*
      // 실제 로그인 로직 (개발 완료 후 활성화)
      // 입력 유효성 검사
      if (email.isEmpty || password.isEmpty) {
        return Result.failure('メールアドレスとパスワードを入力してください');
      }

      if (!_isValidEmail(email)) {
        return Result.failure('有効なメールアドレスを入力してください');
      }

      if (password.length < 6) {
        return Result.failure('パスワードは6文字以上で入力してください');
      }

      // Repository를 통한 로그인 실행
      final authResult = await _repository.signInWithEmailAndPassword(email, password);

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('ログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
      */
    } catch (error) {
      return Result.failure('ログインに失敗しました: ${error.toString()}');
    }
  }

  /// 소셜 로그인 (Google)
  Future<Result<AuthUser>> loginWithGoogle() async {
    try {
      final authResult = await _repository.signInWithGoogle();

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('Googleログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('Googleログインに失敗しました: ${error.toString()}');
    }
  }

  /// 소셜 로그인 (Apple)
  Future<Result<AuthUser>> loginWithApple() async {
    try {
      final authResult = await _repository.signInWithApple();

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('Appleログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('Appleログインに失敗しました: ${error.toString()}');
    }
  }

  /// 소셜 로그인 (LINE)
  Future<Result<AuthUser>> loginWithLine() async {
    try {
      final authResult = await _repository.signInWithLine();

      if (authResult.isSuccess && authResult.user != null) {
        return Result.success('LINEログインが完了しました', authResult.user!);
      } else {
        return Result.failure(authResult.message);
      }
    } catch (error) {
      return Result.failure('LINEログインに失敗しました: ${error.toString()}');
    }
  }
}
