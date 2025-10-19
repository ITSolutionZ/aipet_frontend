import 'package:aipet_frontend/shared/core/domain/result.dart';

import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

/// 세션 관리 Use Case
///
/// 토큰 관리, 세션 갱신, 자동 로그아웃 등을 처리
class SessionManagementUseCase {
  final AuthRepository _repository;

  const SessionManagementUseCase(this._repository);

  /// 현재 세션 상태 확인
  Future<Result<AuthenticationStatus>> getSessionStatus() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        // 토큰 유효성 추가 확인
        final isAuthenticated = await _repository.isAuthenticated();
        if (isAuthenticated) {
          return Result.success('인증된 세션', AuthenticationStatus.authenticated);
        }
      }
      return Result.success('미인증 세션', AuthenticationStatus.unauthenticated);
    } catch (error) {
      return Result.failure('세션 상태 확인 실패: ${error.toString()}');
    }
  }

  /// 토큰 갱신
  Future<Result<AuthToken?>> refreshToken() async {
    try {
      // 현재 저장된 토큰 조회
      final currentToken = await _repository.getStoredServerToken();
      if (currentToken == null) {
        return Result.failure('저장된 토큰이 없습니다');
      }

      // Firebase 토큰을 서버 토큰으로 교환
      final firebaseToken = await _repository.getCurrentUserIdToken();
      if (firebaseToken != null) {
        final newServerToken = await _repository.exchangeServerToken(
          firebaseToken,
        );
        await _repository.saveServerToken(newServerToken);

        // AuthToken 엔티티로 변환 (실제로는 토큰 정보를 파싱해야 함)
        final authToken = _parseToken(newServerToken);
        return Result.success('토큰이 갱신되었습니다', authToken);
      }

      return Result.failure('Firebase 토큰을 가져올 수 없습니다');
    } catch (error) {
      return Result.failure('토큰 갱신 실패: ${error.toString()}');
    }
  }

  /// 세션 만료 확인
  Future<Result<bool>> isSessionExpired() async {
    try {
      final token = await _repository.getStoredServerToken();
      if (token == null) {
        return Result.success('세션 만료됨', true);
      }

      // 토큰 만료 시간 확인 (실제로는 JWT 디코딩이 필요)
      final authToken = _parseToken(token);
      if (authToken != null && authToken.isExpired) {
        return Result.success('세션 만료됨', true);
      }

      return Result.success('세션 유효함', false);
    } catch (error) {
      return Result.failure('세션 만료 확인 실패: ${error.toString()}');
    }
  }

  /// 세션 자동 갱신 여부 확인
  Future<Result<bool>> shouldRefreshSession() async {
    try {
      final token = await _repository.getStoredServerToken();
      if (token == null) {
        return Result.success('토큰이 없어 갱신 불필요', false);
      }

      final authToken = _parseToken(token);
      if (authToken != null && authToken.willExpireSoon) {
        return Result.success('토큰 갱신 필요', true);
      }

      return Result.success('토큰 갱신 불필요', false);
    } catch (error) {
      return Result.failure('세션 갱신 필요성 확인 실패: ${error.toString()}');
    }
  }

  /// 모든 세션 종료 (모든 디바이스에서 로그아웃)
  Future<Result<void>> terminateAllSessions() async {
    try {
      await _repository.signOut();
      await _repository.clearServerToken();
      return Result.success('모든 세션이 종료되었습니다');
    } catch (error) {
      return Result.failure('세션 종료 실패: ${error.toString()}');
    }
  }

  /// 현재 디바이스에서만 로그아웃
  Future<Result<void>> logoutCurrentDevice() async {
    try {
      await _repository.signOut();
      await _repository.clearServerToken();
      return Result.success('현재 디바이스에서 로그아웃되었습니다');
    } catch (error) {
      return Result.failure('로그아웃 실패: ${error.toString()}');
    }
  }

  /// 세션 정보 조회
  Future<Result<AuthSession?>> getCurrentSession() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user == null) {
        return Result.success('세션 없음', null);
      }

      // 현재 세션 정보 구성 (실제로는 서버에서 조회)
      final session = AuthSession(
        sessionId: _generateSessionId(),
        userId: user.uid,
        createdAt: user.lastSignInTime ?? user.creationTime,
        deviceId: _getDeviceId(),
        deviceName: _getDeviceName(),
      );

      return Result.success('현재 세션 정보', session);
    } catch (error) {
      return Result.failure('세션 정보 조회 실패: ${error.toString()}');
    }
  }

  /// 자동 로그인 설정 확인
  Future<Result<bool>> isAutoLoginEnabled() async {
    try {
      // SharedPreferences나 SecureStorage에서 자동 로그인 설정 확인
      // 현재는 토큰 존재 여부로 판단
      final token = await _repository.getStoredServerToken();
      return Result.success('자동 로그인 설정 확인', token != null);
    } catch (error) {
      return Result.failure('자동 로그인 설정 확인 실패: ${error.toString()}');
    }
  }

  /// 백그라운드에서 세션 유효성 검사
  Future<Result<bool>> validateSessionInBackground() async {
    try {
      final isAuthenticated = await _repository.isAuthenticated();
      if (!isAuthenticated) {
        await _repository.signOut();
        await _repository.clearServerToken();
        return Result.success('세션 무효화됨', false);
      }

      return Result.success('세션 유효함', true);
    } catch (error) {
      return Result.failure('백그라운드 세션 검증 실패: ${error.toString()}');
    }
  }

  // Private helper methods

  /// 토큰 파싱 (실제로는 JWT 라이브러리 사용)
  AuthToken? _parseToken(String token) {
    try {
      // 간단한 mock 구현
      final now = DateTime.now();
      return AuthToken(
        accessToken: token,
        issuedAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );
    } catch (error) {
      return null;
    }
  }

  /// 세션 ID 생성
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 디바이스 ID 조회 (실제로는 device_info_plus 사용)
  String _getDeviceId() {
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 디바이스 이름 조회
  String _getDeviceName() {
    return 'User Device';
  }
}
