import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';
import '../services/auth_config_service.dart';

/// 통합 Auth Repository 구현체
///
/// Firebase Auth를 기반으로 하며, 개발 중에는 간단한 검증만 수행합니다.
/// 향후 실제 Firebase Auth 연동 시 이 파일만 수정하면 됩니다.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRepository _firebaseRepository;
  final Ref ref;

  AuthRepositoryImpl({
    required AuthRepository firebaseRepository,
    required this.ref,
  }) : _firebaseRepository = firebaseRepository;

  /// Firebase Auth Repository 사용
  /// 개발 중에는 간단한 검증만 수행하고, 향후 실제 Firebase Auth 호출로 변경
  AuthRepository get _currentRepository => _firebaseRepository;

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _currentRepository.signInWithEmailAndPassword(
        email,
        password,
      );

      // 성공 시 토큰 저장 (Mock 모드에서도 토큰 정보 포함)
      if (result.isSuccess && result.user != null) {
        await _saveAuthTokens(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure('ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _currentRepository.createUserWithEmailAndPassword(
        email,
        password,
      );

      // 성공 시 토큰 저장
      if (result.isSuccess && result.user != null) {
        await _saveAuthTokens(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure('会員登録に失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final result = await _currentRepository.signInWithGoogle();

      // 성공 시 토큰 저장
      if (result.isSuccess && result.user != null) {
        await _saveAuthTokens(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure('Google ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      final result = await _currentRepository.signInWithApple();

      // 성공 시 토큰 저장
      if (result.isSuccess && result.user != null) {
        await _saveAuthTokens(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure('Apple ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithLine() async {
    try {
      final result = await _currentRepository.signInWithLine();

      // 성공 시 토큰 저장
      if (result.isSuccess && result.user != null) {
        await _saveAuthTokens(result.user!);
      }

      return result;
    } catch (e) {
      return AuthResult.failure('LINE ログインに失敗しました: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // 토큰 삭제
      await _clearAuthTokens();

      // Repository 로그아웃
      await _currentRepository.signOut();
    } catch (e) {
      // 로그아웃 실패해도 토큰은 삭제
      await _clearAuthTokens();
      rethrow;
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      // 먼저 저장된 토큰 확인
      final storedTokens = await _getStoredTokens();
      if (storedTokens != null && _isTokenValid(storedTokens)) {
        // 토큰이 유효하면 저장된 사용자 정보 반환
        return await _getUserFromStoredTokens(storedTokens);
      }

      // 토큰이 없거나 만료된 경우 Repository에서 사용자 정보 가져오기
      final user = await _currentRepository.getCurrentUser();

      // 사용자 정보가 있으면 토큰 저장
      if (user != null) {
        await _saveAuthTokens(user);
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _currentRepository.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await _currentRepository.sendEmailVerification();
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await _currentRepository.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _currentRepository.deleteAccount();
      await _clearAuthTokens();
    } catch (e) {
      // 계정 삭제 실패해도 토큰은 삭제
      await _clearAuthTokens();
      rethrow;
    }
  }

  /// 인증 토큰 저장
  Future<void> _saveAuthTokens(AuthUser user) async {
    try {
      final customData = user.customData;

      if (customData != null) {
        // Access Token 저장
        if (customData['accessToken'] != null) {
          await SecureStorageService.setString(
            AuthConfigConstants.accessTokenKey,
            customData['accessToken'] as String,
          );
        }

        // Refresh Token 저장
        if (customData['refreshToken'] != null) {
          await SecureStorageService.setString(
            AuthConfigConstants.refreshTokenKey,
            customData['refreshToken'] as String,
          );
        }

        // 토큰 만료 시간 저장
        if (customData['expiresAt'] != null) {
          await SecureStorageService.setString(
            AuthConfigConstants.tokenExpiresAtKey,
            customData['expiresAt'] as String,
          );
        }

        // 토큰 타입 저장
        if (customData['tokenType'] != null) {
          await SecureStorageService.setString(
            AuthConfigConstants.tokenTypeKey,
            customData['tokenType'] as String,
          );
        }

        // Firebase ID Token 저장 (Firebase Auth 사용 시)
        if (customData['firebaseUid'] != null) {
          await SecureStorageService.setString(
            AuthConfigConstants.firebaseIdTokenKey,
            customData['firebaseUid'] as String,
          );
        }
      }
    } catch (e) {
      // 토큰 저장 실패는 로그만 남기고 계속 진행
      debugPrint('토큰 저장 실패: $e');
    }
  }

  /// 저장된 인증 토큰 가져오기
  Future<Map<String, String>?> _getStoredTokens() async {
    try {
      final accessToken = await SecureStorageService.getString(
        AuthConfigConstants.accessTokenKey,
      );
      final refreshToken = await SecureStorageService.getString(
        AuthConfigConstants.refreshTokenKey,
      );
      final expiresAt = await SecureStorageService.getString(
        AuthConfigConstants.tokenExpiresAtKey,
      );
      final tokenType = await SecureStorageService.getString(
        AuthConfigConstants.tokenTypeKey,
      );

      if (accessToken == null) return null;

      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken ?? '',
        'expiresAt': expiresAt ?? '',
        'tokenType': tokenType ?? 'Bearer',
      };
    } catch (e) {
      return null;
    }
  }

  /// 토큰 유효성 검사
  bool _isTokenValid(Map<String, String> tokens) {
    try {
      final expiresAt = tokens['expiresAt'];
      if (expiresAt == null || expiresAt.isEmpty) return false;

      final expiry = DateTime.parse(expiresAt);
      final now = DateTime.now();

      // 토큰 갱신 임계값을 고려하여 유효성 검사
      return expiry.isAfter(now.add(AuthConfigService.tokenRefreshThreshold));
    } catch (e) {
      return false;
    }
  }

  /// 저장된 토큰에서 사용자 정보 생성
  Future<AuthUser?> _getUserFromStoredTokens(Map<String, String> tokens) async {
    try {
      // 실제 구현에서는 토큰을 검증하고 사용자 정보를 가져와야 합니다.
      // 현재는 간단히 null을 반환하여 Repository에서 사용자 정보를 가져오도록 합니다.
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 인증 토큰 삭제
  Future<void> _clearAuthTokens() async {
    try {
      await Future.wait<void>([
        SecureStorageService.remove(AuthConfigConstants.accessTokenKey),
        SecureStorageService.remove(AuthConfigConstants.refreshTokenKey),
        SecureStorageService.remove(AuthConfigConstants.tokenExpiresAtKey),
        SecureStorageService.remove(AuthConfigConstants.tokenTypeKey),
        SecureStorageService.remove(AuthConfigConstants.firebaseIdTokenKey),
        SecureStorageService.remove(
          AuthConfigConstants.firebaseIdTokenExpiresKey,
        ),
      ]);
    } catch (e) {
      // 토큰 삭제 실패는 로그만 남기고 계속 진행
      debugPrint('토큰 삭제 실패: $e');
    }
  }
}
