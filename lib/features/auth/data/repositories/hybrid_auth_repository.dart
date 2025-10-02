import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/core/data/result_types.dart' as api;
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/domain/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_models.dart';
import '../services/api_auth_service.dart';
import '../services/offline_auth_state_manager.dart';
import '../services/token_manager_service.dart';

class HybridAuthRepository implements AuthRepository {
  final ApiAuthService _apiAuthService;
  final TokenManagerService _tokenManager;
  final OfflineAuthStateManager _offlineManager;
  final Connectivity _connectivity;
  final AuthRepository? _firebaseAuthRepository;

  AuthUserModel? _cachedApiUser;
  StreamSubscription<AuthMode>? _authModeSubscription;

  HybridAuthRepository({
    required ApiAuthService apiAuthService,
    required TokenManagerService tokenManager,
    required OfflineAuthStateManager offlineManager,
    required Connectivity connectivity,
    AuthRepository? firebaseAuthRepository,
  }) : _apiAuthService = apiAuthService,
       _tokenManager = tokenManager,
       _offlineManager = offlineManager,
       _connectivity = connectivity,
       _firebaseAuthRepository = firebaseAuthRepository {
    _initializeAuthModeListener();
  }

  void _initializeAuthModeListener() {
    _authModeSubscription = _offlineManager.authModeStream.listen((mode) {
      if (mode == AuthMode.online) {
        _syncOfflineChanges();
      }
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        // 온라인 로그인 시도 (API 우선)
        final loginResult = await _apiAuthService.login(
          email: email,
          password: password,
        );

        if (loginResult.isSuccess) {
          final token = loginResult.dataOrNull!;
          await _tokenManager.saveToken(token);

          // 로그인 후 사용자 정보 가져오기
          final userResult = await _apiAuthService.getCurrentUser();
          if (userResult.isSuccess && userResult.dataOrNull != null) {
            _cachedApiUser = userResult.dataOrNull;
            await _offlineManager.cacheUser(userResult.dataOrNull!);
            await _offlineManager.updateOfflineValidation();

            return Result.success(
              'ログイン成功',
              _convertToAuthUser(userResult.dataOrNull!),
            );
          }
        }

        // API 실패 시 Firebase 시도
        if (_firebaseAuthRepository != null) {
          return await _firebaseAuthRepository.signInWithEmailAndPassword(
            email,
            password,
          );
        }

        return Result.failure(
          'ログイン失敗: ${loginResult.errorOrNull?.message ?? "不明なエラー"}',
        );
      } else {
        // 오프라인 로그인
        final isValidOffline = await _offlineManager
            .isOfflineAuthenticationValid();
        if (isValidOffline) {
          final cachedUserResult = await _offlineManager.getCachedUser();
          if (cachedUserResult.isSuccess &&
              cachedUserResult.dataOrNull != null) {
            _cachedApiUser = cachedUserResult.dataOrNull;
            return Result.success(
              'オフラインログイン成功',
              _convertToAuthUser(_cachedApiUser!),
            );
          }
        }

        return Result.failure('ネットワーク接続が必要です');
      }
    } catch (e) {
      return Result.failure('ログイン中にエラーが発生: $e');
    }
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final registerResult = await _apiAuthService.register(
        email: email,
        password: password,
      );

      if (registerResult.isSuccess) {
        final token = registerResult.dataOrNull!;
        await _tokenManager.saveToken(token);

        final userResult = await _apiAuthService.getCurrentUser();
        if (userResult.isSuccess && userResult.dataOrNull != null) {
          _cachedApiUser = userResult.dataOrNull;
          await _offlineManager.cacheUser(userResult.dataOrNull!);
          return Result.success('会員登録成功', userResult.dataOrNull!.toDomain());
        }
      }

      if (_firebaseAuthRepository != null) {
        return await _firebaseAuthRepository.createUserWithEmailAndPassword(
          email,
          password,
        );
      }

      return Result.failure(
        '会員登録失敗: ${registerResult.errorOrNull?.message ?? "不明なエラー"}',
      );
    } catch (e) {
      return Result.failure('会員登録中にエラーが発生: $e');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    try {
      if (_firebaseAuthRepository != null) {
        final firebaseResult = await _firebaseAuthRepository.signInWithGoogle();
        if (firebaseResult.isSuccess) {
          final idToken = await _firebaseAuthRepository.getCurrentUserIdToken();
          if (idToken != null) {
            final exchangeResult = await _apiAuthService.exchangeFirebaseToken(
              idToken,
            );
            if (exchangeResult.isSuccess && exchangeResult.dataOrNull != null) {
              await _tokenManager.saveToken(exchangeResult.dataOrNull!);
            }
          }
        }
        return firebaseResult;
      }

      return Result.failure('Googleログインはサポートされていません');
    } catch (e) {
      return Result.failure('Googleログイン中にエラーが発生: $e');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    try {
      if (_firebaseAuthRepository != null) {
        final firebaseResult = await _firebaseAuthRepository.signInWithApple();
        if (firebaseResult.isSuccess) {
          final idToken = await _firebaseAuthRepository.getCurrentUserIdToken();
          if (idToken != null) {
            final exchangeResult = await _apiAuthService.exchangeFirebaseToken(
              idToken,
            );
            if (exchangeResult.isSuccess && exchangeResult.dataOrNull != null) {
              await _tokenManager.saveToken(exchangeResult.dataOrNull!);
            }
          }
        }
        return firebaseResult;
      }

      return Result.failure('Appleログインはサポートされていません');
    } catch (e) {
      return Result.failure('Appleログイン中にエラーが発生: $e');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithLine() async {
    try {
      if (_firebaseAuthRepository != null) {
        return await _firebaseAuthRepository.signInWithLine();
      }

      return Result.failure('LINEログインはサポートされていません');
    } catch (e) {
      return Result.failure('LINEログイン中にエラーが発生: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _apiAuthService.logout();
    } catch (e) {
      // API logout 실패는 무시 (오프라인일 수 있음)
    }

    _cachedApiUser = null;
    await _tokenManager.clearToken();

    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.signOut();
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final tokenResult = await _tokenManager.getCurrentToken();
      if (tokenResult.isSuccess && tokenResult.dataOrNull != null) {
        final userResult = await _apiAuthService.getCurrentUser();
        if (userResult.isSuccess && userResult.dataOrNull != null) {
          return userResult.dataOrNull!.toDomain();
        }
      }
    } catch (e) {
      // API 호출 실패 시 Firebase로 폴백
    }

    if (_firebaseAuthRepository != null) {
      return _firebaseAuthRepository.getCurrentUser();
    }

    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final result = await _apiAuthService.sendPasswordResetEmail(email);
      if (result.isSuccess) {
        return;
      }
    } catch (e) {
      // API 실패 시 Firebase로 시도
    }

    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.sendPasswordResetEmail(email);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final result = await _apiAuthService.sendEmailVerification();
      if (result.isSuccess) {
        return;
      }
    } catch (e) {
      // API 실패 시 Firebase로 시도
    }

    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.sendEmailVerification();
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final result = await _apiAuthService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      if (result.isSuccess) {
        // 캐시된 사용자 정보 갱신
        if (_cachedApiUser != null) {
          _cachedApiUser = _cachedApiUser!.copyWith(
            displayName: displayName,
            photoURL: photoURL,
          );
          await _offlineManager.cacheUser(_cachedApiUser!);
        }
        return;
      }
    } catch (e) {
      // API 실패 시 Firebase로 시도
    }

    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _apiAuthService.deleteAccount();
    } catch (e) {
      // API 실패 시에도 계속 진행
    }

    _cachedApiUser = null;
    await _tokenManager.clearToken();

    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.deleteAccount();
    }
  }

  @override
  Future<String> exchangeServerToken(String idToken) async {
    try {
      final result = await _apiAuthService.exchangeFirebaseToken(idToken);
      if (result.isSuccess && result.dataOrNull != null) {
        final token = result.dataOrNull!;
        await _tokenManager.saveToken(token);
        return token.accessToken;
      }
    } catch (e) {
      // API 실패 시 Firebase로 시도
    }

    if (_firebaseAuthRepository != null) {
      return _firebaseAuthRepository.exchangeServerToken(idToken);
    }

    throw Exception('サーバートークン交換失敗');
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    final tokenResult = await _tokenManager.getCurrentToken();
    if (tokenResult.isSuccess && tokenResult.dataOrNull != null) {
      return tokenResult.dataOrNull!.accessToken;
    }

    if (_firebaseAuthRepository != null) {
      return _firebaseAuthRepository.getCurrentUserIdToken();
    }

    return null;
  }

  @override
  Future<String?> getStoredServerToken() async {
    final tokenResult = await _tokenManager.getCurrentToken();
    if (tokenResult.isSuccess && tokenResult.dataOrNull != null) {
      return tokenResult.dataOrNull!.accessToken;
    }

    if (_firebaseAuthRepository != null) {
      return _firebaseAuthRepository.getStoredServerToken();
    }

    return null;
  }

  @override
  Future<void> saveServerToken(String token) async {
    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.saveServerToken(token);
    }
  }

  @override
  Future<void> clearServerToken() async {
    await _tokenManager.clearToken();

    if (_firebaseAuthRepository != null) {
      await _firebaseAuthRepository.clearServerToken();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // 유틸리티 메서드

  AuthUser _convertToAuthUser(AuthUserModel apiUser) {
    return AuthUser(
      uid: apiUser.id,
      email: apiUser.email,
      displayName: apiUser.displayName,
      photoURL: apiUser.photoURL,
      isEmailVerified: apiUser.isEmailVerified,
      lastSignInTime: apiUser.lastSignInTime,
      creationTime: apiUser.creationTime,
      customData: apiUser.customData,
    );
  }

  // 확장 기능: 동기화 관련 메서드들

  Future<api.ResultState<void>> forceSyncOfflineChanges() async {
    return _syncOfflineChanges();
  }

  Future<api.ResultState<bool>> hasOfflineChanges() async {
    try {
      // 실제 pending changes 확인 로직 필요
      return const api.Success(false);
    } catch (e) {
      return api.Failure(UnknownError(details: e.toString()));
    }
  }

  Future<api.ResultState<DateTime?>> getLastSyncTime() async {
    try {
      // 마지막 동기화 시간 조회 로직 필요
      return const api.Success(null);
    } catch (e) {
      return api.Failure(UnknownError(details: e.toString()));
    }
  }

  Future<api.ResultState<void>> _syncOfflineChanges() async {
    try {
      // 오프라인 변경사항 동기화 로직
      return const api.Success(null);
    } catch (e) {
      return api.Failure(UnknownError(details: e.toString()));
    }
  }

  // 스트림 접근자
  Stream<AuthMode> get authModeStream => _offlineManager.authModeStream;
  Stream<NetworkStatus> get networkStatusStream =>
      _offlineManager.networkStatusStream;

  AuthMode get currentAuthMode => _offlineManager.currentMode;
  NetworkStatus get networkStatus => _offlineManager.networkStatus;

  void dispose() {
    _authModeSubscription?.cancel();
    _offlineManager.dispose();
  }
}

final hybridAuthRepositoryProvider = Provider<HybridAuthRepository>((ref) {
  final apiAuthService = ref.read(apiAuthServiceProvider);
  final tokenManager = ref.read(tokenManagerServiceProvider);
  final offlineManager = ref.read(offlineAuthStateManagerProvider);
  final connectivity = Connectivity();

  final repository = HybridAuthRepository(
    apiAuthService: apiAuthService,
    tokenManager: tokenManager,
    offlineManager: offlineManager,
    connectivity: connectivity,
    // firebaseAuthRepository: ref.read(firebaseAuthRepositoryProvider), // 필요시 추가
  );

  ref.onDispose(() => repository.dispose());
  return repository;
});
