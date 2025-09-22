import '../../domain/domain.dart';

/// Firebase Auth Mock 구현체
///
/// 실제 Firebase Auth 연동 전까지 사용하는 Mock 구현체입니다.
/// 개발 환경에서 간단한 인증 로직을 제공합니다.
class FirebaseAuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Mock 로그인 검증
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('メールアドレスとパスワードを入力してください');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('有効なメールアドレスを入力してください');
      }

      if (password.length < 6) {
        return AuthResult.failure('パスワードは6文字以上で入力してください');
      }

      // Mock 사용자 생성
      final user = _createMockUser(email);

      return AuthResult.success('ログインが完了しました', user: user);
    } catch (e) {
      return AuthResult.failure('ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Mock 회원가입 검증
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('メールアドレスとパスワードを入力してください');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('有効なメールアドレスを入力してください');
      }

      if (password.length < 8) {
        return AuthResult.failure('パスワードは8文字以上で入力してください');
      }

      // Mock 사용자 생성
      final user = _createMockUser(email, isEmailVerified: false);

      return AuthResult.success('会員登録が完了しました。確認メールを送信しました。', user: user);
    } catch (e) {
      return AuthResult.failure('会員登録に失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Mock Google 로그인
      final user = _createMockUser('user@gmail.com', displayName: 'Google User');

      return AuthResult.success('Googleログインが完了しました', user: user);
    } catch (e) {
      return AuthResult.failure('Googleログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      // Mock Apple 로그인
      final user = _createMockUser('user@privaterelay.appleid.com', displayName: 'Apple User');

      return AuthResult.success('Appleログインが完了しました', user: user);
    } catch (e) {
      return AuthResult.failure('Appleログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithLine() async {
    try {
      // Mock LINE 로그인
      final user = _createMockUser('user@line.me', displayName: 'LINE User');

      return AuthResult.success('LINEログインが完了しました', user: user);
    } catch (e) {
      return AuthResult.failure('LINEログインに失敗しました: $e');
    }
  }

  @override
  Future<void> signOut() async {
    // Mock 로그아웃 - 실제로는 Firebase Auth에서 로그아웃
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    // Mock 현재 사용자 - 실제로는 Firebase Auth에서 가져옴
    // 개발 중에는 항상 null 반환 (로그인되지 않은 상태)
    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Mock 비밀번호 재설정 이메일 발송
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_isValidEmail(email)) {
      throw Exception('有効なメールアドレスを入力してください');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    // Mock 이메일 인증 메일 발송
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    // Mock 프로필 업데이트
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteAccount() async {
    // Mock 계정 삭제
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 이메일 유효성 검사
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Mock 사용자 생성
  AuthUser _createMockUser(
    String email, {
    String? displayName,
    bool isEmailVerified = true,
  }) {
    final now = DateTime.now();
    return AuthUser(
      uid: 'mock_${email.hashCode}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      isEmailVerified: isEmailVerified,
      creationTime: now,
      lastSignInTime: now,
      customData: {
        'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        'tokenType': 'Bearer',
        'firebaseUid': 'mock_firebase_${email.hashCode}',
      },
    );
  }
}