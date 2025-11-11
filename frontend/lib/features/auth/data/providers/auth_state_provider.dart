import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';
import '../auth_providers.dart';

part 'auth_state_provider.g.dart';

/// Firebase Auth 인증 상태 스트림 프로바이더
///
/// Firebase Auth의 authStateChanges()를 통해 실시간 인증 상태를 감지합니다.
/// 사용자 로그인/로그아웃 시 자동으로 상태가 업데이트됩니다.
///
/// 사용 예시:
/// ```dart
/// final authState = ref.watch(authStateStreamProvider);
/// authState.when(
///   data: (user) => user != null ? HomeScreen() : LoginScreen(),
///   loading: () => LoadingScreen(),
///   error: (error, stack) => ErrorScreen(error),
/// );
/// ```
@riverpod
Stream<User?> authStateStream(Ref ref) {
  final firebaseAuth = FirebaseAuth.instance;

  LoggerService.debug('🔐 [AuthStateStream] Firebase Auth 상태 감지 시작');

  return firebaseAuth.authStateChanges();
}

/// Firebase Auth ID Token 변경 스트림 프로바이더
///
/// Firebase Auth의 idTokenChanges()를 통해 ID 토큰 갱신을 실시간으로 감지합니다.
/// 토큰이 만료되어 자동 갱신될 때도 이벤트가 발생합니다.
///
/// 💡 베스트 프랙티스: 백엔드 API 호출 시 최신 토큰을 사용하려면 이 스트림을 활용하세요.
///
/// 사용 예시:
/// ```dart
/// final tokenState = ref.watch(idTokenStreamProvider);
/// tokenState.when(
///   data: (user) => user != null ? _callBackendAPI() : _showLogin(),
///   loading: () => LoadingScreen(),
///   error: (error, stack) => ErrorScreen(error),
/// );
/// ```
@riverpod
Stream<User?> idTokenStream(Ref ref) {
  final firebaseAuth = FirebaseAuth.instance;

  LoggerService.debug('🔐 [IdTokenStream] Firebase ID Token 변경 감지 시작');

  return firebaseAuth.idTokenChanges();
}

/// Firebase Auth 사용자 변경 스트림 프로바이더
///
/// Firebase Auth의 userChanges()를 통해 사용자 프로필 업데이트를 감지합니다.
/// updateEmail, updatePassword, updateProfile 등의 변경사항도 감지합니다.
///
/// 💡 베스트 프랙티스: 사용자 프로필 화면에서 실시간 업데이트를 반영하려면 이 스트림을 활용하세요.
///
/// 사용 예시:
/// ```dart
/// final userState = ref.watch(userChangesStreamProvider);
/// userState.when(
///   data: (user) => ProfileView(user: user),
///   loading: () => LoadingScreen(),
///   error: (error, stack) => ErrorScreen(error),
/// );
/// ```
@riverpod
Stream<User?> userChangesStream(Ref ref) {
  final firebaseAuth = FirebaseAuth.instance;

  LoggerService.debug('🔐 [UserChangesStream] Firebase 사용자 변경 감지 시작');

  return firebaseAuth.userChanges();
}

/// 현재 인증된 사용자 정보를 제공하는 프로바이더
///
/// Firebase User를 AuthUser 엔티티로 변환하여 제공합니다.
/// 로그인되지 않은 경우 null을 반환합니다.
@riverpod
Stream<AuthUser?> currentAuthUser(Ref ref) async* {
  final firebaseAuth = FirebaseAuth.instance;

  await for (final user in firebaseAuth.authStateChanges()) {
    if (user == null) {
      LoggerService.debug('🔐 [CurrentAuthUser] 로그아웃 상태');
      yield null;
    } else {
      LoggerService.debug('🔐 [CurrentAuthUser] 로그인 상태: ${user.email}');

      // Firebase User를 AuthUser로 변환
      final authUser = AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        isEmailVerified: user.emailVerified,
        creationTime: user.metadata.creationTime ?? DateTime.now(),
        lastSignInTime: user.metadata.lastSignInTime,
        customData: {
          'firebaseUid': user.uid,
          'isEmailVerified': user.emailVerified,
          'creationTime': user.metadata.creationTime?.toIso8601String(),
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        },
      );

      yield authUser;
    }
  }
}

/// 사용자 로그인 상태를 boolean으로 제공하는 프로바이더
///
/// 로그인 여부를 간단하게 확인할 수 있습니다.
/// 라우팅 가드 등에서 활용할 수 있습니다.
@riverpod
Stream<bool> isUserLoggedIn(Ref ref) async* {
  final firebaseAuth = FirebaseAuth.instance;

  await for (final user in firebaseAuth.authStateChanges()) {
    final isLoggedIn = user != null;
    LoggerService.debug('🔐 [IsUserLoggedIn] 로그인 상태: $isLoggedIn');
    yield isLoggedIn;
  }
}

/// 현재 사용자의 Firebase ID Token을 제공하는 프로바이더
///
/// 백엔드 API 호출 시 사용할 수 있는 ID Token을 제공합니다.
/// 토큰이 만료된 경우 자동으로 갱신됩니다.
///
/// Returns: ID Token (String?) 또는 null (로그인되지 않은 경우)
@riverpod
Future<String?> currentUserIdToken(Ref ref) async {
  try {
    final firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;

    if (user == null) {
      LoggerService.debug('🔐 [IdToken] 로그인되지 않음');
      return null;
    }

    // forceRefresh=true로 항상 최신 토큰 획득
    final token = await user.getIdToken(true);

    if (token != null) {
      LoggerService.debug(
        '🔐 [IdToken] Firebase ID Token 획득 성공 (${token.length}자)',
      );
    } else {
      LoggerService.debug('🔐 [IdToken] Firebase ID Token 획득 실패');
    }

    return token;
  } catch (e) {
    LoggerService.debug('❌ [IdToken] Firebase ID Token 획득 에러: $e');
    return null;
  }
}

/// 백엔드 서버 JWT 토큰을 제공하는 프로바이더
///
/// Firebase ID Token을 백엔드 서버 JWT로 교환한 토큰을 제공합니다.
/// 토큰이 없거나 만료된 경우 자동으로 갱신합니다.
@riverpod
Future<String?> currentServerToken(Ref ref) async {
  try {
    final repository = ref.read(authRepositoryProvider);

    // 1. 저장된 서버 토큰 확인
    final storedToken = await repository.getStoredServerToken();

    if (storedToken != null) {
      LoggerService.debug('🔐 [ServerToken] 저장된 서버 토큰 사용');
      return storedToken;
    }

    // 2. 토큰이 없으면 Firebase ID Token으로 교환
    final idToken = await ref.read(currentUserIdTokenProvider.future);

    if (idToken == null) {
      LoggerService.debug('🔐 [ServerToken] Firebase ID Token 없음');
      return null;
    }

    // 3. 서버 토큰 교환
    final serverToken = await repository.exchangeServerToken(idToken);
    LoggerService.debug('🔐 [ServerToken] 새로운 서버 토큰 획득 성공');

    return serverToken;
  } catch (e) {
    LoggerService.debug('❌ [ServerToken] 서버 토큰 획득 에러: $e');
    return null;
  }
}

/// 인증 상태가 완전한지 확인하는 프로바이더
///
/// Firebase 로그인 + 서버 JWT 토큰이 모두 유효한지 확인합니다.
/// 두 조건이 모두 만족되어야 완전한 인증 상태로 간주됩니다.
@riverpod
Future<bool> isFullyAuthenticated(Ref ref) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.debug('🔐 [FullyAuth] Firebase 로그인 안됨');
      return false;
    }

    final serverToken = await ref.read(currentServerTokenProvider.future);
    if (serverToken == null) {
      LoggerService.debug('🔐 [FullyAuth] 서버 토큰 없음');
      return false;
    }

    LoggerService.debug('🔐 [FullyAuth] 완전한 인증 상태 ✅');
    return true;
  } catch (e) {
    LoggerService.debug('❌ [FullyAuth] 인증 상태 확인 에러: $e');
    return false;
  }
}
