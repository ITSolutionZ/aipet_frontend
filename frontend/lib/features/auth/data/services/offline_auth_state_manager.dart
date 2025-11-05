import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';


import '../../../../shared/shared.dart';
import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/services/logger_service.dart';
import '../../../../shared/core/services/secure_storage_service.dart';
import '../models/auth_models.dart';
import 'token_manager_service.dart';



enum AuthMode {
  online, // API 기반 인증
  offline, // 로컬 캐시 기반 인증
  hybrid, // 하이브리드 (온라인/오프라인 자동 전환)
}

enum NetworkStatus { connected, disconnected, unknown }

class OfflineAuthStateManager {
  final TokenManagerService _tokenManager;
  final Connectivity _connectivity;

  AuthMode _currentMode = AuthMode.hybrid;
  NetworkStatus _networkStatus = NetworkStatus.unknown;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<AuthMode> _authModeController =
      StreamController.broadcast();
  final StreamController<NetworkStatus> _networkStatusController =
      StreamController.broadcast();

  OfflineAuthStateManager(this._tokenManager, this._connectivity) {
    _initializeConnectivityListener();
  }

  Stream<AuthMode> get authModeStream => _authModeController.stream;
  Stream<NetworkStatus> get networkStatusStream =>
      _networkStatusController.stream;

  AuthMode get currentMode => _currentMode;
  NetworkStatus get networkStatus => _networkStatus;

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      _updateNetworkStatus(results);
    });

    _connectivity.checkConnectivity().then((results) {
      _updateNetworkStatus(results);
    });
  }

  void _updateNetworkStatus(List<ConnectivityResult> results) {
    final wasConnected = _networkStatus == NetworkStatus.connected;

    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet)) {
      _networkStatus = NetworkStatus.connected;
    } else {
      _networkStatus = NetworkStatus.disconnected;
    }

    _networkStatusController.add(_networkStatus);

    if (_currentMode == AuthMode.hybrid) {
      final newMode = _networkStatus == NetworkStatus.connected
          ? AuthMode.online
          : AuthMode.offline;

      if (newMode != _getEffectiveMode()) {
        _updateAuthMode(newMode);
      }
    }

    if (!wasConnected && _networkStatus == NetworkStatus.connected) {
      _handleNetworkReconnection();
    }
  }

  AuthMode _getEffectiveMode() {
    if (_currentMode == AuthMode.hybrid) {
      return _networkStatus == NetworkStatus.connected
          ? AuthMode.online
          : AuthMode.offline;
    }
    return _currentMode;
  }

  void _updateAuthMode(AuthMode mode) {
    _currentMode = mode;
    _authModeController.add(mode);
  }

  Future<void> _handleNetworkReconnection() async {
    try {
      await _syncOfflineChanges();
      await _refreshTokenIfNeeded();
    } catch (e) {
      LoggerService.debug('⚠️ Error handling network reconnection: $e');
    }
  }

  Future<void> _syncOfflineChanges() async {
    try {
      final pendingChanges = await _getPendingOfflineChanges();
      if (pendingChanges.isNotEmpty) {
        for (final change in pendingChanges) {
          await _syncChange(change);
        }
        await _clearPendingChanges();
      }
    } catch (e) {
      LoggerService.debug('⚠️ Error syncing offline changes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingOfflineChanges() async {
    try {
      final changesJson = await SecureStorageService.getJson(
        'pending_auth_changes',
      );
      if (changesJson != null && changesJson['changes'] is List) {
        return List<Map<String, dynamic>>.from(changesJson['changes']);
      }
    } catch (e) {
      LoggerService.debug('⚠️ Error getting pending offline changes: $e');
    }
    return [];
  }

  Future<void> _syncChange(Map<String, dynamic> change) async {}

  Future<void> _clearPendingChanges() async {
    try {
      await SecureStorageService.remove('pending_auth_changes');
    } catch (e) {
      LoggerService.debug('⚠️ Error clearing pending changes: $e');
    }
  }

  Future<void> _refreshTokenIfNeeded() async {
    try {
      if (_tokenManager.isTokenExpiringSoon) {
        await _tokenManager.refreshToken();
      }
    } catch (e) {
      LoggerService.debug('⚠️ Error refreshing token: $e');
    }
  }

  Future<ResultState<AuthUserModel?>> getCachedUser() async {
    try {
      final userJson = await SecureStorageService.getJson('cached_user');
      if (userJson == null) {
        return const Success(null);
      }

      final user = AuthUserModel.fromJson(userJson);
      return Success(user);
    } catch (e) {
      return ResultState.failure(
        CacheError('캐시된 사용자 정보 로드 실패', details: e.toString()),
      );
    }
  }

  Future<ResultState<void>> cacheUser(AuthUserModel user) async {
    try {
      await SecureStorageService.setJson('cached_user', user.toJson());
      return const Success(null);
    } catch (e) {
      // AppErrorHandler가 정의되어 있지 않아, 단순히 e.toString()으로 에러 디테일 출력
      return ResultState.failure(
        CacheError('사용자 정보 캐시 실패', details: e.toString()),
      );
    }
  }

  Future<ResultState<void>> clearCachedUser() async {
    try {
      await SecureStorageService.remove('cached_user');
      return const Success(null);
    } catch (e) {
      return ResultState.failure(
        CacheError('캐시된 사용자 정보 삭제 실패', details: e.toString()),
      );
    }
  }

  Future<bool> isOfflineAuthenticationValid() async {
    try {
      final tokenResult = await _tokenManager.getCurrentToken();
      if (tokenResult.isFailure || tokenResult.dataOrNull == null) {
        return false;
      }

      final userResult = await getCachedUser();
      if (userResult.isFailure || userResult.dataOrNull == null) {
        return false;
      }

      final lastValidation = await SecureStorageService.getInt(
        'last_offline_validation',
      );
      if (lastValidation != null) {
        final lastValidationTime = DateTime.fromMillisecondsSinceEpoch(
          lastValidation,
        );
        final timeSinceValidation = DateTime.now().difference(
          lastValidationTime,
        );

        if (timeSinceValidation.inHours > 24) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateOfflineValidation() async {
    try {
      await SecureStorageService.setInt(
        'last_offline_validation',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      LoggerService.debug('⚠️ Error updating offline validation: $e');
    }
  }

  Future<void> addPendingChange(String type, Map<String, dynamic> data) async {
    try {
      final existingChanges = await _getPendingOfflineChanges();
      existingChanges.add({
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await SecureStorageService.setJson('pending_auth_changes', {
        'changes': existingChanges,
      });
    } catch (e) {
      LoggerService.debug('⚠️ Error adding pending change: $e');
    }
  }

  void setAuthMode(AuthMode mode) {
    if (_currentMode != mode) {
      _updateAuthMode(mode);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _authModeController.close();
    _networkStatusController.close();
  }
}

final offlineAuthStateManagerProvider = Provider<OfflineAuthStateManager>((
  ref,
) {
  final tokenManager = ref.read(tokenManagerServiceProvider);
  final connectivity = Connectivity();
  final manager = OfflineAuthStateManager(tokenManager, connectivity);
  ref.onDispose(() => manager.dispose());
  return manager;
});
