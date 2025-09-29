import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';

/// Auth Feature 전용 Mock 데이터 서비스
class AuthMockService extends BaseMockService {
  // ==================== 사용자 인증 데이터 ====================

  /// Mock 사용자 정보
  static Map<String, dynamic> getMockUserInfo() {
    return {
      'id': 'user1',
      'email': 'test@example.com',
      'name': '테스트 사용자',
      'profileImageUrl': 'assets/images/profile/default_avatar.png',
      'createdAt': DateTime.now().subtract(Duration(days: 30)),
      'lastLoginAt': DateTime.now().subtract(Duration(hours: 2)),
      'isEmailVerified': true,
      'preferences': {
        'language': 'ko',
        'theme': 'light',
        'notifications': true,
      },
    };
  }

  /// Mock 로그인 응답
  static Future<Map<String, dynamic>> mockLogin({
    required String email,
    required String password,
  }) async {
    await MockHelper.simulateApiCall();

    // 간단한 Mock 검증
    if (email == 'test@example.com' && password == 'password') {
      return {
        'success': true,
        'user': getMockUserInfo(),
        'accessToken':
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresIn': 3600, // 1시간
      };
    } else {
      return {
        'success': false,
        'error': 'Invalid email or password',
        'errorCode': 'INVALID_CREDENTIALS',
      };
    }
  }

  /// Mock 회원가입 응답
  static Future<Map<String, dynamic>> mockSignUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await MockHelper.simulateApiCall();

    // 간단한 유효성 검사
    if (email.contains('@') && password.length >= 6 && name.isNotEmpty) {
      return {
        'success': true,
        'message': 'Account created successfully. Please verify your email.',
        'user': {
          'id': MockHelper.generateId(),
          'email': email,
          'name': name,
          'profileImageUrl': 'assets/images/profile/default_avatar.png',
          'createdAt': DateTime.now(),
          'isEmailVerified': false,
        },
      };
    } else {
      return {
        'success': false,
        'error': 'Invalid input data',
        'errorCode': 'VALIDATION_ERROR',
        'details': {
          'email': email.contains('@') ? null : 'Invalid email format',
          'password': password.length >= 6
              ? null
              : 'Password must be at least 6 characters',
          'name': name.isNotEmpty ? null : 'Name is required',
        },
      };
    }
  }

  /// Mock 이메일 인증 응답
  static Future<Map<String, dynamic>> mockEmailVerification({
    required String verificationCode,
  }) async {
    await MockHelper.simulateApiCall();

    if (verificationCode == '123456') {
      return {'success': true, 'message': 'Email verified successfully'};
    } else {
      return {
        'success': false,
        'error': 'Invalid verification code',
        'errorCode': 'INVALID_CODE',
      };
    }
  }

  /// Mock 비밀번호 재설정 요청
  static Future<Map<String, dynamic>> mockPasswordResetRequest({
    required String email,
  }) async {
    await MockHelper.simulateApiCall();

    if (email.contains('@')) {
      return {
        'success': true,
        'message': 'Password reset link sent to your email',
      };
    } else {
      return {
        'success': false,
        'error': 'Invalid email format',
        'errorCode': 'INVALID_EMAIL',
      };
    }
  }

  /// Mock 토큰 갱신 응답
  static Future<Map<String, dynamic>> mockTokenRefresh({
    required String refreshToken,
  }) async {
    await MockHelper.simulateApiCall();

    if (refreshToken.startsWith('mock_refresh_token_')) {
      return {
        'success': true,
        'accessToken':
            'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresIn': 3600,
      };
    } else {
      return {
        'success': false,
        'error': 'Invalid refresh token',
        'errorCode': 'INVALID_REFRESH_TOKEN',
      };
    }
  }

  // ==================== 소셜 로그인 ====================

  /// Mock Google 로그인 응답
  static Future<Map<String, dynamic>> mockGoogleLogin() async {
    await MockHelper.simulateApiCall();

    return {
      'success': true,
      'user': {
        ...getMockUserInfo(),
        'provider': 'google',
        'providerId': 'google_user_123',
      },
      'accessToken':
          'mock_google_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken':
          'mock_google_refresh_${DateTime.now().millisecondsSinceEpoch}',
      'expiresIn': 3600,
    };
  }

  /// Mock Apple 로그인 응답
  static Future<Map<String, dynamic>> mockAppleLogin() async {
    await MockHelper.simulateApiCall();

    return {
      'success': true,
      'user': {
        ...getMockUserInfo(),
        'provider': 'apple',
        'providerId': 'apple_user_456',
      },
      'accessToken':
          'mock_apple_token_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken':
          'mock_apple_refresh_${DateTime.now().millisecondsSinceEpoch}',
      'expiresIn': 3600,
    };
  }

  // ==================== 프로필 관리 ====================

  /// Mock 프로필 업데이트 응답
  static Future<Map<String, dynamic>> mockProfileUpdate({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    await MockHelper.simulateApiCall();

    final updatedUser = {
      ...getMockUserInfo(),
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'updatedAt': DateTime.now(),
    };

    return {
      'success': true,
      'user': updatedUser,
      'message': 'Profile updated successfully',
    };
  }

  /// Mock 프로필 이미지 업로드 응답
  static Future<Map<String, dynamic>> mockProfileImageUpload({
    required String imagePath,
  }) async {
    await MockHelper.simulateLongApiCall(); // 파일 업로드는 시간이 오래 걸림

    final uploadedUrl =
        'https://mock-storage.example.com/profiles/${MockHelper.generateId()}.jpg';

    return {
      'success': true,
      'imageUrl': uploadedUrl,
      'message': 'Profile image uploaded successfully',
    };
  }

  // ==================== 계정 관리 ====================

  /// Mock 비밀번호 변경 응답
  static Future<Map<String, dynamic>> mockPasswordChange({
    required String currentPassword,
    required String newPassword,
  }) async {
    await MockHelper.simulateApiCall();

    if (currentPassword == 'password' && newPassword.length >= 6) {
      return {'success': true, 'message': 'Password changed successfully'};
    } else {
      return {
        'success': false,
        'error': currentPassword != 'password'
            ? 'Current password is incorrect'
            : 'New password must be at least 6 characters',
        'errorCode': 'VALIDATION_ERROR',
      };
    }
  }

  /// Mock 계정 삭제 응답
  static Future<Map<String, dynamic>> mockAccountDeletion({
    required String password,
    required String reason,
  }) async {
    await MockHelper.simulateApiCall();

    if (password == 'password') {
      return {
        'success': true,
        'message': 'Account deleted successfully',
        'deletionId': MockHelper.generateId(),
      };
    } else {
      return {
        'success': false,
        'error': 'Incorrect password',
        'errorCode': 'INVALID_PASSWORD',
      };
    }
  }

  // ==================== 세션 관리 ====================

  /// Mock 로그아웃 응답
  static Future<Map<String, dynamic>> mockLogout() async {
    await MockHelper.simulateApiCall();

    return {'success': true, 'message': 'Logged out successfully'};
  }

  /// Mock 세션 검증 응답
  static Future<Map<String, dynamic>> mockSessionValidation({
    required String accessToken,
  }) async {
    await MockHelper.simulateApiCall();

    if (accessToken.startsWith('mock_access_token_')) {
      return {
        'success': true,
        'valid': true,
        'user': getMockUserInfo(),
        'expiresIn': 1800, // 30분 남음
      };
    } else {
      return {
        'success': false,
        'valid': false,
        'error': 'Invalid or expired token',
        'errorCode': 'TOKEN_EXPIRED',
      };
    }
  }

  // ==================== 기기 관리 ====================

  /// Mock 등록된 기기 목록
  static List<Map<String, dynamic>> getMockRegisteredDevices() {
    return [
      {
        'id': MockHelper.generateId(),
        'deviceName': 'iPhone 14',
        'deviceType': 'mobile',
        'platform': 'iOS',
        'lastActive': DateTime.now().subtract(const Duration(minutes: 5)),
        'isCurrentDevice': true,
        'location': '서울, 대한민국',
      },
      {
        'id': MockHelper.generateId(),
        'deviceName': 'iPad Air',
        'deviceType': 'tablet',
        'platform': 'iPadOS',
        'lastActive': DateTime.now().subtract(Duration(days: 2)),
        'isCurrentDevice': false,
        'location': '서울, 대한민국',
      },
    ];
  }

  /// Mock 기기 등록 해제 응답
  static Future<Map<String, dynamic>> mockDeviceUnregister({
    required String deviceId,
  }) async {
    await MockHelper.simulateApiCall();

    return {
      'success': true,
      'message': 'Device unregistered successfully',
      'deviceId': deviceId,
    };
  }
}
