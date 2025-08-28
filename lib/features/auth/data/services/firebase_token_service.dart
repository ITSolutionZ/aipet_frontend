import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/services/secure_storage_service_v2.dart';

/// Firebase ID Token 관리 서비스
/// 
/// Firebase ID Token의 자동 갱신, 검증, 저장을 담당합니다.
class FirebaseTokenService {
  static const String _firebaseIdTokenKey = 'firebase_id_token';
  static const String _firebaseIdTokenExpiresKey = 'firebase_id_token_expires';
  
  static FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  /// 현재 유효한 Firebase ID Token 가져오기 (자동 갱신 포함)
  static Future<String?> getCurrentIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('Firebase 사용자가 로그인되어 있지 않습니다');
        }
        return null;
      }

      // forceRefresh가 true이거나 토큰이 곧 만료될 경우 강제 갱신
      final shouldForceRefresh = forceRefresh || await _shouldRefreshToken();
      
      final idToken = await user.getIdToken(shouldForceRefresh);
      
      if (idToken != null) {
        // 새 토큰을 안전하게 저장
        await _cacheIdToken(idToken);
        
        if (kDebugMode) {
          debugPrint('Firebase ID Token 가져오기 성공${shouldForceRefresh ? ' (갱신됨)' : ''}');
        }
        
        return idToken;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase ID Token 가져오기 실패: $e');
      }
      
      // Firebase 토큰 가져오기 실패 시 캐시된 토큰 시도
      return _getCachedIdToken();
    }
  }

  /// Firebase ID Token을 강제로 갱신
  static Future<String?> refreshIdToken() async {
    return getCurrentIdToken(forceRefresh: true);
  }

  /// ID Token이 유효한지 확인
  static Future<bool> isIdTokenValid() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // 토큰 만료 확인
      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;
      
      if (expirationTime == null) return false;
      
      // 현재 시간보다 5분 이상 남아있으면 유효
      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
      return expirationTime.isAfter(fiveMinutesFromNow);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ID Token 유효성 확인 실패: $e');
      }
      return false;
    }
  }

  /// 토큰을 갱신해야 하는지 확인
  static Future<bool> _shouldRefreshToken() async {
    try {
      final cachedExpires = await SecureStorageServiceV2.getString(_firebaseIdTokenExpiresKey);
      if (cachedExpires == null) return true;
      
      final expirationTime = DateTime.parse(cachedExpires);
      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
      
      return expirationTime.isBefore(fiveMinutesFromNow);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('토큰 만료 확인 실패: $e');
      }
      return true; // 확인 실패 시 안전하게 갱신
    }
  }

  /// ID Token을 캐시에 저장
  static Future<void> _cacheIdToken(String idToken) async {
    try {
      // Firebase에서 토큰 정보 가져오기
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;
      
      if (expirationTime != null) {
        await Future.wait([
          SecureStorageServiceV2.setString(_firebaseIdTokenKey, idToken),
          SecureStorageServiceV2.setString(
            _firebaseIdTokenExpiresKey, 
            expirationTime.toIso8601String(),
          ),
        ]);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ID Token 캐시 저장 실패: $e');
      }
    }
  }

  /// 캐시된 ID Token 가져오기
  static Future<String?> _getCachedIdToken() async {
    try {
      final cachedToken = await SecureStorageServiceV2.getString(_firebaseIdTokenKey);
      final cachedExpires = await SecureStorageServiceV2.getString(_firebaseIdTokenExpiresKey);
      
      if (cachedToken == null || cachedExpires == null) {
        return null;
      }
      
      final expirationTime = DateTime.parse(cachedExpires);
      final now = DateTime.now();
      
      // 만료되지 않은 캐시된 토큰만 반환
      if (expirationTime.isAfter(now)) {
        if (kDebugMode) {
          debugPrint('캐시된 Firebase ID Token 사용');
        }
        return cachedToken;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('캐시된 ID Token 가져오기 실패: $e');
      }
    }
    
    return null;
  }

  /// Firebase ID Token 캐시 삭제
  static Future<void> clearCachedIdToken() async {
    try {
      await Future.wait([
        SecureStorageServiceV2.remove(_firebaseIdTokenKey),
        SecureStorageServiceV2.remove(_firebaseIdTokenExpiresKey),
      ]);
      
      if (kDebugMode) {
        debugPrint('Firebase ID Token 캐시 삭제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase ID Token 캐시 삭제 실패: $e');
      }
    }
  }

  /// Firebase 사용자 상태 변경 리스너 설정
  static void setupAuthStateListener() {
    _firebaseAuth.authStateChanges().listen((User? user) async {
      if (user == null) {
        // 로그아웃 시 캐시된 토큰 삭제
        await clearCachedIdToken();
        if (kDebugMode) {
          debugPrint('Firebase 사용자 로그아웃 - 캐시 삭제됨');
        }
      } else {
        // 로그인 시 새 토큰 캐시
        try {
          final idToken = await user.getIdToken();
          if (idToken != null) {
            await _cacheIdToken(idToken);
            if (kDebugMode) {
              debugPrint('Firebase 사용자 로그인 - 새 토큰 캐시됨');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('로그인 후 토큰 캐시 실패: $e');
          }
        }
      }
    });
  }

  /// Firebase ID Token의 클레임 정보 가져오기
  static Future<Map<String, dynamic>?> getIdTokenClaims() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final tokenResult = await user.getIdTokenResult();
      return tokenResult.claims;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ID Token 클레임 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// Firebase 사용자가 이메일 인증을 완료했는지 확인
  static Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // 최신 상태로 새로고침
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      
      return updatedUser?.emailVerified ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('이메일 인증 상태 확인 실패: $e');
      }
      return false;
    }
  }

  /// 이메일 인증 메일 재발송
  static Future<bool> resendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.emailVerified) return false;

      await user.sendEmailVerification();
      
      if (kDebugMode) {
        debugPrint('이메일 인증 메일 발송 완료');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('이메일 인증 메일 발송 실패: $e');
      }
      return false;
    }
  }
}