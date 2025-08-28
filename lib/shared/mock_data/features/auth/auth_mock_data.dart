import '../../base/mock_data_base.dart';

/// 인증 관련 Mock 데이터 서비스
///
/// 로그인, 회원가입, 소셜 로그인과 관련된 Mock 데이터를 제공합니다.
class AuthMockData {
  /// Mock 사용자 데이터
  static List<Map<String, dynamic>> getMockUsers() {
    return [
      {
        'id': 'mock_user_1',
        'email': 'test@example.com',
        'username': 'TestUser',
        'displayName': 'Test User',
        'photoUrl': null,
        'provider': 'email',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        'lastLoginAt': DateTime.now(),
        'isEmailVerified': true,
      },
      {
        'id': 'mock_user_2',
        'email': 'demo@aipet.com',
        'username': 'DemoUser',
        'displayName': 'Demo User',
        'photoUrl': null,
        'provider': 'email',
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
        'lastLoginAt': DateTime.now().subtract(const Duration(hours: 2)),
        'isEmailVerified': true,
      },
    ];
  }

  /// 소셜 로그인 Mock 사용자 생성
  static Map<String, dynamic> generateSocialUser(String provider) {
    final now = DateTime.now();
    
    switch (provider) {
      case 'google':
        return {
          'id': 'google_${MockDataBase.generateId()}',
          'email': 'google.user@gmail.com',
          'username': 'GoogleUser',
          'displayName': 'Google User',
          'photoUrl': 'https://ui-avatars.com/api/?name=Google+User&background=4285f4&color=fff',
          'provider': 'google',
          'createdAt': now,
          'lastLoginAt': now,
          'isEmailVerified': true,
        };
      
      case 'apple':
        return {
          'id': 'apple_${MockDataBase.generateId()}',
          'email': 'apple.user@icloud.com',
          'username': 'AppleUser',
          'displayName': 'Apple User',
          'photoUrl': 'https://ui-avatars.com/api/?name=Apple+User&background=000000&color=fff',
          'provider': 'apple',
          'createdAt': now,
          'lastLoginAt': now,
          'isEmailVerified': true,
        };
      
      case 'line':
        return {
          'id': 'line_${MockDataBase.generateId()}',
          'email': 'line.user@line.me',
          'username': 'LineUser',
          'displayName': 'LINE User',
          'photoUrl': 'https://ui-avatars.com/api/?name=LINE+User&background=00c300&color=fff',
          'provider': 'line',
          'createdAt': now,
          'lastLoginAt': now,
          'isEmailVerified': true,
        };
      
      default:
        return {
          'id': 'user_${MockDataBase.generateId()}',
          'email': 'user@example.com',
          'username': 'User',
          'displayName': 'User',
          'photoUrl': null,
          'provider': 'email',
          'createdAt': now,
          'lastLoginAt': now,
          'isEmailVerified': false,
        };
    }
  }

  /// 개발 모드 로그인 처리 (토큰 기반)
  /// 어떤 이메일/비밀번호든 성공하도록 처리
  static Future<Map<String, dynamic>> mockLogin(String email, String password) async {
    await MockDataBase.simulateApiDelay(milliseconds: 1000);

    // Mock 토큰 생성
    final accessToken = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken = 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
    final expiresAt = DateTime.now().add(const Duration(hours: 24)); // 24시간 후 만료

    final user = {
      'id': 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email.isNotEmpty ? email : 'dev@aipet.com',
      'username': email.isNotEmpty ? email.split('@')[0] : 'DevUser',
      'displayName': email.isNotEmpty ? email.split('@')[0] : 'Developer',
      'photoUrl': null,
      'provider': 'email',
      'createdAt': DateTime.now(),
      'lastLoginAt': DateTime.now(),
      'isEmailVerified': true,
    };

    final token = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': 'Bearer',
    };

    return {
      'success': true,
      'message': 'ログインに成功しました',
      'user': user,
      'token': token,
    };
  }

  /// 개발 모드 회원가입 처리 (토큰 기반)
  /// 어떤 정보든 성공하도록 처리
  static Future<Map<String, dynamic>> mockSignup(
    String email, 
    String password, 
    String username,
  ) async {
    await MockDataBase.simulateApiDelay(milliseconds: 1200);

    // Mock 토큰 생성
    final accessToken = 'mock_signup_token_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken = 'mock_signup_refresh_${DateTime.now().millisecondsSinceEpoch}';
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    final user = {
      'id': 'dev_signup_${DateTime.now().millisecondsSinceEpoch}',
      'email': email.isNotEmpty ? email : 'newuser@aipet.com',
      'username': username.isNotEmpty ? username : 'NewUser',
      'displayName': username.isNotEmpty ? username : 'New User',
      'photoUrl': null,
      'provider': 'email',
      'createdAt': DateTime.now(),
      'lastLoginAt': DateTime.now(),
      'isEmailVerified': false,
    };

    final token = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': 'Bearer',
    };

    return {
      'success': true,
      'message': '会員登録に成功しました',
      'user': user,
      'token': token,
    };
  }

  /// 소셜 로그인 Mock 처리 (토큰 기반)
  static Future<Map<String, dynamic>> mockSocialLogin(String provider) async {
    await MockDataBase.simulateApiDelay(milliseconds: 800);

    // Mock 토큰 생성
    final accessToken = 'mock_${provider}_token_${DateTime.now().millisecondsSinceEpoch}';
    final refreshToken = 'mock_${provider}_refresh_${DateTime.now().millisecondsSinceEpoch}';
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    final user = generateSocialUser(provider);
    final providerName = {
      'google': 'Google',
      'apple': 'Apple',
      'line': 'LINE',
    }[provider] ?? provider;

    final token = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': 'Bearer',
    };

    return {
      'success': true,
      'message': '$providerNameログインに成功しました',
      'user': user,
      'token': token,
    };
  }

  /// 로그아웃 Mock 처리
  static Future<Map<String, dynamic>> mockLogout() async {
    await MockDataBase.simulateApiDelay(milliseconds: 300);

    return {
      'success': true,
      'message': 'ログアウトに成功しました',
    };
  }

  /// 비밀번호 재설정 Mock 처리
  static Future<Map<String, dynamic>> mockPasswordReset(String email) async {
    await MockDataBase.simulateApiDelay(milliseconds: 500);

    return {
      'success': true,
      'message': 'パスワード再設定メールを送信しました',
      'email': email,
    };
  }

  /// 이메일 인증 Mock 처리
  static Future<Map<String, dynamic>> mockEmailVerification() async {
    await MockDataBase.simulateApiDelay(milliseconds: 400);

    return {
      'success': true,
      'message': '認証メールを送信しました',
    };
  }

  /// 현재 사용자 정보 Mock 반환
  static Future<Map<String, dynamic>?> mockGetCurrentUser() async {
    await MockDataBase.simulateApiDelay(milliseconds: 200);

    // 개발 모드에서는 항상 로그인된 사용자 반환
    return {
      'id': 'current_dev_user',
      'email': 'current@aipet.com',
      'username': 'CurrentUser',
      'displayName': 'Current Developer',
      'photoUrl': null,
      'provider': 'email',
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'lastLoginAt': DateTime.now().subtract(const Duration(minutes: 5)),
      'isEmailVerified': true,
    };
  }
}