import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/auth_mock_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/authenticate_usecase.dart';
import '../../domain/usecases/session_management_usecase.dart';
import '../controllers/auth_controller_new.dart';

/// Remote Datasource Provider
final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthMockRemoteDatasource(),
);

/// Local Datasource Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>(
  (ref) => AuthMockLocalDatasource(),
);

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    final remoteDatasource = ref.watch(authRemoteDatasourceProvider);
    final localDatasource = ref.watch(authLocalDatasourceProvider);

    return AuthRepositoryImpl(
      remoteDatasource,
      localDatasource,
    );
  },
);

/// Authenticate UseCase Provider
final authenticateUseCaseProvider = Provider<AuthenticateUseCase>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return AuthenticateUseCase(repository);
  },
);

/// Session Management UseCase Provider
final sessionManagementUseCaseProvider = Provider<SessionManagementUseCase>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return SessionManagementUseCase(repository);
  },
);

/// Clean Auth Controller Provider
final cleanAuthControllerProvider = StateNotifierProvider<CleanAuthController, AuthState>(
  (ref) {
    final authenticateUseCase = ref.watch(authenticateUseCaseProvider);
    final sessionManagementUseCase = ref.watch(sessionManagementUseCaseProvider);

    return CleanAuthController(
      authenticateUseCase: authenticateUseCase,
      sessionManagementUseCase: sessionManagementUseCase,
    );
  },
);

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