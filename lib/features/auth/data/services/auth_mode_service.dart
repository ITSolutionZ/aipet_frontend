import 'package:flutter/foundation.dart';

import '../../../../app/config/app_config.dart';
import '../../domain/domain.dart';

/// 🎯 Auth 모드 서비스
///
/// 개발/프로덕션 모드에 따른 인증 로직을 분리
class AuthModeService {
  /// 현재 Mock 모드 여부
  static bool get isMockMode => AppConfig.current.isMockMode;

  /// 임시 로그인 사용자 생성 (개발 모드용)
  static AuthUser createTempUser(String email) {
    final now = DateTime.now();
    return AuthUser(
      uid: 'temp_user_${now.millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0], // 이메일에서 사용자명 추출
      isEmailVerified: true,
      creationTime: now,
      lastSignInTime: now,
      customData: {'isTempLogin': true, 'tempLoginTime': now.toIso8601String()},
    );
  }

  /// 임시 회원가입 사용자 생성 (개발 모드용)
  static AuthUser createTempSignupUser(String email) {
    final now = DateTime.now();
    return AuthUser(
      uid: 'temp_signup_${now.millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0],
      isEmailVerified: false, // 회원가입 시에는 이메일 미인증
      creationTime: now,
      lastSignInTime: now,
      customData: {
        'isTempSignup': true,
        'tempSignupTime': now.toIso8601String(),
      },
    );
  }

  /// 임시 소셜 로그인 사용자 생성 (개발 모드용)
  static AuthUser createTempSocialUser(String provider, String email) {
    final now = DateTime.now();
    return AuthUser(
      uid: 'temp_${provider}_${now.millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0],
      isEmailVerified: true,
      creationTime: now,
      lastSignInTime: now,
      customData: {
        'isTempSocialLogin': true,
        'provider': provider,
        'tempSocialLoginTime': now.toIso8601String(),
      },
    );
  }

  /// 임시 로그인 로그 출력
  static void logTempLogin(String email, String method) {
    if (isMockMode) {
      debugPrint('🚨 AuthModeService: 임시 $method - 이메일: $email');
    }
  }

  /// 임시 로그인 성공 메시지
  static String getTempLoginMessage(String method) {
    return '임시 $method이 완료되었습니다';
  }

  /// 임시 회원가입 성공 메시지
  static String getTempSignupMessage() {
    return '임시 회원가입이 완료되었습니다';
  }

  /// 임시 소셜 로그인 성공 메시지
  static String getTempSocialLoginMessage(String provider) {
    return '임시 $provider 로그인이 완료되었습니다';
  }
}
