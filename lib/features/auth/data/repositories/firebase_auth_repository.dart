import '../../domain/repositories/auth_repository.dart';

/// Firebase Auth 실제 구현체
class FirebaseAuthRepositoryImpl implements AuthRepository {
  // Firebase Auth 인스턴스는 현재 테스트 모드에서 사용하지 않음
  // 향후 실제 Firebase Auth 연동 시 활성화
  // FirebaseAuth? _firebaseAuth;

  // Firebase Auth 인스턴스는 현재 테스트 모드에서 사용하지 않음
  // 향후 실제 Firebase Auth 연동 시 활성화
  // FirebaseAuth get _auth {
  //   FirebaseManager.ensureInitialized();
  //   return _firebaseAuth ??= FirebaseAuth.instance;
  // }

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 테스트 모드: 간단한 검증만 수행 (1문자 이상이면 통과)
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('メールアドレスとパスワードを入力してください');
      }

      // 테스트 모드: Firebase Auth 호출 없이 Mock 사용자 생성
      final mockUser = AuthUser(
        uid: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        isEmailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
        // 테스트용 Mock 토큰 정보
        customData: {
          'accessToken':
              'test_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken':
              'test_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'firebaseUid':
              'test_firebase_uid_${DateTime.now().millisecondsSinceEpoch}',
          'isTestMode': true,
        },
      );

      return AuthResult.success('테스트 모드: 로그인 성공', user: mockUser);
    } catch (e) {
      return AuthResult.failure('로그인에 실패했습니다: $e');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 테스트 모드: 간단한 검증만 수행 (1문자 이상이면 통과)
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('メールアドレスとパスワードを入力してください');
      }

      // 테스트 모드: Firebase Auth 호출 없이 Mock 사용자 생성
      final mockUser = AuthUser(
        uid: 'test_new_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        isEmailVerified: false, // 새 사용자는 이메일 인증 필요
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
        // 테스트용 Mock 토큰 정보
        customData: {
          'accessToken':
              'test_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken':
              'test_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'firebaseUid':
              'test_firebase_uid_${DateTime.now().millisecondsSinceEpoch}',
          'isNewUser': true,
          'isTestMode': true,
        },
      );

      return AuthResult.success('테스트 모드: 회원가입 성공', user: mockUser);
    } catch (e) {
      return AuthResult.failure('회원가입에 실패했습니다: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      // 개발 중: 간단한 검증만 수행
      // 실제 Google Sign-In은 나중에 구현

      // 개발용 Mock Google 사용자 생성
      final mockUser = AuthUser(
        uid: 'dev_google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'dev_google_${DateTime.now().millisecondsSinceEpoch}@gmail.com',
        displayName: 'Google Dev User',
        photoURL: 'https://via.placeholder.com/150/4285f4/ffffff?text=G',
        isEmailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
        // 개발용 Mock 토큰 정보
        customData: {
          'accessToken':
              'dev_google_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken':
              'dev_google_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'firebaseUid':
              'dev_google_firebase_uid_${DateTime.now().millisecondsSinceEpoch}',
          'provider': 'google',
          'isDevMode': true,
        },
      );

      return AuthResult.success('開発モード: Google ログイン成功', user: mockUser);
    } catch (e) {
      return AuthResult.failure('Google ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      // 개발 중: 간단한 검증만 수행
      // 실제 Apple Sign-In은 나중에 구현

      // 개발용 Mock Apple 사용자 생성
      final mockUser = AuthUser(
        uid: 'dev_apple_user_${DateTime.now().millisecondsSinceEpoch}',
        email:
            'dev_apple_${DateTime.now().millisecondsSinceEpoch}@privaterelay.appleid.com',
        displayName: 'Apple Dev User',
        photoURL: 'https://via.placeholder.com/150/000000/ffffff?text=A',
        isEmailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
        // 개발용 Mock 토큰 정보
        customData: {
          'accessToken':
              'dev_apple_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken':
              'dev_apple_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'firebaseUid':
              'dev_apple_firebase_uid_${DateTime.now().millisecondsSinceEpoch}',
          'provider': 'apple',
          'isDevMode': true,
        },
      );

      return AuthResult.success('開発モード: Apple ログイン成功', user: mockUser);
    } catch (e) {
      return AuthResult.failure('Apple ログインに失敗しました');
    }
  }

  @override
  Future<AuthResult> signInWithLine() async {
    try {
      // 개발 중: 간단한 검증만 수행
      // 실제 LINE Sign-In은 나중에 구현

      // 개발용 Mock LINE 사용자 생성
      final mockUser = AuthUser(
        uid: 'dev_line_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'dev_line_${DateTime.now().millisecondsSinceEpoch}@line.me',
        displayName: 'LINE Dev User',
        photoURL: 'https://via.placeholder.com/150/00c300/ffffff?text=L',
        isEmailVerified: true,
        creationTime: DateTime.now(),
        lastSignInTime: DateTime.now(),
        // 개발용 Mock 토큰 정보
        customData: {
          'accessToken':
              'dev_line_access_token_${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken':
              'dev_line_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          'firebaseUid':
              'dev_line_firebase_uid_${DateTime.now().millisecondsSinceEpoch}',
          'provider': 'line',
          'isDevMode': true,
        },
      );

      return AuthResult.success('開発モード: LINE ログイン成功', user: mockUser);
    } catch (e) {
      return AuthResult.failure('LINE ログインに失敗しました');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // 개발 중: 간단한 로그아웃 처리
      // 실제 Firebase Auth 로그아웃은 나중에 구현
      await Future.delayed(_mockDelay);
    } catch (e) {
      // 로그아웃 실패는 무시
    }
  }

  // 개발 모드용 지연 시간 상수
  static const Duration _mockDelay = Duration(milliseconds: 500);

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      // 개발 중: Mock 사용자 정보 반환
      // 실제 Firebase Auth 사용자 정보는 나중에 구현
      return null; // 개발 중에는 항상 null 반환
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // 개발 중: 간단한 비밀번호 재설정 처리
      // 실제 Firebase Auth 비밀번호 재설정은 나중에 구현
      if (email.isEmpty) {
        throw Exception('メールアドレスを入力してください');
      }
      await Future.delayed(_mockDelay);
    } catch (e) {
      throw Exception('パスワードリセットに失敗しました');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      // 개발 중: 간단한 이메일 인증 처리
      // 실제 Firebase Auth 이메일 인증은 나중에 구현
      await Future.delayed(_mockDelay);
    } catch (e) {
      // 이메일 인증 실패는 무시
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      // 개발 중: 간단한 프로필 업데이트 처리
      // 실제 Firebase Auth 프로필 업데이트는 나중에 구현
      await Future.delayed(_mockDelay);
    } catch (e) {
      // 프로필 업데이트 실패는 무시
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      // 개발 중: 간단한 계정 삭제 처리
      // 실제 Firebase Auth 계정 삭제는 나중에 구현
      await Future.delayed(_mockDelay);
    } catch (e) {
      // 계정 삭제 실패는 무시
    }
  }

  // Firebase 사용자 매핑 메서드는 현재 테스트 모드에서 사용하지 않음
  // 향후 실제 Firebase Auth 연동 시 활성화
  // AuthUser _mapFirebaseUserToAuthUser(User firebaseUser) {
  //   return AuthUser(
  //     uid: firebaseUser.uid,
  //     email: firebaseUser.email ?? '',
  //     displayName: firebaseUser.displayName ?? '',
  //     photoURL: firebaseUser.photoURL,
  //     isEmailVerified: firebaseUser.emailVerified,
  //     creationTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
  //     lastSignInTime: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
  //   );
  // }
}
