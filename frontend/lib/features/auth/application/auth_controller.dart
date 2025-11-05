import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../shared/shared.dart';
import '../../../app/services/secure_storage.dart';
import '../data/data.dart';
import '../domain/domain.dart';



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

/// 토큰 교환을 관리하는 Notifier
class AuthController extends Notifier<TokenExchangeState> {
  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  TokenExchangeState build() => const TokenExchangeState.initial();

  /// 서버 토큰 교환 실행
  Future<void> exchangeServerToken() async {
    if (state.isLoading) return; // 이미 진행 중이면 중복 실행 방지

    state = const TokenExchangeState.loading();

    try {
      if (kDebugMode) {}

      // Firebase 로그인 상태 확인 및 최신 idToken 획득
      final idToken = await _authRepository.getCurrentUserIdToken();
      if (idToken == null) {
        throw Exception(
          'Firebase 사용자가 로그인되지 않았습니다. 먼저 Firebase Auth로 로그인해주세요.',
        );
      }

      // 서버 JWT로 교환
      final serverJWT = await _authRepository.exchangeServerToken(idToken);

      state = TokenExchangeState.success(serverJWT);

      if (kDebugMode) {}
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = TokenExchangeState.error(errorMessage);

      if (kDebugMode) {}
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

  /// 토큰 자동 갱신 시도
  ///
  /// 토큰이 곧 만료될 경우 자동으로 갱신을 시도합니다.
  ///
  /// Returns: 갱신 성공 여부
  Future<bool> autoRefreshToken() async {
    try {
      // 현재 저장된 토큰 확인
      final currentToken = await getStoredToken();
      if (currentToken == null) {
        if (kDebugMode) {
          LoggerService.debug('갱신할 토큰이 없습니다');
        }
        return false;
      }

      // 토큰이 곧 만료되는지 확인 (5분 전)
      final tokenExpiry = await getTokenExpiry();
      if (tokenExpiry == null) {
        return false;
      }

      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
      if (tokenExpiry.isAfter(fiveMinutesFromNow)) {
        if (kDebugMode) {
          LoggerService.debug('토큰 갱신이 필요하지 않습니다 (만료: ${tokenExpiry.toIso8601String()})');
        }
        return true; // 갱신이 필요하지 않으면 성공으로 간주
      }

      // Firebase ID 토큰으로 새 서버 토큰 교환
      if (kDebugMode) {
        LoggerService.debug('토큰 자동 갱신 시작 (만료 예정: ${tokenExpiry.toIso8601String()})');
      }

      await exchangeServerToken();

      if (kDebugMode) {
        LoggerService.debug('토큰 자동 갱신 성공');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('토큰 자동 갱신 실패: $e');
      }
      return false;
    }
  }

  /// 주기적 토큰 갱신 시작
  ///
  /// 5분마다 토큰 상태를 확인하고 필요시 자동 갱신을 수행합니다.
  void startPeriodicTokenRefresh() {
    // 5분마다 토큰 상태 확인
    Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        final isAuthenticated = await this.isAuthenticated();
        if (!isAuthenticated) {
          // 인증되지 않은 상태면 타이머 정지
          timer.cancel();
          return;
        }

        // 자동 갱신 시도
        await autoRefreshToken();
      } catch (e) {
        if (kDebugMode) {
          LoggerService.debug('주기적 토큰 갱신 에러: $e');
        }
      }
    });
  }
}

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRealImpl();
});

/// AuthController Provider
final authControllerProvider =
    NotifierProvider<AuthController, TokenExchangeState>(AuthController.new);
