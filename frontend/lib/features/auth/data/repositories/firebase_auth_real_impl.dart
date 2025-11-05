import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


import '../../../../shared/shared.dart';
import '../../../../app/app.dart';
import '../../domain/auth_error.dart' as auth_errors;
import '../../domain/domain.dart';
import '../services/line_oauth_service.dart';



/// 🎯 실제 Firebase Auth 구현체
///
/// ⚠️ 개발 중: 현재는 LocalAuthImpl 사용 (kDebugMode == true)
/// 이 구현체는 프로덕션 배포 시에만 활성화됩니다.
///
/// Firebase Auth와 실제 OAuth 프로바이더들을 사용한 실제 구현체입니다.
/// 이메일/비밀번호 로그인, Google Sign-In, Apple Sign-In을 지원합니다.
/// LINE 로그인은 현재 Mock 구현으로 되어 있으며, 추후 실제 구현 예정입니다.
///
/// 프로덕션 전환 시:
/// 1. auth_providers.dart에서 kDebugMode 체크 제거
/// 2. Firebase 프로젝트 설정 완료 확인
/// 3. google-services.json / GoogleService-Info.plist 확인
class FirebaseAuthRealImpl implements AuthRepository {
  /// Firebase Auth 인스턴스
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Google Sign-In 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// LINE OAuth 서비스 인스턴스
  final LineOAuthService _lineOAuthService = LineOAuthService();

  // 서버 토큰 저장소 키
  static const String _serverTokenKey = 'server_token';
  static const String _serverTokenExpiresKey = 'server_token_expires';

  // FlutterSecureStorage 인스턴스
  static const _storage = FlutterSecureStorage();

  /// 이메일/비밀번호로 로그인
  ///
  /// [email] 사용자 이메일 주소
  /// [password] 사용자 비밀번호
  ///
  /// Returns: 인증 결과 (성공 시 AuthUser 포함)
  ///
  /// Throws: FirebaseAuthException - Firebase 인증 에러
  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Firebase Auth를 통한 이메일/비밀번호 로그인
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Firebase User를 AuthUser로 변환
        final user = _mapFirebaseUserToAuthUser(credential.user!);
        return Result.success('ログインが完了しました', user);
      } else {
        return Result.failure('ログインに失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      // Firebase Auth 에러를 사용자 친화적 메시지로 변환
      return Result.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return Result.failure('ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = _mapFirebaseUserToAuthUser(credential.user!);
        return Result.success('会員登録が完了しました', user);
      } else {
        return Result.failure('会員登録に失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return Result.failure('会員登録に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    try {
      // Google Sign-In 초기화
      await _googleSignIn.initialize();

      // Google Sign-In 인증 시작
      final GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.authenticate(
          scopeHint: [
            'email',
            'https://www.googleapis.com/auth/userinfo.profile',
          ],
        );
      } catch (authError) {
        if (kDebugMode) {
          LoggerService.debug('❌ Google Sign-In 에러: $authError');
        }

        // 사용자 취소 에러인 경우
        if (authError.toString().contains('canceled') ||
            authError.toString().contains('cancelled')) {
          return Result.failure('Googleログインがキャンセルされました');
        }

        rethrow;
      }

      // Google 인증 토큰 획득
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Google idTokenを獲得できませんでした');
      }

      // Firebase 자격증명 생성
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Firebase Auth로 로그인
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final user = _mapFirebaseUserToAuthUser(userCredential.user!);

        if (kDebugMode) {
          LoggerService.debug('✅ Google Sign-In 성공: ${user.email}');
        }

        return Result.success('Googleログインが完了しました', user);
      }

      return Result.failure('Googleログインに失敗しました');
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('❌ Google Sign-In 에러: $e');
      }

      // 사용자 취소 에러인 경우
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return Result.failure('Googleログインがキャンセルされました');
      }

      return Result.failure('Googleログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    try {
      // Apple Sign-In 플로우
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      if (userCredential.user != null) {
        final user = _mapFirebaseUserToAuthUser(userCredential.user!);
        return Result.success('Appleログインが完了しました', user);
      } else {
        return Result.failure('Apple ログインに失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      return Result.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return Result.failure('Apple ログインに失敗しました: ${e.toString()}');
    }
  }

  /// LINE 로그인
  ///
  /// LINE OAuth 2.0을 통한 로그인을 수행합니다.
  ///
  /// Returns: 인증 결과 (성공 시 AuthUser 포함)
  @override
  Future<Result<AuthUser>> signInWithLine() async {
    try {
      // LINE OAuth 서비스를 통한 로그인
      final result = await _lineOAuthService.loginWithLine();

      if (result.isSuccess && result.dataOrNull != null) {
        final lineUserInfo = result.dataOrNull!;

        // LINE 사용자 정보를 AuthUser로 변환
        final user = AuthUser(
          uid: lineUserInfo.userId,
          email: '${lineUserInfo.userId}@line.me', // LINE은 이메일을 제공하지 않을 수 있음
          displayName: lineUserInfo.displayName,
          isEmailVerified: false, // LINE은 이메일 인증을 제공하지 않음
          creationTime: DateTime.now(),
          lastSignInTime: DateTime.now(),
          customData: {
            'provider': 'line',
            'lineUserId': lineUserInfo.userId,
            'lineDisplayName': lineUserInfo.displayName,
            'linePictureUrl': lineUserInfo.pictureUrl,
            'lineStatusMessage': lineUserInfo.statusMessage,
          },
        );

        return Result.success('LINEログインが完了しました', user);
      } else {
        return Result.failure(result.error?.toString() ?? 'LINE ログインに失敗しました');
      }
    } catch (e) {
      return Result.failure('LINE ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // TODO: Google Sign-Out when Google Sign-In is re-implemented
      // await _googleSignIn.signOut();
      // LINE 로그아웃은 별도 구현이 필요할 수 있음 (현재는 Firebase 로그아웃으로 처리)
    } catch (e) {
      // 로그아웃 실패는 무시
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return _mapFirebaseUserToAuthUser(user);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('パスワードリセットメールの送信に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('確認メールの送信に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('プロフィールの更新に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('アカウントの削除に失敗しました: ${e.toString()}');
    }
  }

  /// Firebase ID 토큰을 서버 JWT로 교환
  ///
  /// [idToken] Firebase에서 발급받은 ID 토큰
  ///
  /// Returns: 서버에서 발급받은 JWT 토큰
  @override
  Future<String> exchangeServerToken(String idToken) async {
    try {
      // 실제 백엔드 API 호출로 서버 토큰 교환
      final response = await http.post(
        Uri.parse('${AppConfig.current.apiBaseUrl}/auth/exchange-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
          'Accept': 'application/json',
        },
        body: json.encode({
          'firebaseIdToken': idToken,
          'clientType': 'mobile',
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final serverToken = data['serverToken'] as String;
        final expiresInHours = data['expiresInHours'] as int? ?? 24;

        // 토큰 유효성 검증
        if (serverToken.isEmpty || serverToken.length < 32) {
          throw const auth_errors.TokenError(
            auth_errors.TokenErrorType.invalid,
          );
        }

        // 서버 토큰 저장
        await saveServerToken(serverToken, expiresInHours: expiresInHours);

        if (kDebugMode) {
          LoggerService.debug('서버 토큰 교환 성공 - 만료시간: $expiresInHours시간');
        }

        return serverToken;
      } else if (response.statusCode == 401) {
        throw const auth_errors.TokenError(auth_errors.TokenErrorType.expired);
      } else if (response.statusCode >= 500) {
        throw auth_errors.ServerError(statusCode: response.statusCode);
      } else {
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorData?['message'] ?? 'Token exchange failed';
        throw auth_errors.ClientError(
          statusCode: response.statusCode,
          reason: errorMessage,
        );
      }
    } catch (e) {
      throw Exception('서버 토큰 교환 실패: $e');
    }
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      return null;
    }
  }

  /// 저장된 서버 JWT 토큰 확인
  ///
  /// SecureStorage에서 저장된 서버 토큰을 가져옵니다.
  /// 토큰이 만료되었거나 없으면 null을 반환합니다.
  @override
  Future<String?> getStoredServerToken() async {
    try {
      final token = await _storage.read(key: _serverTokenKey);
      final expiresStr = await _storage.read(key: _serverTokenExpiresKey);

      if (token == null || expiresStr == null) {
        return null;
      }

      // 토큰 만료 확인
      final expiresAt = DateTime.parse(expiresStr);
      if (DateTime.now().isAfter(expiresAt)) {
        // 만료된 토큰 삭제
        await clearServerToken();
        return null;
      }

      return token;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('서버 토큰 가져오기 실패: $e');
      }
      return null;
    }
  }

  /// 서버 JWT 토큰 저장
  ///
  /// [token] 저장할 서버 JWT 토큰
  /// [expiresInHours] 토큰 만료 시간 (기본 24시간)
  @override
  Future<void> saveServerToken(String token, {int expiresInHours = 24}) async {
    try {
      final expiresAt = DateTime.now().add(Duration(hours: expiresInHours));

      await Future.wait([
        _storage.write(key: _serverTokenKey, value: token),
        _storage.write(
          key: _serverTokenExpiresKey,
          value: expiresAt.toIso8601String(),
        ),
      ]);

      if (kDebugMode) {
        LoggerService.debug('서버 토큰 저장 완료 (만료: ${expiresAt.toIso8601String()})');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('서버 토큰 저장 실패: $e');
      }
      rethrow;
    }
  }

  /// 저장된 서버 JWT 토큰 삭제
  ///
  /// 로그아웃 시 또는 토큰 만료 시 호출됩니다.
  @override
  Future<void> clearServerToken() async {
    try {
      await Future.wait([
        _storage.delete(key: _serverTokenKey),
        _storage.delete(key: _serverTokenExpiresKey),
      ]);

      if (kDebugMode) {
        LoggerService.debug('서버 토큰 삭제 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('서버 토큰 삭제 실패: $e');
      }
      // 삭제 실패는 로그아웃에 영향을 주지 않도록 무시
    }
  }

  /// 사용자 인증 상태 확인 (Firebase + 서버 JWT 모두 유효)
  ///
  /// Firebase 사용자 로그인 상태와 서버 JWT 토큰 유효성을 모두 확인합니다.
  /// 두 조건이 모두 만족되어야 인증된 상태로 간주됩니다.
  @override
  Future<bool> isAuthenticated() async {
    try {
      // Firebase 사용자 로그인 상태 확인
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return false;
      }

      // 서버 JWT 토큰 유효성 확인
      final serverToken = await getStoredServerToken();
      if (serverToken == null) {
        return false;
      }

      // 두 조건 모두 만족 시 인증된 상태
      return true;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('인증 상태 확인 실패: $e');
      }
      return false;
    }
  }

  /// Firebase User를 AuthUser로 변환
  AuthUser _mapFirebaseUserToAuthUser(User firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      creationTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInTime: firebaseUser.metadata.lastSignInTime,
      customData: {
        'firebaseUid': firebaseUser.uid,
        'isEmailVerified': firebaseUser.emailVerified,
        'creationTime': firebaseUser.metadata.creationTime?.toIso8601String(),
        'lastSignInTime': firebaseUser.metadata.lastSignInTime
            ?.toIso8601String(),
      },
    );
  }

  /// Firebase Auth 에러 메시지 변환
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'ユーザーが見つかりません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'weak-password':
        return 'パスワードが弱すぎます';
      case 'invalid-email':
        return '無効なメールアドレスです';
      case 'user-disabled':
        return 'このアカウントは無効化されています';
      case 'too-many-requests':
        return 'リクエストが多すぎます。しばらくしてから再試行してください';
      case 'operation-not-allowed':
        return 'この操作は許可されていません';
      case 'invalid-credential':
        return '無効な認証情報です';
      case 'account-exists-with-different-credential':
        return '異なる認証情報でアカウントが既に存在します';
      case 'credential-already-in-use':
        return 'この認証情報は既に使用されています';
      case 'invalid-verification-code':
        return '無効な確認コードです';
      case 'invalid-verification-id':
        return '無効な確認IDです';
      case 'network-request-failed':
        return 'ネットワークエラーが発生しました';
      case 'requires-recent-login':
        return 'セキュリティのため、再度ログインしてください';
      default:
        return '認証エラーが発生しました: ${e.message}';
    }
  }
}
