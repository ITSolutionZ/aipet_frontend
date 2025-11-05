import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/home/domain/entities/entities.dart';
import '../../shared/services/cache_service.dart';

/// 초고속 캐시 서비스
///
/// 홈 화면 로딩을 3초 이내로 단축하기 위한 특별한 캐시 시스템
class UltraFastCacheService {
  static final UltraFastCacheService _instance =
      UltraFastCacheService._internal();
  factory UltraFastCacheService() => _instance;
  UltraFastCacheService._internal();

  final CacheService _baseCache = CacheService();
  SharedPreferences? _prefs;

  // 최근 성공한 대시보드 데이터 (즉시 로딩용)
  HomeDashboardEntity? _lastSuccessfulDashboard;
  DateTime? _lastUpdateTime;

  /// 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadLastSuccessfulDashboard();
  }

  /// 홈 대시보드 초고속 로딩
  ///
  /// 1. 메모리 캐시 확인
  /// 2. 마지막 성공 데이터 즉시 반환
  /// 3. 백그라운드에서 새 데이터 로딩
  Future<HomeDashboardEntity?> getUltraFastDashboard() async {
    await initialize();

    // 1단계: 메모리 캐시 확인 (0ms)
    final memoryCached = _baseCache.getCache<HomeDashboardEntity>(
      CacheKeys.homeDashboard,
    );
    if (memoryCached != null) {
      debugPrint('⚡ UltraFast: 메모리 캐시 히트');
      return memoryCached;
    }

    // 2단계: 마지막 성공 데이터 즉시 반환 (1-5ms)
    if (_lastSuccessfulDashboard != null) {
      debugPrint('🚀 UltraFast: 마지막 성공 데이터 즉시 반환');

      // 백그라운드에서 새 데이터 로딩 시작 (사용자는 기다리지 않음)
      _refreshInBackground();

      return _lastSuccessfulDashboard;
    }

    // 3단계: 영속 캐시에서 복원 시도
    final persistentData = await _loadFromPersistentCache();
    if (persistentData != null) {
      debugPrint('💿 UltraFast: 영속 캐시에서 복원');
      _lastSuccessfulDashboard = persistentData;
      return persistentData;
    }

    debugPrint('❌ UltraFast: 캐시된 데이터 없음');
    return null;
  }

  /// 대시보드 데이터 저장 및 백업
  Future<void> saveDashboard(HomeDashboardEntity dashboard) async {
    await initialize();

    // 메모리에 저장
    _lastSuccessfulDashboard = dashboard;
    _lastUpdateTime = DateTime.now();

    // 메모리 캐시에 저장
    await _baseCache.setCache(
      CacheKeys.homeDashboard,
      dashboard,
      ttl: const Duration(minutes: 15),
    );

    // 영속 캐시에 백업 (백그라운드)
    unawaited(_saveToPersistentCache(dashboard));

    debugPrint('💾 UltraFast: 대시보드 저장 완료');
  }

  /// 백그라운드에서 새 데이터 로딩
  void _refreshInBackground() {
    debugPrint('🔄 UltraFast: 백그라운드 새로고침 시작');

    // 실제 구현에서는 Repository를 통해 새 데이터를 가져옴
    // 여기서는 직접 호출하지 않고 Riverpod가 처리하도록 함
  }

  /// 영속 캐시에서 데이터 로딩
  Future<HomeDashboardEntity?> _loadFromPersistentCache() async {
    try {
      final cachedString = _prefs!.getString(_persistentKey);
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'] as int,
      );

      // 24시간 이내 데이터만 사용
      if (DateTime.now().difference(timestamp).inHours > 24) {
        await _prefs!.remove(_persistentKey);
        return null;
      }

      final dashboardData = cacheData['dashboard'] as Map<String, dynamic>;
      return _deserializeDashboard(dashboardData);
    } catch (e) {
      debugPrint('❌ UltraFast: 영속 캐시 로딩 실패 - $e');
      return null;
    }
  }

  /// 영속 캐시에 데이터 저장
  Future<void> _saveToPersistentCache(HomeDashboardEntity dashboard) async {
    try {
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'dashboard': _serializeDashboard(dashboard),
      };

      await _prefs!.setString(_persistentKey, jsonEncode(cacheData));
      debugPrint('💿 UltraFast: 영속 캐시 저장 완료');
    } catch (e) {
      debugPrint('❌ UltraFast: 영속 캐시 저장 실패 - $e');
    }
  }

  /// 마지막 성공 데이터 로딩
  Future<void> _loadLastSuccessfulDashboard() async {
    final cached = await _loadFromPersistentCache();
    if (cached != null) {
      _lastSuccessfulDashboard = cached;
      debugPrint('📱 UltraFast: 마지막 성공 데이터 복원됨');
    }
  }

  /// 대시보드 직렬화
  Map<String, dynamic> _serializeDashboard(HomeDashboardEntity dashboard) {
    return {
      'currentTime': dashboard.currentTime,
      'weather': _serializeWeather(dashboard.weather),
      'petProfiles': dashboard.petProfiles.map(_serializePetSummary).toList(),
      'upcomingAppointments': dashboard.upcomingAppointments
          .map(_serializeAppointment)
          .toList(),
      'petHealthSummary': _serializeHealthSummary(dashboard.petHealthSummary),
      'walkSummary': _serializeWalkSummary(dashboard.walkSummary),
    };
  }

  /// 대시보드 역직렬화
  HomeDashboardEntity _deserializeDashboard(Map<String, dynamic> data) {
    return HomeDashboardEntity(
      currentTime: data['currentTime'] as String,
      weather: _deserializeWeather(data['weather'] as Map<String, dynamic>),
      petProfiles: (data['petProfiles'] as List)
          .map((e) => _deserializePetSummary(e as Map<String, dynamic>))
          .toList(),
      upcomingAppointments: (data['upcomingAppointments'] as List)
          .map((e) => _deserializeAppointment(e as Map<String, dynamic>))
          .toList(),
      petHealthSummary: _deserializeHealthSummary(
        data['petHealthSummary'] as Map<String, dynamic>,
      ),
      walkSummary: _deserializeWalkSummary(
        data['walkSummary'] as Map<String, dynamic>,
      ),
    );
  }

  // 개별 엔티티 직렬화/역직렬화 메서드들
  Map<String, dynamic> _serializeWeather(WeatherEntity weather) {
    return {
      'temperature': weather.temperature,
      'location': weather.location,
      'weatherId': weather.weatherId,
      'description': weather.description,
      'feelsLike': weather.feelsLike,
      'humidity': weather.humidity,
      'windSpeed': weather.windSpeed,
      'iconCode': weather.iconCode,
      'uvIndex': weather.uvIndex,
      'visibility': weather.visibility,
      'pressure': weather.pressure,
    };
  }

  WeatherEntity _deserializeWeather(Map<String, dynamic> data) {
    return WeatherEntity(
      temperature: data['temperature'] as double,
      location: data['location'] as String,
      weatherId: data['weatherId'] as int,
      description: data['description'] as String,
      feelsLike: data['feelsLike'] as double,
      humidity: data['humidity'] as int,
      windSpeed: data['windSpeed'] as double,
      iconCode: data['iconCode'] as String,
      uvIndex: data['uvIndex'] as double,
      visibility: data['visibility'] as int,
      pressure: data['pressure'] as double,
    );
  }

  Map<String, dynamic> _serializePetSummary(PetSummaryEntity pet) {
    return {
      'id': pet.id,
      'name': pet.name,
      'typeName': pet.typeName,
      'breed': pet.breed,
      'age': pet.age,
      'birthDate': pet.birthDate.millisecondsSinceEpoch,
      'createdAt': pet.createdAt.millisecondsSinceEpoch,
      'profileImageUrl': pet.profileImageUrl,
      'additionalInfo': pet.additionalInfo,
    };
  }

  PetSummaryEntity _deserializePetSummary(Map<String, dynamic> data) {
    return PetSummaryEntity(
      id: data['id'] as String,
      name: data['name'] as String,
      typeName: data['typeName'] as String,
      breed: data['breed'] as String?,
      age: data['age'] as int,
      birthDate: DateTime.fromMillisecondsSinceEpoch(data['birthDate'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      profileImageUrl: data['profileImageUrl'] as String?,
      additionalInfo: data['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> _serializeAppointment(AppointmentSummary appointment) {
    return {
      'id': appointment.id,
      'title': appointment.title,
      'scheduledTime': appointment.scheduledTime.millisecondsSinceEpoch,
      'type': appointment.type,
      'petName': appointment.petName,
    };
  }

  AppointmentSummary _deserializeAppointment(Map<String, dynamic> data) {
    return AppointmentSummary(
      id: data['id'] as String,
      title: data['title'] as String,
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(
        data['scheduledTime'] as int,
      ),
      type: data['type'] as String,
      petName: data['petName'] as String,
    );
  }

  Map<String, dynamic> _serializeHealthSummary(HealthSummary health) {
    return {
      'totalPets': health.totalPets,
      'healthyPets': health.healthyPets,
      'petsNeedingAttention': health.petsNeedingAttention,
      'alerts': health.alerts
          .map((a) => {'petName': a.petName, 'message': a.message})
          .toList(),
    };
  }

  HealthSummary _deserializeHealthSummary(Map<String, dynamic> data) {
    return HealthSummary(
      totalPets: data['totalPets'] as int,
      healthyPets: data['healthyPets'] as int,
      petsNeedingAttention: data['petsNeedingAttention'] as int,
      alerts: (data['alerts'] as List)
          .map(
            (a) => HealthAlert(
              petName: a['petName'] as String,
              message: a['message'] as String,
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> _serializeWalkSummary(WalkSummary walk) {
    return {
      'todayWalks': walk.todayWalks,
      'todayDistance': walk.todayDistance,
      'todayDuration': walk.todayDuration.inMilliseconds,
      'weeklyGoal': walk.weeklyGoal,
      'weeklyProgress': walk.weeklyProgress,
      'isWeeklyRecord': walk.isWeeklyRecord,
    };
  }

  WalkSummary _deserializeWalkSummary(Map<String, dynamic> data) {
    return WalkSummary(
      todayWalks: data['todayWalks'] as int,
      todayDistance: data['todayDistance'] as double,
      todayDuration: Duration(milliseconds: data['todayDuration'] as int),
      weeklyGoal: data['weeklyGoal'] as double,
      weeklyProgress: data['weeklyProgress'] as double,
      isWeeklyRecord: data['isWeeklyRecord'] as bool,
    );
  }

  /// 캐시 무효화
  Future<void> invalidateCache() async {
    _lastSuccessfulDashboard = null;
    _lastUpdateTime = null;
    await _prefs?.remove(_persistentKey);
    debugPrint('🗑️ UltraFast: 캐시 무효화 완료');
  }

  /// 영속 캐시 키
  String get _persistentKey => 'ultra_fast_home_dashboard';

  /// 데이터 신선도 확인
  bool get isDataFresh {
    if (_lastUpdateTime == null) return false;
    return DateTime.now().difference(_lastUpdateTime!).inMinutes < 15;
  }
}
