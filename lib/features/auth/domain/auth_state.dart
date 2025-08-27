class AuthState {
  final String email;
  final String password;
  final String confirmPassword;
  final String username;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool rememberMe;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.username = '',
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.rememberMe = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? username,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? rememberMe,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      username: username ?? this.username,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.email == email &&
        other.password == password &&
        other.confirmPassword == confirmPassword &&
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
        password.hashCode ^
        confirmPassword.hashCode ^
        username.hashCode ^
        isPasswordVisible.hashCode ^
        isConfirmPasswordVisible.hashCode ^
        rememberMe.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
  }
}
