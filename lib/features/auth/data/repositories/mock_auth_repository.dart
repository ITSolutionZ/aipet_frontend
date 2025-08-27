import 'package:mockito/annotations.dart';

import '../../domain/repositories/auth_repository.dart';

/// Mock AuthRepository 생성
///
/// Mockito를 사용하여 테스트용 Mock 객체를 생성합니다.
/// 추후 Firebase Auth 구현으로 교체할 때 이 파일만 수정하면 됩니다.
@GenerateMocks([AuthRepository])
void main() {}

/// Mock AuthRepository 구현체
///
/// 개발 중에는 이 Mock 구현체를 사용하고,
/// Firebase Auth 연동 후에는 실제 구현체로 교체합니다.
class MockAuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // 개발 중에는 모든 로그인을 성공으로 처리
    await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

    return AuthResult.success(
      '로그인되었습니다',
      user: AuthUser(
        uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        creationTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // 개발 중에는 모든 회원가입을 성공으로 처리
    await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

    return AuthResult.success(
      '회원가입이 완료되었습니다',
      user: AuthUser(
        uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        creationTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResult.success(
      'Google 로그인이 완료되었습니다',
      user: AuthUser(
        uid: 'mock_google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'google_user@example.com',
        displayName: 'Google User',
        creationTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResult.success(
      'Apple 로그인이 완료되었습니다',
      user: AuthUser(
        uid: 'mock_apple_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'apple_user@example.com',
        displayName: 'Apple User',
        creationTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<AuthResult> signInWithLine() async {
    await Future.delayed(const Duration(seconds: 1));
    return AuthResult.success(
      'LINE 로그인이 완료되었습니다',
      user: AuthUser(
        uid: 'mock_line_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'line_user@example.com',
        displayName: 'LINE User',
        creationTime: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    // 개발 중에는 항상 Mock 사용자 반환
    return AuthUser(
      uid: 'mock_current_user',
      email: 'current_user@example.com',
      displayName: 'Current User',
      creationTime: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
