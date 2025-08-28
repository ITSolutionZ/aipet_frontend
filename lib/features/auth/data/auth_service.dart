import '../domain/auth_error.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/result.dart';
import 'repositories/mock_auth_repository.dart';
import 'services/token_storage_service.dart';

/// 인증 관련 비즈니스 로직을 담당하는 서비스
/// Repository와 Storage를 조합하여 실제 인증 플로우 관리
class AuthService {
  final AuthRepository _repository;
  
  AuthService({
    AuthRepository? repository,
  }) : _repository = repository ?? MockAuthRepositoryImpl();

  /// 이메일/비밀번호 로그인
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _repository.signInWithEmailAndPassword(email, password);
      
      if (result.isSuccess && result.user != null) {
        // 로그인 성공 시 토큰 저장 (실제 구현에서는 토큰 데이터 활용)
        // await _saveTokenFromResult(result);
        return Result.success(result.user!);
      } else {
        return Result.failure(
          AuthenticationError(result.message),
        );
      }
    } catch (e) {
      return Result.fromError(e);
    }
  }

  /// 회원가입
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _repository.createUserWithEmailAndPassword(email, password);
      
      if (result.isSuccess && result.user != null) {
        // 회원가입 성공 시 토큰 저장
        // await _saveTokenFromResult(result);
        return Result.success(result.user!);
      } else {
        return Result.failure(
          AuthenticationError(result.message),
        );
      }
    } catch (e) {
      return Result.fromError(e);
    }
  }

  /// 소셜 로그인
  Future<Result<AuthUser>> signInWithProvider(String provider) async {
    try {
      AuthResult result;
      
      switch (provider.toLowerCase()) {
        case 'google':
          result = await _repository.signInWithGoogle();
          break;
        case 'apple':
          result = await _repository.signInWithApple();
          break;
        case 'line':
          result = await _repository.signInWithLine();
          break;
        default:
          return Result.failure(
            const ValidationError(
              field: 'provider',
              reason: 'サポートされていないプロバイダーです',
            ),
          );
      }
      
      if (result.isSuccess && result.user != null) {
        // 소셜 로그인 성공 시 토큰 저장
        // await _saveTokenFromResult(result);
        return Result.success(result.user!);
      } else {
        return Result.failure(
          AuthenticationError(result.message),
        );
      }
    } catch (e) {
      return Result.fromError(e);
    }
  }

  /// 로그아웃
  Future<Result<void>> signOut() async {
    try {
      await _repository.signOut();
      await TokenStorageService.clearToken();
      await TokenStorageService.clearRememberMe();
      return Result.success(null);
    } catch (e) {
      return Result.fromError(e);
    }
  }

  /// 현재 인증 상태 확인
  Future<bool> isAuthenticated() async {
    try {
      return await TokenStorageService.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  /// 현재 사용자 정보 가져오기
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.fromError(e);
    }
  }

  /// 비밀번호 재설정 이메일 발송
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _repository.sendPasswordResetEmail(email);
      return Result.success(null);
    } catch (e) {
      return Result.fromError(e);
    }
  }

  // 향후 실제 API 연동시 사용할 토큰 저장 메서드
  // Future<void> _saveTokenFromResult(AuthResult result) async {
  //   // 실제 API response에서 토큰 정보 추출하여 저장
  //   final token = AuthToken(
  //     accessToken: result.accessToken,
  //     refreshToken: result.refreshToken,
  //     expiresAt: result.expiresAt,
  //   );
  //   await TokenStorageService.saveToken(token);
  // }
}