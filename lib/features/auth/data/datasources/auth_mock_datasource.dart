import 'package:aipet_frontend/shared/core/domain/result.dart';

import '../../domain/entities/auth_entities.dart';
import 'auth_datasource.dart';

/// Mock 원격 인증 데이터소스
class AuthMockRemoteDatasource implements AuthRemoteDatasource {
  final Map<String, AuthUser> _users = {};
  final Map<String, String> _passwords = {};
  AuthUser? _currentUser;

  AuthMockRemoteDatasource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock 사용자 데이터 초기화
    final mockUser = AuthUser(
      uid: 'mock_user_001',
      email: 'test@example.com',
      displayName: 'Test User',
      isEmailVerified: true,
      creationTime: DateTime.now().subtract(const Duration(days: 30)),
      lastSignInTime: DateTime.now().subtract(const Duration(hours: 1)),
    );

    _users['test@example.com'] = mockUser;
    _passwords['test@example.com'] = 'password123';
  }

  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    if (!_users.containsKey(email)) {
      return Result.failure('このメールアドレスは登録されていません');
    }

    if (_passwords[email] != password) {
      return Result.failure('パスワードが正しくありません');
    }

    _currentUser = _users[email]!.copyWith(
      lastSignInTime: DateTime.now(),
    );

    return Result.success('ログインが完了しました', _currentUser!);
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_users.containsKey(email)) {
      return Result.failure('このメールアドレスは既に登録されています');
    }

    final newUser = AuthUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      isEmailVerified: false,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
    );

    _users[email] = newUser;
    _passwords[email] = password;
    _currentUser = newUser;

    return Result.success('会員登録が完了しました', newUser);
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 2));

    final googleUser = AuthUser(
      uid: 'google_${DateTime.now().millisecondsSinceEpoch}',
      email: 'google.user@gmail.com',
      displayName: 'Google User',
      photoURL: 'https://lh3.googleusercontent.com/mock',
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'provider': 'google'},
    );

    _currentUser = googleUser;
    _users[googleUser.email!] = googleUser;

    return Result.success('Googleログインが完了しました', googleUser);
  }

  @override
  Future<Result<AuthUser>> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 2));

    final appleUser = AuthUser(
      uid: 'apple_${DateTime.now().millisecondsSinceEpoch}',
      email: 'apple.user@privaterelay.appleid.com',
      displayName: 'Apple User',
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'provider': 'apple'},
    );

    _currentUser = appleUser;
    _users[appleUser.email!] = appleUser;

    return Result.success('Appleログインが完了しました', appleUser);
  }

  @override
  Future<Result<AuthUser>> signInWithLine() async {
    await Future.delayed(const Duration(seconds: 2));

    final lineUser = AuthUser(
      uid: 'line_${DateTime.now().millisecondsSinceEpoch}',
      email: 'line.user@line.me',
      displayName: 'LINE User',
      photoURL: 'https://profile.line-scdn.net/mock',
      isEmailVerified: true,
      creationTime: DateTime.now(),
      lastSignInTime: DateTime.now(),
      customData: {'provider': 'line'},
    );

    _currentUser = lineUser;
    _users[lineUser.email!] = lineUser;

    return Result.success('LINEログインが完了しました', lineUser);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.success('現在のユーザー情報', _currentUser);
  }

  @override
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
      );

      // 저장된 사용자 정보도 업데이트
      if (_currentUser!.email != null) {
        _users[_currentUser!.email!] = _currentUser!;
      }
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!_users.containsKey(email)) {
      throw Exception('このメールアドレスは登録されていません');
    }

    // Mock 구현: 실제로는 이메일 발송
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser == null) {
      throw Exception('ログインが必要です');
    }

    // Mock 구현: 실제로는 이메일 발송
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser != null && _currentUser!.email != null) {
      _users.remove(_currentUser!.email!);
      _passwords.remove(_currentUser!.email!);
      _currentUser = null;
    }
  }

  @override
  Future<String> exchangeServerToken(String idToken) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock JWT 토큰 생성
    final now = DateTime.now();
    final exp = now.add(const Duration(hours: 1));

    return 'mock_jwt_token_${now.millisecondsSinceEpoch}_exp_${exp.millisecondsSinceEpoch}';
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentUser == null) return null;

    // Mock Firebase ID 토큰
    return 'mock_firebase_id_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<bool> validateToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 토큰 검증: 단순히 토큰이 비어있지 않으면 유효하다고 가정
    return token.isNotEmpty && token.startsWith('mock_');
  }
}

/// Mock 로컬 인증 데이터소스
class AuthMockLocalDatasource implements AuthLocalDatasource {
  AuthUser? _cachedUser;
  String? _storedToken;
  final Map<String, AuthUser> _userCache = {};
  bool _autoLoginEnabled = false;
  bool _biometricEnabled = false;

  @override
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // 로컬 데이터소스는 직접 로그인을 수행하지 않음
    return Result.failure('로컬 데이터소스에서는 로그인을 지원하지 않습니다');
  }

  @override
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // 로컬 데이터소스는 직접 회원가입을 수행하지 않음
    return Result.failure('로컬 데이터소스에서는 회원가입을 지원하지 않습니다');
  }

  @override
  Future<void> signOut() async {
    _cachedUser = null;
    _storedToken = null;
    _userCache.clear();
  }

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    return Result.success('캐시된 사용자 정보', _cachedUser);
  }

  @override
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    if (_cachedUser != null) {
      _cachedUser = _cachedUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
      );
    }
  }

  @override
  Future<void> saveUserSession(AuthUser user) async {
    _cachedUser = user;
    if (user.email != null) {
      _userCache[user.email!] = user;
    }
  }

  @override
  Future<void> clearUserSession() async {
    _cachedUser = null;
    _storedToken = null;
  }

  @override
  Future<Result<AuthUser?>> getCachedUser(String email) async {
    final user = _userCache[email];
    return Result.success('캐시된 사용자', user);
  }

  @override
  Future<void> saveToken(String token) async {
    _storedToken = token;
  }

  @override
  Future<String?> getStoredToken() async {
    return _storedToken;
  }

  @override
  Future<void> clearToken() async {
    _storedToken = null;
  }

  @override
  Future<void> saveLoginRecord(String email, DateTime loginTime) async {
    // Mock 구현: 실제로는 SharedPreferences나 SQLite에 저장
  }

  @override
  Future<void> saveAutoLoginSetting(bool enabled) async {
    _autoLoginEnabled = enabled;
  }

  @override
  Future<bool> getAutoLoginSetting() async {
    return _autoLoginEnabled;
  }

  @override
  Future<void> saveBiometricSetting(bool enabled) async {
    _biometricEnabled = enabled;
  }

  @override
  Future<bool> getBiometricSetting() async {
    return _biometricEnabled;
  }
}