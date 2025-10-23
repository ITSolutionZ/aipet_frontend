import 'package:shared_preferences/shared_preferences.dart';

/// 전역 캐시 서비스 (SharedPreferences 래퍼)
///
/// 앱 전체에서 사용하는 로컬 저장소 관리
/// - SharedPreferences의 싱글톤 래퍼
/// - TTL 기반 캐시 관리
/// - 타입 안전 메서드 제공
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memoryCache = {};

  /// 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ========== String 관련 ==========

  /// String 저장
  Future<void> setString(String key, String value) async {
    await initialize();
    await _prefs!.setString(key, value);
  }

  /// String 조회
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  /// List<String> 저장
  Future<void> setStringList(String key, List<String> value) async {
    await initialize();
    await _prefs!.setStringList(key, value);
  }

  /// List<String> 조회
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // ========== Bool 관련 ==========

  /// Bool 값 저장
  Future<void> setBoolValue(String key, bool value) async {
    await initialize();
    await _prefs!.setBool(key, value);
  }

  /// Bool 값 조회
  bool? getBoolValue(String key) {
    return _prefs?.getBool(key);
  }

  // ========== Int 관련 ==========

  /// Int 값 저장
  Future<void> setIntValue(String key, int value) async {
    await initialize();
    await _prefs!.setInt(key, value);
  }

  /// Int 값 조회
  int? getIntValue(String key) {
    return _prefs?.getInt(key);
  }

  // ========== Double 관련 ==========

  /// Double 값 저장
  Future<void> setDoubleValue(String key, double value) async {
    await initialize();
    await _prefs!.setDouble(key, value);
  }

  /// Double 값 조회
  double? getDoubleValue(String key) {
    return _prefs?.getDouble(key);
  }

  // ========== 유틸리티 메서드 ==========

  /// 키 존재 여부 확인 (동기)
  bool containsKeySync(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// 키 제거
  Future<void> removeKey(String key) async {
    await initialize();
    await _prefs!.remove(key);
    _memoryCache.remove(key);
  }

  /// 전체 캐시 클리어
  Future<void> clearAll() async {
    await initialize();
    await _prefs!.clear();
    _memoryCache.clear();
  }

  /// Double 값 저장
  Future<void> setDoubleValue(String key, double value) async {
    await initialize();
    await _prefs!.setDouble(key, value);
  }

  /// Double 값 조회
  double? getDoubleValue(String key) {
    return _prefs?.getDouble(key);
  }

  // ========== 호환성 메서드 (기존 코드 지원) ==========

  /// List<String> 조회 (호환성 - 동기)
  List<String>? getPersistentCacheList(String key) {
    return _prefs?.getStringList(key);
  }

  /// List<String> 저장 (호환성 - 비동기)
  Future<void> setPersistentCacheList(String key, List<String> value) async {
    await initialize();
    await _prefs!.setStringList(key, value);
  }

  // ========== TTL 기반 캐시 ==========

  /// TTL 캐시 저장
  Future<void> setCache(String key, dynamic data, {Duration? ttl}) async {
    _memoryCache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
  }

  /// TTL 캐시 조회
  T? getCache<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _memoryCache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  /// 캐시 유효성 확인
  bool isCacheValid(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return false;
    return !entry.isExpired;
  }

  /// 캐시 무효화
  void invalidateCache(String key) {
    _memoryCache.remove(key);
  }

  /// 만료된 메모리 캐시 정리
  void cleanupExpiredCache() {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
  }
}

/// 캐시 엔트리
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration? ttl;

  CacheEntry({required this.data, required this.timestamp, this.ttl});

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(timestamp.add(ttl!));
  }
}

/// 캐시 키 상수
class CacheKeys {
  static const String homeDashboard = 'home_dashboard';
  static const String dashboard = 'dashboard';
  static const String weather = 'weather_data';
  static const String petProfiles = 'pet_profiles';
  static const String walkSummary = 'walk_summary';
  static const String healthSummary = 'health_summary';
  static const String appointments = 'appointments';
}

/// 캐시 TTL 상수
class CacheTTL {
  static const Duration location = Duration(seconds: 30); // 위치 정보 (30초)
  static const Duration short = Duration(minutes: 5); // 날씨 등 자주 변하는 데이터
  static const Duration medium = Duration(minutes: 15); // 홈 대시보드
  static const Duration long = Duration(hours: 1); // 펫 프로필 등 정적 데이터
  static const Duration veryLong = Duration(hours: 24); // 거의 변하지 않는 데이터
}
