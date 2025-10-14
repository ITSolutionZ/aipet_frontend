import 'package:aipet_frontend/features/auth/domain/entities/auth_entities.dart';
import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';

/// 🎯 로컬 전용 AuthRepository 구현체 (개발 모드)
///
/// Firebase Auth 없이 로컬에서만 동작하는 간단한 인증 시스템
/// 개발 중에는 이 구현체를 사용하고, 프로덕션에서는 FirebaseAuthRealImpl 사용
class LocalAuthImpl implements AuthRepository {
  // 메모리에 저장되는 Mock 사용자 데이터
  AuthUser? _currentUser;
  final Map<String, String> _userPasswords = {};
  String? _serverToken;

  /// 이메일/비밀번호로 로그인 (개발 모드: 간단한 검증만)
  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

    if (email.isEmpty || password.isEmpty) {
      return Result.failure('メールアドレスとパスワードを入力してください');
    }

    // 개발 모드: 모든 입력을 허용
    final user = AuthUser(
      uid: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0],
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'isLocalAuth': true},
    );

    _currentUser = user;
    _userPasswords[email] = password;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] ログイン成功: $email');
    }

    return Result.success('ログインが完了しました', user);
  }

  /// 이메일/비밀번호로 회원가입 (개발 모드)
  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.isEmpty || password.isEmpty) {
      return Result.failure('メールアドレスとパスワードを入力してください');
    }

    final user = AuthUser(
      uid: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0],
      isEmailVerified: false, // 회원가입 시에는 미인증
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'isLocalAuth': true},
    );

    _currentUser = user;
    _userPasswords[email] = password;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] 会員登録成功: $email');
    }

    return Result.success('会員登録が完了しました', user);
  }

  /// Google 로그인 (개발 모드: Mock)
  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = AuthUser(
      uid: 'local_google_${DateTime.now().millisecondsSinceEpoch}',
      email: 'google.user@gmail.com',
      displayName: 'Google User',
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'provider': 'google', 'isLocalAuth': true},
    );

    _currentUser = user;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] Googleログイン成功');
    }

    return Result.success('Googleログインが完了しました', user);
  }

  /// Apple 로그인 (개발 모드: Mock)
  @override
  Future<Result<AuthUser>> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = AuthUser(
      uid: 'local_apple_${DateTime.now().millisecondsSinceEpoch}',
      email: 'apple.user@privaterelay.appleid.com',
      displayName: 'Apple User',
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'provider': 'apple', 'isLocalAuth': true},
    );

    _currentUser = user;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] Appleログイン成功');
    }

    return Result.success('Appleログインが完了しました', user);
  }

  /// LINE 로그인 (개발 모드: Mock)
  @override
  Future<Result<AuthUser>> signInWithLine() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = AuthUser(
      uid: 'local_line_${DateTime.now().millisecondsSinceEpoch}',
      email: 'line.user@line.me',
      displayName: 'LINE User',
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'provider': 'line', 'isLocalAuth': true},
    );

    _currentUser = user;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] LINEログイン成功');
    }

    return Result.success('LINEログインが完了しました', user);
  }

  /// 로그아웃
  @override
  Future<void> signOut() async {
    _currentUser = null;
    _serverToken = null;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] ログアウト完了');
    }
  }

  /// 현재 사용자 조회
  @override
  Future<AuthUser?> getCurrentUser() async {
    return _currentUser;
  }

  /// 비밀번호 재설정 (개발 모드: 시뮬레이션만)
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] パスワードリセットメール送信 (Mock): $email');
    }
  }

  /// 이메일 인증 메일 발송 (개발 모드: 시뮬레이션만)
  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] 確認メール送信 (Mock)');
    }
  }

  /// 사용자 프로필 업데이트
  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (kDebugMode) {
        debugPrint('🔐 [LocalAuth] プロフィール更新完了');
      }
    }
  }

  /// 계정 삭제
  @override
  Future<void> deleteAccount() async {
    if (_currentUser != null && _currentUser!.email != null) {
      _userPasswords.remove(_currentUser!.email);
      _currentUser = null;

      if (kDebugMode) {
        debugPrint('🔐 [LocalAuth] アカウント削除完了');
      }
    }
  }

  /// 서버 토큰 교환 (개발 모드: Mock 토큰 생성)
  @override
  Future<String> exchangeServerToken(String idToken) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockToken =
        'local_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    _serverToken = mockToken;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] サーバートークン交換完了 (Mock)');
    }

    return mockToken;
  }

  /// 현재 사용자 ID 토큰 조회 (개발 모드: Mock)
  @override
  Future<String?> getCurrentUserIdToken() async {
    if (_currentUser == null) return null;

    return 'local_id_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 저장된 서버 토큰 조회
  @override
  Future<String?> getStoredServerToken() async {
    return _serverToken;
  }

  /// 서버 토큰 저장
  @override
  Future<void> saveServerToken(String token, {int expiresInHours = 24}) async {
    _serverToken = token;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] サーバートークン保存完了');
    }
  }

  /// 서버 토큰 삭제
  @override
  Future<void> clearServerToken() async {
    _serverToken = null;

    if (kDebugMode) {
      debugPrint('🔐 [LocalAuth] サーバートークン削除完了');
    }
  }

  /// 인증 상태 확인
  @override
  Future<bool> isAuthenticated() async {
    return _currentUser != null && _serverToken != null;
  }
}
