import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/core/domain/result.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/authenticate_usecase.dart';
import '../../domain/usecases/session_management_usecase.dart';
import '../controllers/auth_controller_new.dart';

// Auth Datasource Implementations
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return Result.failure('Remote authentication not implemented');
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return Result.failure('Remote authentication not implemented');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    return Result.success('No current user', null);
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {}

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    return Result.failure('Google sign-in not implemented');
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    return Result.failure('Apple sign-in not implemented');
  }

  @override
  Future<Result<AuthUser>> signInWithLine() async {
    return Result.failure('LINE sign-in not implemented');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<String> exchangeServerToken(String idToken) async {
    return '';
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    return null;
  }

  @override
  Future<bool> validateToken(String token) async {
    return false;
  }
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return Result.failure('Local authentication not implemented');
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return Result.failure('Local authentication not implemented');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    return Result.success('No current user', null);
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {}

  @override
  Future<void> saveUserSession(AuthUser user) async {}

  @override
  Future<void> clearUserSession() async {}

  @override
  Future<Result<AuthUser?>> getCachedUser(String email) async {
    return Result.success('No cached user', null);
  }

  @override
  Future<void> saveToken(String token) async {}

  @override
  Future<String?> getStoredToken() async {
    return null;
  }

  @override
  Future<void> clearToken() async {}

  @override
  Future<void> saveLoginRecord(String email, DateTime loginTime) async {}

  @override
  Future<void> saveAutoLoginSetting(bool enabled) async {}

  @override
  Future<bool> getAutoLoginSetting() async {
    return false;
  }

  @override
  Future<void> saveBiometricSetting(bool enabled) async {}

  @override
  Future<bool> getBiometricSetting() async {
    return false;
  }
}

/// Remote Datasource Provider
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(),
);

/// Local Datasource Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>(
  (ref) => AuthLocalDatasourceImpl(),
);

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
  final localDatasource = ref.watch(authLocalDatasourceProvider);

  return AuthRepositoryImpl(remoteDatasource, localDatasource);
});

/// Authenticate UseCase Provider
final authenticateUseCaseProvider = Provider<AuthenticateUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthenticateUseCase(repository);
});

/// Session Management UseCase Provider
final sessionManagementUseCaseProvider = Provider<SessionManagementUseCase>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return SessionManagementUseCase(repository);
});

/// Clean Auth Controller Provider
final cleanAuthControllerProvider =
    StateNotifierProvider<CleanAuthController, AuthState>((ref) {
      final authenticateUseCase = ref.watch(authenticateUseCaseProvider);
      final sessionManagementUseCase = ref.watch(
        sessionManagementUseCaseProvider,
      );

      return CleanAuthController(
        authenticateUseCase: authenticateUseCase,
        sessionManagementUseCase: sessionManagementUseCase,
      );
    });

/// 현재 사용자 Provider (computed)
final currentUserProvider = Provider((ref) {
  final authState = ref.watch(cleanAuthControllerProvider);
  return authState.user;
});

/// 인증 상태 Provider (computed)
final isAuthenticatedProvider = Provider((ref) {
  final authState = ref.watch(cleanAuthControllerProvider);
  return authState.status == AuthenticationStatus.authenticated;
});

/// 로딩 상태 Provider (computed)
final authLoadingProvider = Provider((ref) {
  final authState = ref.watch(cleanAuthControllerProvider);
  return authState.isLoading;
});

/// 에러 메시지 Provider (computed)
final authErrorProvider = Provider((ref) {
  final authState = ref.watch(cleanAuthControllerProvider);
  return authState.errorMessage;
});
