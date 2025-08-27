/// 인증 리포지토리 인터페이스
///
/// Firebase Auth 구현을 위한 추상화된 인터페이스입니다.
/// 추후 Mockito를 사용한 테스트와 실제 Firebase Auth 구현을 쉽게 전환할 수 있습니다.
abstract class AuthRepository {
  /// 이메일/비밀번호로 로그인
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);

  /// 이메일/비밀번호로 회원가입
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  /// 소셜 로그인 (Google)
  Future<AuthResult> signInWithGoogle();

  /// 소셜 로그인 (Apple)
  Future<AuthResult> signInWithApple();

  /// 소셜 로그인 (LINE)
  Future<AuthResult> signInWithLine();

  /// 로그아웃
  Future<void> signOut();

  /// 현재 사용자 상태 확인
  Future<AuthUser?> getCurrentUser();

  /// 비밀번호 재설정 이메일 발송
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증 메일 발송
  Future<void> sendEmailVerification();

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile({String? displayName, String? photoURL});

  /// 계정 삭제
  Future<void> deleteAccount();
}

/// 인증 결과
class AuthResult {
  final bool isSuccess;
  final String message;
  final AuthUser? user;
  final String? errorCode;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
    this.user,
    this.errorCode,
  });

  factory AuthResult.success(String message, {AuthUser? user}) {
    return AuthResult._(isSuccess: true, message: message, user: user);
  }

  factory AuthResult.failure(String message, {String? errorCode}) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      errorCode: errorCode,
    );
  }
}

/// 인증된 사용자 정보
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  final DateTime? lastSignInTime;
  final DateTime creationTime;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
    this.lastSignInTime,
    required this.creationTime,
  });

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isEmailVerified,
    DateTime? lastSignInTime,
    DateTime? creationTime,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
      creationTime: creationTime ?? this.creationTime,
    );
  }
}
