/// 인증 폼의 UI 상태만 관리하는 클래스
///
/// 폼의 UI 상태와 사용자 입력을 관리합니다.
/// 보안상 민감한 정보(패스워드)는 저장하지 않고 UI 상태만 관리합니다.
/// 실제 인증 처리는 AuthRepository를 통해 수행됩니다.
class AuthFormState {
  /// 사용자 이메일 주소
  final String email;

  /// 사용자 이름/닉네임
  final String username;

  /// 로그인용 패스워드 (UI에서만 사용, 저장하지 않음)
  final String password;

  /// 패스워드 가시성 상태
  final bool isPasswordVisible;

  /// 확인 패스워드 가시성 상태
  final bool isConfirmPasswordVisible;

  /// 로그인 정보 기억하기 옵션
  final bool rememberMe;

  /// 로딩 상태
  final bool isLoading;

  /// 에러 메시지
  final String? error;

  const AuthFormState({
    this.email = '',
    this.username = '',
    this.password = '', // 기본값 추가
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.rememberMe = false,
    this.isLoading = false,
    this.error,
  });

  AuthFormState copyWith({
    String? email,
    String? username,
    String? password,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? rememberMe,
    bool? isLoading,
    String? error,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthFormState &&
        other.email == email &&
        other.username == username &&
        other.password == password &&
        other.isPasswordVisible == isPasswordVisible &&
        other.isConfirmPasswordVisible == isConfirmPasswordVisible &&
        other.rememberMe == rememberMe &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        username.hashCode ^
        password.hashCode ^
        isPasswordVisible.hashCode ^
        isConfirmPasswordVisible.hashCode ^
        rememberMe.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }
}
