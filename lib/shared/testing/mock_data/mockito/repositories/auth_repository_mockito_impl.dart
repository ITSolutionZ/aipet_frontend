import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';
import 'package:mockito/mockito.dart';

/// 🎭 Auth Repository Mockito 구현체
///
/// ⚠️ 이 파일은 Mockito 전용입니다!
/// 프로덕션 배포 시 mockito/ 폴더를 삭제하면 자동으로 제거됩니다.
class AuthRepositoryMockitoImpl extends Mock implements AuthRepository {
  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(String email, String password) async {
    await BaseMockService.simulateApiDelay();

    // Mock 시나리오: 성공적인 로그인
    if (email.isNotEmpty && password.isNotEmpty) {
      final mockUser = AuthUser(
        uid: 'mock_user_123',
        email: email,
        displayName: 'Mockito User',
        photoURL: null,
        isEmailVerified: true,
        creationTime: DateTime.now(),
      );
      return Result.success('Mockito 로그인 성공', mockUser);
    } else {
      return Result.failure('이메일과 패스워드를 입력해주세요');
    }
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(String email, String password) async {
    await BaseMockService.simulateApiDelay();
    final mockUser = AuthUser(
      uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: 'Mockito User',
      photoURL: null,
      isEmailVerified: false,
      creationTime: DateTime.now(),
    );
    return Result.success('Mockito 회원가입 성공', mockUser);
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    await BaseMockService.simulateApiDelay();
    final mockUser = AuthUser(
      uid: 'mock_google_user_123',
      email: 'mockito@google.com',
      displayName: 'Mockito Google User',
      photoURL: 'https://example.com/avatar.jpg',
      isEmailVerified: true,
      creationTime: DateTime.now(),
    );
    return Result.success('Mockito Google 로그인 성공', mockUser);
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    await BaseMockService.simulateApiDelay();
    final mockUser = AuthUser(
      uid: 'mock_apple_user_123',
      email: 'mockito@privaterelay.appleid.com',
      displayName: 'Mockito Apple User',
      photoURL: null,
      isEmailVerified: true,
      creationTime: DateTime.now(),
    );
    return Result.success('Mockito Apple 로그인 성공', mockUser);
  }

  @override
  Future<Result<AuthUser>> signInWithLine() async {
    await BaseMockService.simulateApiDelay();
    final mockUser = AuthUser(
      uid: 'mock_line_user_123',
      email: 'mockito@line.com',
      displayName: 'Mockito LINE User',
      photoURL: 'https://example.com/line_avatar.jpg',
      isEmailVerified: true,
      creationTime: DateTime.now(),
    );
    return Result.success('Mockito LINE 로그인 성공', mockUser);
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
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<void> deleteAccount() async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<String> exchangeServerToken(String idToken) async {
    await BaseMockService.simulateApiDelay();
    return 'mock_server_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    await BaseMockService.simulateApiDelay();
    return 'mock_firebase_id_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String?> getStoredServerToken() async {
    await BaseMockService.simulateApiDelay();
    return null;
  }

  @override
  Future<void> saveServerToken(String token) async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<void> clearServerToken() async {
    await BaseMockService.simulateApiDelay();
  }

  @override
  Future<bool> isAuthenticated() async {
    await BaseMockService.simulateApiDelay();
    return false;
  }
}
