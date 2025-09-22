import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/services/secure_storage.dart'; // Changed
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';

/// 토큰 교환 상태를 나타내는 클래스
class TokenExchangeState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? serverToken;

  const TokenExchangeState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.serverToken,
  });

  /// 로딩 상태
  const TokenExchangeState.loading()
      : isLoading = true,
        isSuccess = false,
        errorMessage = null,
        serverToken = null;

  /// 성공 상태
  const TokenExchangeState.success(String token)
      : isLoading = false,
        isSuccess = true,
        errorMessage = null,
        serverToken = token;

  /// 실패 상태
  const TokenExchangeState.error(String error)
      : isLoading = false,
        isSuccess = false,
        errorMessage = error,
        serverToken = null;

  /// 초기 상태
  const TokenExchangeState.initial()
      : isLoading = false,
        isSuccess = false,
        errorMessage = null,
        serverToken = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenExchangeState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isSuccess == other.isSuccess &&
          errorMessage == other.errorMessage &&
          serverToken == other.serverToken;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isSuccess.hashCode ^
      errorMessage.hashCode ^
      serverToken.hashCode;

  @override
  String toString() {
    return 'TokenExchangeState{isLoading: $isLoading, isSuccess: $isSuccess, errorMessage: $errorMessage, serverToken: ${serverToken != null ? '***' : null}}';
  }
}

/// 토큰 교환을 관리하는 StateNotifier
class AuthController extends StateNotifier<TokenExchangeState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository)
      : super(const TokenExchangeState.initial());

  /// 서버 토큰 교환 실행
  Future<void> exchangeServerToken() async {
    if (state.isLoading) return; // 이미 진행 중이면 중복 실행 방지

    state = const TokenExchangeState.loading();

    try {
      if (kDebugMode) {
        print('🔄 서버 토큰 교환 시작');
      }

      // Firebase 로그인 상태 확인 및 최신 idToken 획득
      final idToken = await _authRepository.getCurrentUserIdToken();
      if (idToken == null) {
        throw Exception('Firebase 사용자가 로그인되지 않았습니다. 먼저 Firebase Auth로 로그인해주세요.');
      }

      // 서버 JWT로 교환
      final serverJWT = await _authRepository.exchangeServerToken(idToken);

      state = TokenExchangeState.success(serverJWT);

      if (kDebugMode) {
        print('✅ 서버 토큰 교환 완료');
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = TokenExchangeState.error(errorMessage);

      if (kDebugMode) {
        print('❌ 서버 토큰 교환 실패: $errorMessage');
      }
    }
  }

  /// 상태 초기화
  void reset() {
    state = const TokenExchangeState.initial();
  }

  /// 저장된 서버 토큰 확인
  Future<String?> getStoredToken() async {
    return _authRepository.getStoredServerToken();
  }

  /// 서버 토큰 삭제
  Future<void> clearServerToken() async {
    await _authRepository.clearServerToken();
    state = const TokenExchangeState.initial();
  }

  /// 인증 상태 확인
  Future<bool> isAuthenticated() async {
    return _authRepository.isAuthenticated();
  }

  /// 토큰 만료 상태 확인 // Changed
  Future<bool> isTokenExpired() async {
    return SecureStorage.isTokenExpired();
  }

  /// 토큰이 곧 만료될지 확인 // Changed
  Future<bool> isTokenExpiringSoon() async {
    return SecureStorage.isTokenExpiringSoon();
  }

  /// 토큰 만료 시간 확인 // Changed
  Future<DateTime?> getTokenExpiry() async {
    return SecureStorage.getTokenExpiry();
  }
}

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// AuthController Provider
final authControllerProvider =
    StateNotifierProvider<AuthController, TokenExchangeState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});