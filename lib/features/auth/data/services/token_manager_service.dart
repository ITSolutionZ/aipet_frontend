import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/core/api/api_client.dart';
import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/core/services/secure_storage_service.dart';
import '../models/auth_models.dart';
import 'api_auth_service.dart';

class TokenManagerService {
  final ApiAuthService _apiAuthService;

  AuthTokenModel? _currentToken;
  Timer? _refreshTimer;

  TokenManagerService(this._apiAuthService);

  Future<ResultState<AuthTokenModel?>> getCurrentToken() async {
    if (_currentToken != null && !_currentToken!.isExpired) {
      return Success(_currentToken);
    }

    return _loadTokenFromStorage();
  }

  Future<ResultState<void>> saveToken(AuthTokenModel token) async {
    try {
      _currentToken = token;

      await SecureStorageService.setJson('auth_token', token.toJson());
      await SecureStorageService.saveToken(token.accessToken);
      await SecureStorageService.saveRefreshToken(token.refreshToken);

      _scheduleTokenRefresh(token);
      return const Success(null);
    } catch (e) {
      return Result.failure(CacheError('토큰 저장 실패', details: e.toString()));
    }
  }

  Future<ResultState<void>> clearToken() async {
    try {
      _currentToken = null;
      _refreshTimer?.cancel();
      _refreshTimer = null;

      await SecureStorageService.clearTokens();
      await SecureStorageService.remove('auth_token');

      return const Success(null);
    } catch (e) {
      return Result.failure(CacheError('토큰 삭제 실패', details: e.toString()));
    }
  }

  Future<ResultState<AuthTokenModel>> refreshToken() async {
    try {
      final currentTokenResult = await getCurrentToken();
      if (currentTokenResult.isFailure) {
        return Result.failure(currentTokenResult.errorOrNull!);
      }

      final currentToken = currentTokenResult.dataOrNull;
      if (currentToken == null) {
        return Result.failure(AuthenticationError('토큰이 없습니다.'));
      }

      final refreshResult = await _apiAuthService.refreshToken(
        currentToken.refreshToken,
      );
      if (refreshResult.isFailure) {
        await clearToken();
        return Result.failure(refreshResult.errorOrNull!);
      }

      final newToken = refreshResult.dataOrNull!;
      await saveToken(newToken);

      return Success(newToken);
    } catch (e) {
      return Result.failure(UnknownError(details: e.toString()));
    }
  }

  Future<ResultState<AuthTokenModel?>> _loadTokenFromStorage() async {
    try {
      final tokenJson = await SecureStorageService.getJson('auth_token');
      if (tokenJson == null) {
        return const Success(null);
      }

      final token = AuthTokenModel.fromJson(tokenJson);

      if (token.isExpired) {
        final refreshResult = await refreshToken();
        if (refreshResult.isSuccess) {
          return Success(refreshResult.dataOrNull);
        } else {
          await clearToken();
          return const Success(null);
        }
      }

      _currentToken = token;
      _scheduleTokenRefresh(token);

      return Success(token);
    } catch (e) {
      return Result.failure(CacheError('토큰 로드 실패', details: e.toString()));
    }
  }

  void _scheduleTokenRefresh(AuthTokenModel token) {
    _refreshTimer?.cancel();

    if (token.isExpired) {
      return;
    }

    Duration refreshDelay;
    if (token.isExpiringSoon) {
      refreshDelay = const Duration(minutes: 1);
    } else {
      final timeUntilExpiry = token.timeUntilExpiry;
      refreshDelay = Duration(
        milliseconds: (timeUntilExpiry.inMilliseconds * 0.8).round(),
      );
    }

    _refreshTimer = Timer(refreshDelay, () async {
      final refreshResult = await refreshToken();
      if (refreshResult.isFailure) {
        await clearToken();
      }
    });
  }

  bool get hasValidToken {
    return _currentToken != null && !_currentToken!.isExpired;
  }

  bool get isTokenExpiringSoon {
    return _currentToken?.isExpiringSoon ?? false;
  }

  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

final tokenManagerServiceProvider = Provider<TokenManagerService>((ref) {
  final apiAuthService = ref.read(apiAuthServiceProvider);
  return TokenManagerService(apiAuthService);
});

final apiAuthServiceProvider = Provider<ApiAuthService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ApiAuthService(apiClient);
});
