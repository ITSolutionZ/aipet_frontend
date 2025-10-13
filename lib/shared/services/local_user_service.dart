import 'local_database_service.dart';

/// 사용자 정보 로컬 스토리지 서비스
class LocalUserService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// 사용자 정보 저장
  Future<bool> saveUserInfo(Map<String, dynamic> userInfo) async {
    return await _dbService.saveJsonToPrefs('user_info', userInfo);
  }

  /// 사용자 정보 로드
  Future<Map<String, dynamic>?> loadUserInfo() async {
    return await _dbService.loadJsonFromPrefs('user_info');
  }

  /// 사용자 설정 저장
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    return await _dbService.saveJsonToPrefs('user_settings', settings);
  }

  /// 사용자 설정 로드
  Future<Map<String, dynamic>?> loadUserSettings() async {
    return await _dbService.loadJsonFromPrefs('user_settings');
  }

  /// 알림 설정 저장
  Future<bool> saveNotificationSettings(Map<String, dynamic> settings) async {
    return await _dbService.saveJsonToPrefs('notification_settings', settings);
  }

  /// 알림 설정 로드
  Future<Map<String, dynamic>?> loadNotificationSettings() async {
    return await _dbService.loadJsonFromPrefs('notification_settings');
  }

  /// 온보딩 완료 여부 저장
  Future<bool> setOnboardingComplete(bool isComplete) async {
    final prefs = await _dbService.prefs;
    return prefs.setBool('onboarding_complete', isComplete);
  }

  /// 온보딩 완료 여부 확인
  Future<bool> isOnboardingComplete() async {
    final prefs = await _dbService.prefs;
    return prefs.getBool('onboarding_complete') ?? false;
  }

  /// 마지막 로그인 시간 저장
  Future<bool> saveLastLoginTime() async {
    final prefs = await _dbService.prefs;
    return prefs.setString('last_login_time', DateTime.now().toIso8601String());
  }

  /// 마지막 로그인 시간 로드
  Future<DateTime?> loadLastLoginTime() async {
    final prefs = await _dbService.prefs;
    final timeStr = prefs.getString('last_login_time');
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }

  /// 로그인 상태 저장
  Future<bool> setLoginStatus(bool isLoggedIn) async {
    final prefs = await _dbService.prefs;
    return prefs.setBool('is_logged_in', isLoggedIn);
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final prefs = await _dbService.prefs;
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// 인증 토큰 저장 (보안 저장소 사용 권장)
  Future<bool> saveAuthToken(String token) async {
    final prefs = await _dbService.prefs;
    return prefs.setString('auth_token', token);
  }

  /// 인증 토큰 로드
  Future<String?> loadAuthToken() async {
    final prefs = await _dbService.prefs;
    return prefs.getString('auth_token');
  }

  /// 인증 토큰 삭제
  Future<bool> clearAuthToken() async {
    final prefs = await _dbService.prefs;
    return prefs.remove('auth_token');
  }

  /// 사용자 데이터 전체 삭제
  Future<void> clearAllUserData() async {
    final prefs = await _dbService.prefs;
    await prefs.remove('user_info');
    await prefs.remove('user_settings');
    await prefs.remove('notification_settings');
    await prefs.remove('auth_token');
    await prefs.setBool('is_logged_in', false);
  }
}