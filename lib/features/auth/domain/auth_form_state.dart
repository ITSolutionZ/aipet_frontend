/// 인증 폼의 UI 상태만 관리하는 클래스
/// 민감한 정보(패스워드)는 저장하지 않고 UI 상태만 관리
class AuthFormState {
  final String email;
  final String username;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool rememberMe;
  final bool isLoading;
  final String? error;

  const AuthFormState({
    this.email = '',
    this.username = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.rememberMe = false,
    this.isLoading = false,
    this.error,
  });

  AuthFormState copyWith({
    String? email,
    String? username,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? rememberMe,
    bool? isLoading,
    String? error,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      username: username ?? this.username,
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
        isPasswordVisible.hashCode ^
        isConfirmPasswordVisible.hashCode ^
        rememberMe.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }
}