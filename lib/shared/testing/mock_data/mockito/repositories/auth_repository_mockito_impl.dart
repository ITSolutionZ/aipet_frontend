import 'package:aipet_frontend/features/auth/auth.dart';
import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';
import 'package:mockito/mockito.dart';

/// 🎭 Auth Repository Mockito 구현체
///
/// ⚠️ 이 파일은 Mockito 전용입니다!
/// 프로덕션 배포 시 mockito/ 폴더를 삭제하면 자동으로 제거됩니다.
class AuthRepositoryMockitoImpl extends Mock implements AuthRepository {
  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await BaseMockService.simulateApiDelay();

    // Mock 시나리오: 성공적인 로그인
    if (email.isNotEmpty && password.isNotEmpty) {
      return AuthResult.success('Mockito 로그인 성공');
    } else {
      return AuthResult.failure('이메일과 패스워드를 입력해주세요');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await BaseMockService.simulateApiDelay();
    return AuthResult.success('Mockito 회원가입 성공');
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    await BaseMockService.simulateApiDelay();
    return AuthResult.success('Mockito Google 로그인 성공');
  }

  @override
  Future<AuthResult> signInWithApple() async {
    await BaseMockService.simulateApiDelay();
    return AuthResult.success('Mockito Apple 로그인 성공');
  }

  @override
  Future<AuthResult> signInWithLine() async {
    await BaseMockService.simulateApiDelay();
    return AuthResult.success('Mockito LINE 로그인 성공');
  }

  @override
  Future<void> signOut() async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    await BaseMockService.simulateApiDelay();
    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<void> sendEmailVerification() async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<void> deleteAccount() async {
    await BaseMockService.simulateApiDelay();
  }
}
