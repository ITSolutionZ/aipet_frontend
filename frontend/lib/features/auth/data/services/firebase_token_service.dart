import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';

/// Firebase ID Token 관리 서비스
///
/// Firebase ID Token의 자동 갱신, 검증, 저장을 담당합니다.
class FirebaseTokenService {
  static const String _firebaseIdTokenKey = 'firebase_id_token';
  static const String _firebaseIdTokenExpiresKey = 'firebase_id_token_expires';

  static FirebaseAuth? _firebaseAuthInstance;

  static FirebaseAuth get _firebaseAuth {
    return _firebaseAuthInstance ??= FirebaseAuth.instance;
  }

  /// Firebase가 초기화되어 있는지 확인
  ///
  /// Firebase 앱이 제대로 초기화되었는지 확인합니다.
  /// 초기화되지 않은 경우 토큰 관련 작업을 수행하지 않습니다.
  ///
  /// Returns: Firebase 초기화 여부
  static bool get _isFirebaseInitialized {
    try {
      // Firebase 앱 목록이 비어있지 않으면 초기화된 것으로 간주
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      // Firebase 초기화 실패 시 false 반환
      if (kDebugMode) {
        LoggerService.debug('Firebase 초기화 상태 확인 실패: $e');
      }
      return false;
    }
  }

  /// 현재 유효한 Firebase ID Token 가져오기 (자동 갱신 포함)
  static Future<String?> getCurrentIdToken({bool forceRefresh = false}) async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        LoggerService.debug('Firebase가 초기화되지 않음 - 캐시된 토큰 시도');
      }
      return _getCachedIdToken();
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          LoggerService.debug('Firebase 사용자가 로그인되어 있지 않습니다');
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
          LoggerService.debug(
            'Firebase ID Token 가져오기 성공${shouldForceRefresh ? ' (갱신됨)' : ''}',
          );
        }

        return idToken;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('Firebase ID Token 가져오기 실패: $e');
      }

      // Firebase 토큰 가져오기 실패 시 캐시된 토큰 시도
      return _getCachedIdToken();
    }
  }

  /// Firebase ID Token을 강제로 갱신
  static Future<String?> refreshIdToken() async {
    return getCurrentIdToken(forceRefresh: true);
  }

  /// 🔐 ID Token이 유효한지 확인 (JWT 구조 검증 포함)
  static Future<bool> isIdTokenValid() async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        LoggerService.debug('Firebase가 초기화되지 않음 - ID 토큰 유효성 검사 건너뜀');
      }
      return false;
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // 1. 현재 토큰 가져오기
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) return false;

      // 2. JWT 구조 검증 수행
      final structureValidation = JwtValidationService.validateFirebaseIdToken(
        idToken,
      );
      if (!structureValidation.isSuccess) {
        if (kDebugMode) {
          LoggerService.debug(
            '🔐 JWT 구조 검증 실패: ${structureValidation.error?.toString() ?? 'Unknown error'}',
          );
        }
        return false;
      }

      // 3. 보안 등급 평가
      final securityLevel = JwtValidationService.evaluateSecurityLevel(
        structureValidation.dataOrNull!,
      );
      if (securityLevel.level == SecurityLevel.critical) {
        if (kDebugMode) {
          LoggerService.debug(
            '🚨 심각한 JWT 보안 문제 발견: ${securityLevel.recommendation}',
          );
        }
        return false;
      }

      // 4. 기존 Firebase 만료 시간 확인
      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;

      if (expirationTime == null) return false;

      // 현재 시간보다 5분 이상 남아있으면 유효
      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
      final isTimeValid = expirationTime.isAfter(fiveMinutesFromNow);

      if (kDebugMode && securityLevel.level != SecurityLevel.high) {
        LoggerService.debug(
          '⚠️ JWT 보안 등급: ${securityLevel.level.displayName} (점수: ${securityLevel.score}/${securityLevel.maxScore})',
        );
        LoggerService.debug('💡 권장사항: ${securityLevel.recommendation}');
      }

      return isTimeValid;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('ID Token 유효성 확인 실패: $e');
      }
      return false;
    }
  }

  /// 토큰을 갱신해야 하는지 확인
  static Future<bool> _shouldRefreshToken() async {
    try {
      final cachedExpires = await SecureStorageService.getString(
        _firebaseIdTokenExpiresKey,
      );
      if (cachedExpires == null) return true;

      final expirationTime = DateTime.parse(cachedExpires);
      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));

      return expirationTime.isBefore(fiveMinutesFromNow);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('토큰 만료 확인 실패: $e');
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
          SecureStorageService.setString(_firebaseIdTokenKey, idToken),
          SecureStorageService.setString(
            _firebaseIdTokenExpiresKey,
            expirationTime.toIso8601String(),
          ),
        ]);
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('ID Token 캐시 저장 실패: $e');
      }
    }
  }

  /// 캐시된 ID Token 가져오기
  static Future<String?> _getCachedIdToken() async {
    try {
      final cachedToken = await SecureStorageService.getString(
        _firebaseIdTokenKey,
      );
      final cachedExpires = await SecureStorageService.getString(
        _firebaseIdTokenExpiresKey,
      );

      if (cachedToken == null || cachedExpires == null) {
        return null;
      }

      final expirationTime = DateTime.parse(cachedExpires);
      final now = DateTime.now();

      // 만료되지 않은 캐시된 토큰만 반환
      if (expirationTime.isAfter(now)) {
        if (kDebugMode) {
          LoggerService.debug('캐시된 Firebase ID Token 사용');
        }
        return cachedToken;
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('캐시된 ID Token 가져오기 실패: $e');
      }
    }

    return null;
  }

  /// Firebase ID Token 캐시 삭제
  static Future<void> clearCachedIdToken() async {
    try {
      await Future.wait([
        SecureStorageService.remove(_firebaseIdTokenKey),
        SecureStorageService.remove(_firebaseIdTokenExpiresKey),
      ]);

      if (kDebugMode) {
        LoggerService.debug('Firebase ID Token 캐시 삭제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('Firebase ID Token 캐시 삭제 실패: $e');
      }
    }
  }

  /// Firebase 사용자 상태 변경 리스너 설정
  static void setupAuthStateListener() {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        LoggerService.debug('Firebase가 초기화되지 않아 Auth State Listener 설정을 건너뜀');
      }
      return;
    }

    try {
      _firebaseAuth.authStateChanges().listen((User? user) async {
        if (user == null) {
          // 로그아웃 시 캐시된 토큰 삭제
          await clearCachedIdToken();
          if (kDebugMode) {
            LoggerService.debug('Firebase 사용자 로그아웃 - 캐시 삭제됨');
          }
        } else {
          // 로그인 시 새 토큰 캐시
          try {
            final idToken = await user.getIdToken();
            if (idToken != null) {
              await _cacheIdToken(idToken);
              if (kDebugMode) {
                LoggerService.debug('Firebase 사용자 로그인 - 새 토큰 캐시됨');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              LoggerService.debug('로그인 후 토큰 캐시 실패: $e');
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('Auth State Listener 설정 실패: $e');
      }
    }
  }

  /// Firebase ID Token의 클레임 정보 가져오기
  static Future<Map<String, dynamic>?> getIdTokenClaims() async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        LoggerService.debug('Firebase가 초기화되지 않음 - ID 토큰 클레임 가져오기 건너뜀');
      }
      return null;
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final tokenResult = await user.getIdTokenResult();
      return tokenResult.claims;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('ID Token 클레임 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// トークン情報のデバッグ出力
  static Future<void> debugTokenInfo({bool showFullToken = false}) async {
    LoggerService.debug(
      '🚀 debugTokenInfo呼び出し - showFullToken: $showFullToken',
    );

    if (!kDebugMode) {
      LoggerService.debug('⚠️ kDebugMode = false - トークン表示をスキップ');
      return;
    }

    if (!_isFirebaseInitialized) {
      LoggerService.debug('🔍 [Firebase Token Debug] Firebase未初期化');
      return;
    }

    try {
      final user = _firebaseAuth.currentUser;
      LoggerService.debug('👤 現在のユーザー: ${user?.uid ?? "null"}');

      if (user == null) {
        LoggerService.debug('🔍 [Firebase Token Debug] ログインしていません');
        return;
      }

      LoggerService.debug('🔑 getIdToken()呼び出し中...');
      final idToken = await user.getIdToken();
      LoggerService.debug('✅ getIdToken()完了 - 長さ: ${idToken?.length}');

      LoggerService.debug('🔑 getIdTokenResult()呼び出し中...');
      final tokenResult = await user.getIdTokenResult();
      LoggerService.debug('✅ getIdTokenResult()完了');

      LoggerService.debug('🔍 [Firebase Token Debug] ================');
      LoggerService.debug('   ユーザーUID: ${user.uid}');
      LoggerService.debug('   メール: ${user.email}');
      LoggerService.debug('   メール確認: ${user.emailVerified}');
      LoggerService.debug('   トークン長: ${idToken?.length ?? 0}文字');

      if (idToken != null) {
        if (showFullToken) {
          // フルトークンを表示（開発専用 - セキュリティ注意！）
          LoggerService.debug('   🔑 フルトークン:');
          LoggerService.debug('   $idToken');
        } else {
          // セキュリティのため、最初と最後のみ表示
          final prefix = idToken.substring(
            0,
            idToken.length > 30 ? 30 : idToken.length,
          );
          final suffix = idToken.length > 60
              ? idToken.substring(idToken.length - 30)
              : '';
          LoggerService.debug('   🔑 トークン（一部）: $prefix...$suffix');
        }
      }

      LoggerService.debug('   発行時間: ${tokenResult.issuedAtTime}');
      LoggerService.debug('   有効期限: ${tokenResult.expirationTime}');
      LoggerService.debug('   署名プロバイダー: ${tokenResult.signInProvider}');

      // 残り時間を計算
      if (tokenResult.expirationTime != null) {
        final remaining = tokenResult.expirationTime!.difference(
          DateTime.now(),
        );
        LoggerService.debug(
          '   残り時間: ${remaining.inMinutes}分 ${remaining.inSeconds % 60}秒',
        );
      }

      // クレーム情報
      if (tokenResult.claims != null && tokenResult.claims!.isNotEmpty) {
        LoggerService.debug('   📋 クレーム情報:');
        tokenResult.claims!.forEach((key, value) {
          LoggerService.debug('      - $key: $value');
        });
      }

      LoggerService.debug('=========================================');
    } catch (e) {
      LoggerService.debug('❌ トークンデバッグ情報出力失敗: $e');
    }
  }

  /// 🧪 테스트용: 전체 토큰 표시
  ///
  /// ⚠️ 경고: 보안을 위해 프로덕션 환경에서는 사용하지 마세요!
  /// 디버그 모드에서만 동작합니다.
  static Future<void> debugFullToken() async {
    // Step 1: 메서드 진입 확인
    LoggerService.debug('');
    LoggerService.debug('🚀🚀🚀 debugFullToken() 메서드 진입!');
    LoggerService.debug('📱 kDebugMode 상태: $kDebugMode');

    if (!kDebugMode) {
      LoggerService.debug('⚠️ kDebugMode가 false - 토큰 표시 건너뜀');
      return;
    }

    LoggerService.debug('');
    LoggerService.debug('🧪 =======================================');
    LoggerService.debug('🧪 [TEST MODE] 전체 토큰 표시');
    LoggerService.debug('🧪 ⚠️ 보안 주의: 프로덕션에서 사용 금지!');
    LoggerService.debug('🧪 =======================================');

    // Step 2: Firebase 초기화 상태 확인
    LoggerService.debug('🔍 Firebase 초기화 상태 확인 중...');
    final isInit = _isFirebaseInitialized;
    LoggerService.debug('🧪 Firebase 초기화: $isInit');

    // Step 3: debugTokenInfo 호출
    try {
      LoggerService.debug('📞 debugTokenInfo(showFullToken: true) 호출...');
      await debugTokenInfo(showFullToken: true);
      LoggerService.debug('✅ debugTokenInfo 완료!');
    } catch (e) {
      LoggerService.debug('❌ debugTokenInfo 에러: $e');
      LoggerService.debug('스택: ${StackTrace.current}');
    }

    // キャッシュされたトークンも表示
    try {
      final cachedToken = await _getCachedIdToken();
      LoggerService.debug('');
      LoggerService.debug('💾 [Cached Token] ==================');
      if (cachedToken == null) {
        LoggerService.debug('   キャッシュされたトークンなし');
      } else {
        LoggerService.debug('   トークン長: ${cachedToken.length}文字');
        LoggerService.debug('   🔑 キャッシュトークン（フル）:');
        LoggerService.debug('   $cachedToken');
      }
      LoggerService.debug('======================================');
    } catch (e) {
      LoggerService.debug('❌ キャッシュトークン取得失敗: $e');
    }

    LoggerService.debug('');
  }

  /// Firebase 사용자가 이메일 인증을 완료했는지 확인
  static Future<bool> isEmailVerified() async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        LoggerService.debug('Firebase가 초기화되지 않음 - 이메일 인증 상태 확인 건너뜀');
      }
      return false;
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // 최신 상태로 새로고침
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;

      return updatedUser?.emailVerified ?? false;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('이메일 인증 상태 확인 실패: $e');
      }
      return false;
    }
  }

  /// 이메일 인증 메일 재발송
  static Future<bool> resendEmailVerification() async {
    if (!_isFirebaseInitialized) {
      if (kDebugMode) {
        LoggerService.debug('Firebase가 초기화되지 않음 - 이메일 인증 메일 재발송 건너뜀');
      }
      return false;
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.emailVerified) return false;

      await user.sendEmailVerification();

      if (kDebugMode) {
        LoggerService.debug('이메일 인증 메일 발송 완료');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('이메일 인증 메일 발송 실패: $e');
      }
      return false;
    }
  }
}
