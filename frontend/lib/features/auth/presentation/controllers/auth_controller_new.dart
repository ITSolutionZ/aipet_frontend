import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/authenticate_usecase.dart';
import '../../domain/usecases/session_management_usecase.dart';


/// 인증 상태
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;
  final AuthenticationStatus status;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.status = AuthenticationStatus.unauthenticated,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? errorMessage,
    AuthenticationStatus? status,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      status: status ?? this.status,
    );
  }
}

/// 인증 컨트롤러 (Clean Architecture 적용)
class CleanAuthController extends Notifier<AuthState> {
  late final AuthenticateUseCase _authenticateUseCase;
  late final SessionManagementUseCase _sessionManagementUseCase;

  @override
  AuthState build() {
    // provider를 통해 의존성 주입 (이 부분은 provider에서 처리해야 함)
    return const AuthState();
  }

  /// 초기화 - 현재 세션 상태 확인
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      final sessionResult = await _sessionManagementUseCase.getSessionStatus();
      if (sessionResult.isSuccess) {
        final status =
            sessionResult.dataOrNull ?? AuthenticationStatus.unauthenticated;

        if (status == AuthenticationStatus.authenticated) {
          final userResult = await _authenticateUseCase.getCurrentUser();
          if (userResult.isSuccess && userResult.dataOrNull != null) {
            state = state.copyWith(
              user: userResult.dataOrNull,
              status: AuthenticationStatus.authenticated,
              isLoading: false,
            );
            return;
          }
        }
      }

      state = state.copyWith(
        status: AuthenticationStatus.unauthenticated,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: 'セッション状態の確認に失敗しました',
        isLoading: false,
      );
    }
  }

  /// 이메일/비밀번호 로그인
  Future<Result<AuthUser>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.loginWithEmailPassword(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        state = state.copyWith(
          user: result.dataOrNull,
          status: AuthenticationStatus.authenticated,
          isLoading: false,
        );
        return result;
      } else {
        state = state.copyWith(errorMessage: result.message, isLoading: false);
        return result;
      }
    } catch (error) {
      final errorMessage = 'ログインに失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 소셜 로그인
  Future<Result<AuthUser>> loginWithSocial({
    required SocialProvider provider,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.loginWithSocial(
        provider: provider,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        state = state.copyWith(
          user: result.dataOrNull,
          status: AuthenticationStatus.authenticated,
          isLoading: false,
        );
        return result;
      } else {
        state = state.copyWith(errorMessage: result.message, isLoading: false);
        return result;
      }
    } catch (error) {
      final errorMessage =
          '${provider.displayName}ログインに失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 회원가입
  Future<Result<AuthUser>> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        displayName: displayName,
      );

      if (result.isSuccess && result.dataOrNull != null) {
        state = state.copyWith(
          user: result.dataOrNull,
          status: AuthenticationStatus.authenticated,
          isLoading: false,
        );
        return result;
      } else {
        state = state.copyWith(errorMessage: result.message, isLoading: false);
        return result;
      }
    } catch (error) {
      final errorMessage = '会員登録に失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 로그아웃
  Future<Result<void>> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.logout();

      if (result.isSuccess) {
        state = state.copyWith(
          user: null,
          status: AuthenticationStatus.unauthenticated,
          isLoading: false,
        );
        return result;
      } else {
        state = state.copyWith(errorMessage: result.message, isLoading: false);
        return result;
      }
    } catch (error) {
      final errorMessage = 'ログアウトに失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 비밀번호 재설정
  Future<Result<void>> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.resetPassword(email: email);

      state = state.copyWith(
        errorMessage: result.isSuccess ? null : result.message,
        isLoading: false,
      );

      return result;
    } catch (error) {
      final errorMessage = 'パスワード再設定に失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 이메일 인증 재송신
  Future<Result<void>> resendEmailVerification() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.resendEmailVerification();

      state = state.copyWith(
        errorMessage: result.isSuccess ? null : result.message,
        isLoading: false,
      );

      return result;
    } catch (error) {
      final errorMessage = '確認メール再送信に失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 프로필 업데이트
  Future<Result<void>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (result.isSuccess && state.user != null) {
        // 로컬 상태 업데이트
        final updatedUser = state.user!.copyWith(
          displayName: displayName,
          photoURL: photoURL,
        );

        state = state.copyWith(user: updatedUser, isLoading: false);
      } else {
        state = state.copyWith(errorMessage: result.message, isLoading: false);
      }

      return result;
    } catch (error) {
      final errorMessage = 'プロフィール更新に失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 계정 삭제
  Future<Result<void>> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _authenticateUseCase.deleteAccount();

      if (result.isSuccess) {
        state = state.copyWith(
          user: null,
          status: AuthenticationStatus.unauthenticated,
          isLoading: false,
        );
      } else {
        state = state.copyWith(errorMessage: result.message, isLoading: false);
      }

      return result;
    } catch (error) {
      final errorMessage = 'アカウント削除に失敗しました: ${error.toString()}';
      state = state.copyWith(errorMessage: errorMessage, isLoading: false);
      return Result.failure(errorMessage);
    }
  }

  /// 토큰 갱신
  Future<Result<AuthToken?>> refreshToken() async {
    try {
      return await _sessionManagementUseCase.refreshToken();
    } catch (error) {
      return Result.failure('トークン更新に失敗しました: ${error.toString()}');
    }
  }

  /// 세션 만료 확인
  Future<Result<bool>> isSessionExpired() async {
    try {
      return await _sessionManagementUseCase.isSessionExpired();
    } catch (error) {
      return Result.failure('セッション確認に失敗しました: ${error.toString()}');
    }
  }

  /// 자동 로그인 설정 확인
  Future<Result<bool>> isAutoLoginEnabled() async {
    try {
      return await _sessionManagementUseCase.isAutoLoginEnabled();
    } catch (error) {
      return Result.failure('自動ログイン設定確認に失敗しました: ${error.toString()}');
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 상태 초기화
  void reset() {
    state = const AuthState();
  }
}
