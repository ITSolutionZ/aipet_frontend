import 'package:aipet_frontend/shared/core/domain/result.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

/// 통합 인증 Use Case
///
/// 다양한 인증 방법을 처리하는 중심 Use Case
class AuthenticateUseCase {
  final AuthRepository _repository;

  const AuthenticateUseCase(this._repository);

  /// 이메일/비밀번호 로그인
  Future<Result<AuthUser>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // 비즈니스 로직: 입력 유효성 검사
    final validation = _validateEmailPassword(email, password);
    if (!validation.isSuccess) {
      return Result.failure(validation.message);
    }

    try {
      return await _repository.signInWithEmailAndPassword(email, password);
    } catch (error) {
      return Result.failure('ログインに失敗しました: ${error.toString()}');
    }
  }

  /// 소셜 로그인 (통합)
  Future<Result<AuthUser>> loginWithSocial({
    required SocialProvider provider,
  }) async {
    try {
      switch (provider) {
        case SocialProvider.google:
          return await _repository.signInWithGoogle();
        case SocialProvider.apple:
          return await _repository.signInWithApple();
        case SocialProvider.line:
          return await _repository.signInWithLine();
        case SocialProvider.facebook:
          return Result.failure('Facebook ログインは現在サポートされていません');
        case SocialProvider.twitter:
          return Result.failure('Twitter ログインは現在サポートされていません');
      }
    } catch (error) {
      return Result.failure(
        '${provider.displayName}ログインに失敗しました: ${error.toString()}',
      );
    }
  }

  /// 회원가입
  Future<Result<AuthUser>> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    // 비즈니스 로직: 회원가입 유효성 검사
    final validation = _validateRegistration(email, password, confirmPassword);
    if (!validation.isSuccess) {
      return Result.failure(validation.message);
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

  /// 현재 사용자 조회
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      return Result.success('ユーザー情報を取得しました', user);
    } catch (error) {
      return Result.failure('ユーザー情報の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 인증 상태 확인
  Future<Result<bool>> isAuthenticated() async {
    try {
      final isAuth = await _repository.isAuthenticated();
      return Result.success('認証状態を確認しました', isAuth);
    } catch (error) {
      return Result.failure('認証状態の確認に失敗しました: ${error.toString()}');
    }
  }

  /// 로그아웃
  Future<Result<void>> logout() async {
    try {
      await _repository.signOut();
      return Result.success('ログアウトしました');
    } catch (error) {
      return Result.failure('ログアウトに失敗しました: ${error.toString()}');
    }
  }

  /// 비밀번호 재설정
  Future<Result<void>> resetPassword({required String email}) async {
    if (!_isValidEmail(email)) {
      return Result.failure('有効なメールアドレスを入力してください');
    }

    try {
      await _repository.sendPasswordResetEmail(email);
      return Result.success('パスワード再設定メールを送信しました');
    } catch (error) {
      return Result.failure('パスワード再設定メールの送信に失敗しました: ${error.toString()}');
    }
  }

  /// 이메일 인증 재송신
  Future<Result<void>> resendEmailVerification() async {
    try {
      await _repository.sendEmailVerification();
      return Result.success('確認メールを再送信しました');
    } catch (error) {
      return Result.failure('確認メールの再送信に失敗しました: ${error.toString()}');
    }
  }

  /// 사용자 프로필 업데이트
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _repository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      return Result.success('プロフィールを更新しました');
    } catch (error) {
      return Result.failure('プロフィールの更新に失敗しました: ${error.toString()}');
    }
  }

  /// 계정 삭제
  Future<Result<void>> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      return Result.success('アカウントを削除しました');
    } catch (error) {
      return Result.failure('アカウントの削除に失敗しました: ${error.toString()}');
    }
  }

  // Private helper methods

  /// 이메일/비밀번호 유효성 검사
  Result<void> _validateEmailPassword(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return Result.failure('メールアドレスとパスワードを入力してください');
    }

    if (!_isValidEmail(email)) {
      return Result.failure('有効なメールアドレスを入力してください');
    }

    if (password.length < 6) {
      return Result.failure('パスワードは6文字以上で入力してください');
    }

    return Result.success('検証完了');
  }

  /// 회원가입 유효성 검사
  Result<void> _validateRegistration(
    String email,
    String password,
    String confirmPassword,
  ) {
    final emailPasswordValidation = _validateEmailPassword(email, password);
    if (!emailPasswordValidation.isSuccess) {
      return emailPasswordValidation;
    }

    if (password != confirmPassword) {
      return Result.failure('パスワードが一致しません');
    }

    if (password.length < 8) {
      return Result.failure('パスワードは8文字以上で入力してください');
    }

    // 패스워드 강도 검사
    if (!_isStrongPassword(password)) {
      return Result.failure('パスワードは英数字と記号を含む必要があります');
    }

    return Result.success('検証完了');
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  /// 강한 패스워드 검사
  bool _isStrongPassword(String password) {
    // 최소 8자, 대소문자, 숫자, 특수문자 포함
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return password.length >= 8 &&
        hasUppercase &&
        hasLowercase &&
        hasDigits &&
        hasSpecialCharacters;
  }
}
