import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/repositories/auth_repository.dart';
import '../services/line_oauth_service.dart';

/// 🎯 실제 Firebase Auth 구현체
///
/// Firebase Auth와 실제 OAuth 프로바이더들을 사용한 실제 구현
class FirebaseAuthRealImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final LineOAuthService _lineOAuthService = LineOAuthService();

  @override
  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = _mapFirebaseUserToAuthUser(credential.user!);
        return AuthResult.success('ログインが完了しました', user: user);
      } else {
        return AuthResult.failure('ログインに失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> createUserWithEmailAndPassword(
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
        return AuthResult.success('会員登録が完了しました', user: user);
      } else {
        return AuthResult.failure('会員登録に失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('会員登録に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Google Sign-In 플로우
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

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final user = _mapFirebaseUserToAuthUser(userCredential.user!);
        return AuthResult.success('Googleログインが完了しました', user: user);
      } else {
        return AuthResult.failure('Google ログインに失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Google ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
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
        return AuthResult.success('Appleログインが完了しました', user: user);
      } else {
        return AuthResult.failure('Apple ログインに失敗しました');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getFirebaseErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Apple ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signInWithLine() async {
    try {
      // 실제 LINE OAuth 로그인
      final result = await _lineOAuthService.loginWithLine();

      if (result.isSuccess && result.data != null) {
        final lineUser = result.data!;

        // LINE 사용자 정보를 AuthUser로 변환
        final user = AuthUser(
          uid: lineUser.userId,
          email: '${lineUser.userId}@line.me', // LINE은 이메일을 제공하지 않을 수 있음
          displayName: lineUser.displayName,
          photoURL: lineUser.pictureUrl,
          isEmailVerified: true,
          creationTime: DateTime.now(),
          lastSignInTime: DateTime.now(),
          customData: {
            'provider': 'line',
            'lineUserId': lineUser.userId,
            'statusMessage': lineUser.statusMessage,
          },
        );

        return AuthResult.success('LINEログインが完了しました', user: user);
      } else {
        return AuthResult.failure(result.message);
      }
    } catch (e) {
      return AuthResult.failure('LINE ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      // TODO: LINE 로그아웃 구현 예정
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
