import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../shared/constants/error_codes.dart';
import '../../../../shared/services/http_client_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_token_service.dart';

/// Firebase Auth 실제 구현체
class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 1단계: Firebase Auth로 로그인
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Firebase 인증에 실패했습니다');
      }

      // 2단계: Firebase ID Token 가져오기 (자동 갱신 포함)
      final idToken = await FirebaseTokenService.getCurrentIdToken();
      if (idToken == null) {
        return AuthResult.failure('Firebase ID Token을 가져올 수 없습니다');
      }

      // 3단계: ID Token을 백엔드로 전송하여 로그인 처리
      final backendResponse = await HttpClientService.instance.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'idToken': idToken},
        fromJson: (json) => json,
      );

      if (backendResponse.isError) {
        return AuthResult.failure(
          backendResponse.error ?? '백엔드 로그인에 실패했습니다',
        );
      }

      final backendData = backendResponse.data!;
      if (backendData['success'] != true) {
        return AuthResult.failure(
          backendData['message'] ?? '로그인에 실패했습니다',
          errorCode: backendData['errorCode'],
        );
      }

      // 4단계: 백엔드에서 받은 사용자 정보로 AuthUser 생성
      final userData = backendData['user'] as Map<String, dynamic>;
      final authUser = AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        photoURL: userData['photoUrl'] as String?,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: DateTime.parse(userData['createdAt'] as String),
        lastSignInTime: DateTime.parse(userData['lastLoginAt'] as String),
        // 백엔드 토큰 정보 추가
        customData: {
          'accessToken': backendData['accessToken'],
          'refreshToken': backendData['refreshToken'],
          'expiresAt': backendData['expiresAt'],
          'firebaseUid': userData['firebaseUid'],
        },
      );

      return AuthResult.success(
        backendData['message'] as String,
        user: authUser,
      );
    } on FirebaseAuthException catch (e) {
      final errorCode = ErrorCodes.mapFirebaseAuthError(e.code);
      final errorMessage = ErrorCodes.getErrorMessage(errorCode);
      return AuthResult.failure(errorMessage, errorCode: errorCode);
    } catch (e) {
      return AuthResult.failure('ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 1단계: Firebase Auth로 회원가입
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Firebase 회원가입에 실패했습니다');
      }

      // 2단계: Firebase ID Token 가져오기 (자동 갱신 포함)
      final idToken = await FirebaseTokenService.getCurrentIdToken();
      if (idToken == null) {
        return AuthResult.failure('Firebase ID Token을 가져올 수 없습니다');
      }

      // 3단계: ID Token을 백엔드로 전송하여 회원가입 처리
      final backendResponse = await HttpClientService.instance.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'idToken': idToken},
        fromJson: (json) => json,
      );

      if (backendResponse.isError) {
        return AuthResult.failure(
          backendResponse.error ?? '백엔드 회원가입에 실패했습니다',
        );
      }

      final backendData = backendResponse.data!;
      if (backendData['success'] != true) {
        return AuthResult.failure(
          backendData['message'] ?? '회원가입에 실패했습니다',
          errorCode: backendData['errorCode'],
        );
      }

      // 4단계: 백엔드에서 받은 사용자 정보로 AuthUser 생성
      final userData = backendData['user'] as Map<String, dynamic>;
      final authUser = AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        photoURL: userData['photoUrl'] as String?,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: DateTime.parse(userData['createdAt'] as String),
        lastSignInTime: DateTime.parse(userData['lastLoginAt'] as String),
        customData: {
          'accessToken': backendData['accessToken'],
          'refreshToken': backendData['refreshToken'],
          'expiresAt': backendData['expiresAt'],
          'firebaseUid': userData['firebaseUid'],
          'isNewUser': userData['isNewUser'] ?? true,
        },
      );

      return AuthResult.success(
        backendData['message'] as String,
        user: authUser,
      );
    } on FirebaseAuthException catch (e) {
      final errorCode = ErrorCodes.mapFirebaseAuthError(e.code);
      final errorMessage = ErrorCodes.getErrorMessage(errorCode);
      return AuthResult.failure(errorMessage, errorCode: errorCode);
    } catch (e) {
      return AuthResult.failure('会員登録に失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      // 1단계: Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Google ログインがキャンセルされました');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2단계: Firebase Auth로 로그인
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return AuthResult.failure('Google Firebase 로그인에 실패했습니다');
      }

      // 3단계: Firebase ID Token 가져오기 (자동 갱신 포함)
      final idToken = await FirebaseTokenService.getCurrentIdToken();
      if (idToken == null) {
        return AuthResult.failure('Firebase ID Token을 가져올 수 없습니다');
      }

      // 4단계: ID Token을 백엔드로 전송
      final endpoint = userCredential.additionalUserInfo?.isNewUser == true 
          ? '/auth/register' 
          : '/auth/login';
      
      final backendResponse = await HttpClientService.instance.post<Map<String, dynamic>>(
        endpoint,
        data: {'idToken': idToken},
        fromJson: (json) => json,
      );

      if (backendResponse.isError) {
        return AuthResult.failure(
          backendResponse.error ?? '백엔드 Google 로그인에 실패했습니다',
        );
      }

      final backendData = backendResponse.data!;
      if (backendData['success'] != true) {
        return AuthResult.failure(
          backendData['message'] ?? 'Google 로그인에 실패했습니다',
          errorCode: backendData['errorCode'],
        );
      }

      // 5단계: 백엔드에서 받은 사용자 정보로 AuthUser 생성
      final userData = backendData['user'] as Map<String, dynamic>;
      final authUser = AuthUser(
        uid: userData['id'] as String,
        email: userData['email'] as String,
        displayName: userData['displayName'] as String,
        photoURL: userData['photoUrl'] as String?,
        isEmailVerified: userData['isEmailVerified'] as bool,
        creationTime: DateTime.parse(userData['createdAt'] as String),
        lastSignInTime: DateTime.parse(userData['lastLoginAt'] as String),
        customData: {
          'accessToken': backendData['accessToken'],
          'refreshToken': backendData['refreshToken'],
          'expiresAt': backendData['expiresAt'],
          'firebaseUid': userData['firebaseUid'],
          'provider': 'google',
        },
      );

      return AuthResult.success(
        backendData['message'] as String,
        user: authUser,
      );
    } catch (e) {
      return AuthResult.failure('Google ログインに失敗しました: $e');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();
      final userCredential = await _firebaseAuth.signInWithProvider(appleProvider);
      final user = userCredential.user;

      if (user == null) {
        return AuthResult.failure('Apple ログインに失敗しました');
      }

      return AuthResult.success(
        'Apple ログインが完了しました',
        user: _mapFirebaseUserToAuthUser(user),
      );
    } catch (e) {
      return AuthResult.failure('Apple ログインに失敗しました');
    }
  }

  @override
  Future<AuthResult> signInWithLine() async {
    // LINE 로그인은 별도 SDK 필요
    return AuthResult.failure('LINE ログインは現在サポートされていません');
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    
    return _mapFirebaseUserToAuthUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      final errorCode = ErrorCodes.mapFirebaseAuthError(e.code);
      final errorMessage = ErrorCodes.getErrorMessage(errorCode);
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  AuthUser _mapFirebaseUserToAuthUser(User firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoURL: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      creationTime: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInTime: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

}