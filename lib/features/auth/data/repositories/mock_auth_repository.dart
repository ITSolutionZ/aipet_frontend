import 'package:mockito/annotations.dart';

import '../../../../shared/mock_data/mock_data.dart';
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
    try {
      // 개발 모드에서는 모든 입력을 성공으로 처리
      final mockResult = await AuthMockData.mockLogin(email, password);
      
      // Null safety 강화
      final userData = mockResult['user'];
      final tokenData = mockResult['token'];
      
      if (userData is! Map<String, dynamic> || tokenData is! Map<String, dynamic>) {
        return AuthResult.failure('認証データが不正です', errorCode: 'INVALID_DATA');
      }

      // 필수 필드 검증
      final uid = userData['id'];
      final userEmail = userData['email'];
      final displayName = userData['displayName'];
      
      if (uid is! String || userEmail is! String || displayName is! String) {
        return AuthResult.failure('ユーザーデータが不正です', errorCode: 'INVALID_USER_DATA');
      }

      // Mock 토큰을 저장 (실제 앱에서는 TokenStorageService 사용)
      // 개발 환경에서는 토큰 저장 생략 가능
      
      return AuthResult.success(
        mockResult['message'] as String? ?? 'ログイン成功',
        user: AuthUser(
          uid: uid,
          email: userEmail,
          displayName: displayName,
          isEmailVerified: userData['isEmailVerified'] as bool? ?? false,
          creationTime: userData['createdAt'] as DateTime? ?? DateTime.now(),
          lastSignInTime: userData['lastLoginAt'] as DateTime? ?? DateTime.now(),
        ),
      );
    } catch (e) {
      return AuthResult.failure(
        'ログインに失敗しました', 
        errorCode: 'LOGIN_ERROR',
      );
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // 개발 모드에서는 모든 회원가입을 성공으로 처리
    final mockResult = await AuthMockData.mockSignup(
      email, 
      password, 
      email.split('@')[0],
    );
    final userData = mockResult['user'] as Map<String, dynamic>;

    return AuthResult.success(
      mockResult['message'] as String,
      user: AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: userData['createdAt'] as DateTime,
        lastSignInTime: userData['lastLoginAt'] as DateTime,
      ),
    );
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    final mockResult = await AuthMockData.mockSocialLogin('google');
    final userData = mockResult['user'] as Map<String, dynamic>;

    return AuthResult.success(
      mockResult['message'] as String,
      user: AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        photoURL: userData['photoUrl'] as String?,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: userData['createdAt'] as DateTime,
        lastSignInTime: userData['lastLoginAt'] as DateTime,
      ),
    );
  }

  @override
  Future<AuthResult> signInWithApple() async {
    final mockResult = await AuthMockData.mockSocialLogin('apple');
    final userData = mockResult['user'] as Map<String, dynamic>;

    return AuthResult.success(
      mockResult['message'] as String,
      user: AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        photoURL: userData['photoUrl'] as String?,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: userData['createdAt'] as DateTime,
        lastSignInTime: userData['lastLoginAt'] as DateTime,
      ),
    );
  }

  @override
  Future<AuthResult> signInWithLine() async {
    final mockResult = await AuthMockData.mockSocialLogin('line');
    final userData = mockResult['user'] as Map<String, dynamic>;

    return AuthResult.success(
      mockResult['message'] as String,
      user: AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        photoURL: userData['photoUrl'] as String?,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: userData['createdAt'] as DateTime,
        lastSignInTime: userData['lastLoginAt'] as DateTime,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await AuthMockData.mockLogout();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final userData = await AuthMockData.mockGetCurrentUser();
    if (userData == null) return null;

    return AuthUser(
      uid: userData['id'] as String,
      email: userData['email'] as String,
      displayName: userData['displayName'] as String,
      photoURL: userData['photoUrl'] as String?,
      isEmailVerified: userData['isEmailVerified'] as bool,
      creationTime: userData['createdAt'] as DateTime,
      lastSignInTime: userData['lastLoginAt'] as DateTime,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await AuthMockData.mockPasswordReset(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    await AuthMockData.mockEmailVerification();
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
