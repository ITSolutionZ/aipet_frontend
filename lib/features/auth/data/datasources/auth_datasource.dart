import 'package:aipet_frontend/shared/core/domain/result.dart';

import '../../domain/entities/auth_entities.dart';

/// 기본 인증 데이터소스 인터페이스
abstract class AuthDatasource {
  /// 이메일/비밀번호로 로그인
  Future<Result<AuthUser>> signInWithEmailAndPassword(String email, String password);

  /// 이메일/비밀번호로 회원가입
  Future<Result<AuthUser>> createUserWithEmailAndPassword(String email, String password);

  /// 로그아웃
  Future<void> signOut();

  /// 현재 사용자 조회
  Future<Result<AuthUser?>> getCurrentUser();

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile({String? displayName, String? photoURL});
}

/// 원격 인증 데이터소스 인터페이스
abstract class AuthRemoteDatasource extends AuthDatasource {
  /// Google 로그인
  Future<Result<AuthUser>> signInWithGoogle();

  /// Apple 로그인
  Future<Result<AuthUser>> signInWithApple();

  /// LINE 로그인
  Future<Result<AuthUser>> signInWithLine();

  /// 비밀번호 재설정 이메일 발송
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증 메일 발송
  Future<void> sendEmailVerification();

  /// 계정 삭제
  Future<void> deleteAccount();

  /// Firebase 토큰을 서버 토큰으로 교환
  Future<String> exchangeServerToken(String idToken);

  /// 현재 Firebase 사용자의 ID 토큰 조회
  Future<String?> getCurrentUserIdToken();

  /// 토큰 유효성 검증
  Future<bool> validateToken(String token);
}

/// 로컬 인증 데이터소스 인터페이스
abstract class AuthLocalDatasource extends AuthDatasource {
  /// 사용자 세션 저장
  Future<void> saveUserSession(AuthUser user);

  /// 사용자 세션 삭제
  Future<void> clearUserSession();

  /// 캐시된 사용자 조회 (이메일 기반)
  Future<Result<AuthUser?>> getCachedUser(String email);

  /// 토큰 저장
  Future<void> saveToken(String token);

  /// 저장된 토큰 조회
  Future<String?> getStoredToken();

  /// 토큰 삭제
  Future<void> clearToken();

  /// 로그인 기록 저장
  Future<void> saveLoginRecord(String email, DateTime loginTime);

  /// 자동 로그인 설정 저장
  Future<void> saveAutoLoginSetting(bool enabled);

  /// 자동 로그인 설정 조회
  Future<bool> getAutoLoginSetting();

  /// 생체 인증 설정 저장
  Future<void> saveBiometricSetting(bool enabled);

  /// 생체 인증 설정 조회
  Future<bool> getBiometricSetting();
}