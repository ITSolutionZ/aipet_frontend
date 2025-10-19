import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// 생체인증 서비스 (지문, 얼굴인식)
class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  late LocalAuthentication _localAuth;

  BiometricAuthService._internal() {
    _localAuth = LocalAuthentication();
  }

  static BiometricAuthService get instance => _instance;

  /// 디바이스가 생체인증을 지원하는지 확인
  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('생체인증 확인 실패: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// 디바이스가 디바이스 크리덴셜(PIN, 패턴, 비밀번호)을 지원하는지 확인
  Future<bool> canAuthenticateWithDeviceCredential() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('디바이스 크리덴셜 확인 실패: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// 사용 가능한 생체인증 타입 확인
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('사용 가능한 생체인증 확인 실패: ${e.code} - ${e.message}');
      return [];
    }
  }

  /// 생체인증 수행 (지문 또는 얼굴)
  Future<bool> authenticate() async {
    try {
      // 생체인증이 지원되는지 확인
      final canAuth = await canAuthenticateWithBiometrics();
      if (!canAuth) {
        debugPrint('生体認証が利用できません');
        return false;
      }

      // 사용 가능한 생체인증 타입 확인
      final biometrics = await getAvailableBiometrics();
      final localizedReason = _getLocalizedReason(biometrics);

      // 생체인증 수행
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      debugPrint('生体認証失敗: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// 생체인증 타입에 따른 로컬라이즈된 메시지 반환
  String _getLocalizedReason(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.face)) {
      return '顔認証してください';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return '指紋認証してください';
    } else if (biometrics.contains(BiometricType.iris)) {
      return '虹彩認証してください';
    }
    return '生体認証してください';
  }

  /// 얼굴 인식으로만 인증 (지원하는 경우)
  Future<bool> authenticateWithFace() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (!biometrics.contains(BiometricType.face)) {
        debugPrint('顔認証がこのデバイスでサポートされていません');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: '顔認証してください',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      debugPrint('顔認証失敗: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// 지문 인식으로만 인증 (지원하는 경우)
  Future<bool> authenticateWithFingerprint() async {
    try {
      final biometrics = await getAvailableBiometrics();
      if (!biometrics.contains(BiometricType.fingerprint)) {
        debugPrint('指紋認証がこのデバイスでサポートされていません');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: '指紋認証してください',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      debugPrint('指紋認証失敗: ${e.code} - ${e.message}');
      return false;
    }
  }

  /// 생체인증 또는 디바이스 크리덴셜로 인증
  /// (디바이스에 생체인증이 없으면 PIN/패턴/비밀번호 사용)
  Future<bool> authenticateWithBiometricOrDeviceCredential() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: '본인 인증 필요',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // 디바이스 크리덴셜도 허용
        ),
      );

      return isAuthenticated;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        debugPrint('생체인증 또는 디바이스 크리덴셜이 설정되지 않았습니다');
      } else if (e.code == 'PermanentlyLockedOut') {
        debugPrint('생체인증이 너무 많이 실패하여 잠겼습니다');
      } else if (e.code == 'PasscodeNotSet') {
        debugPrint('디바이스 보안이 설정되지 않았습니다');
      } else {
        debugPrint('인증 실패: ${e.code} - ${e.message}');
      }
      return false;
    }
  }

  /// 생체인증 중단
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException catch (e) {
      debugPrint('생체인증 중단 실패: ${e.code} - ${e.message}');
    }
  }
}
