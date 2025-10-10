import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/home/data/mappers/weather_mapper.dart';
import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/data/services/weather_service.dart';
import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/data/datasources/pet_profile_local_datasource.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:aipet_frontend/shared/services/ultra_fast_cache_service.dart';
import 'package:flutter/material.dart';

class HomeRepositoryImpl implements HomeRepository {
  final WeatherService _weatherService = WeatherService();
  final CacheService _cacheService = CacheService();
  final UltraFastCacheService _ultraFastCache = UltraFastCacheService();

  @override
  Future<HomeDashboardEntity> getDashboardData() async {
    try {
      debugPrint('🏠 HomeRepositoryImpl: getDashboardData 시작');

      // 1단계: 초고속 캐시 확인 (즉시 반환 가능)
      final ultraFastCached = await _ultraFastCache.getUltraFastDashboard();
      if (ultraFastCached != null) {
        debugPrint('🚀 HomeRepositoryImpl: 초고속 캐시에서 즉시 반환');
        return ultraFastCached;
      }

      // 2단계: 데이터 없음 - 새로 로딩
      debugPrint('🔄 HomeRepositoryImpl: 새 데이터 로딩 시작...');

      // 개별 데이터 병렬 로딩
      final results = await Future.wait([
        getCurrentWeather(),
        getPetSummaries(),
        getUpcomingAppointments(),
        getPetHealthSummary(),
        getWalkSummary(),
      ]);

      final weather = results[0] as WeatherEntity?;
      final petProfiles = results[1] as List<PetSummaryEntity>;
      final appointments = results[2] as List<AppointmentSummary>;
      final healthSummary = results[3] as HealthSummary;
      final walkSummary = results[4] as WalkSummary;

      debugPrint('✅ HomeRepositoryImpl: 병렬 데이터 조회 완료');

      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final dashboard = HomeDashboardEntity(
        currentTime: currentTime,
        weather: weather ?? _getMockWeatherEntity(),
        petProfiles: petProfiles,
        upcomingAppointments: appointments,
        petHealthSummary: healthSummary,
        walkSummary: walkSummary,
      );

      // 3단계: 초고속 캐시에 저장 (다음 로딩 시 즉시 반환용)
      await _ultraFastCache.saveDashboard(dashboard);

      debugPrint('✅ HomeRepositoryImpl: getDashboardData 완료');
      return dashboard;
    } catch (error, stackTrace) {
      debugPrint('💥 HomeRepositoryImpl: getDashboardData 실패 - $error');
      debugPrint('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<WeatherEntity?> getCurrentWeather({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    try {
      // 사용자가 직접 요청하지 않은 경우 캐시 확인
      if (!userTriggered) {
        final cachedWeather = _cacheService.getMemoryCache<WeatherEntity>(
          CacheKeys.weather,
        );
        if (cachedWeather != null) {
          debugPrint('⚡ getCurrentWeather: 캐시에서 날씨 데이터 반환');
          return cachedWeather;
        }
      }

      // WeatherService를 사용하여 날씨 데이터 조회
      WeatherLocation? weatherLocation;
      if (location != null) {
        weatherLocation = WeatherMapper.toDataLocation(location);
      }

      final weatherData = await _weatherService.getCurrentWeather(
        location: weatherLocation,
        userTriggered: userTriggered,
      );

      if (weatherData != null) {
        final weatherEntity = WeatherMapper.toEntity(weatherData);

        // 날씨 데이터 캐시 저장 (5분 TTL)
        _cacheService.setMemoryCache(
          CacheKeys.weather,
          weatherEntity,
          ttl: CacheTTL.short,
        );

        return weatherEntity;
      }

      return null;
    } catch (e) {
      // 에러 발생시 null 반환
      return null;
    }
  }

  /// Mock 날씨 엔티티 (API 실패시 fallback)
  WeatherEntity _getMockWeatherEntity() {
    return const WeatherEntity(
      temperature: 22.0,
      location: '東京',
      weatherId: 800, // 맑음
      description: '晴れ',
      feelsLike: 24.0,
      humidity: 65,
      windSpeed: 2.5,
      iconCode: '01d',
      uvIndex: 5.0,
      visibility: 10000,
      pressure: 1013.25,
    );
  }

  @override
  Future<List<PetSummaryEntity>> getPetSummaries() async {
    // 캐시에서 펫 요약 정보 확인
    final cachedPetSummaries = _cacheService
        .getMemoryCache<List<PetSummaryEntity>>(CacheKeys.petProfiles);

    if (cachedPetSummaries != null) {
      debugPrint('⚡ getPetSummaries: 캐시에서 펫 요약 정보 반환');
      return cachedPetSummaries;
    }

    // 로컬 데이터 소스에서 실제 펫 프로필 가져오기
    await Future.delayed(_mockDelay);
    final petProfiles = PetProfileLocalDatasource.getPetProfiles();

    // PetProfileEntity를 PetSummaryEntity로 변환
    final petSummaries = petProfiles
        .map(
          (pet) => PetSummaryEntity(
            id: pet.id,
            name: pet.name,
            typeName: pet.typeName,
            breed: pet.breed ?? '',
            age: pet.age,
            birthDate: pet.birthDate,
            createdAt: pet.createdAt,
            profileImageUrl: pet.imagePath,
          ),
        )
        .toList();

    // 펫 요약 정보 캐시 저장 (1시간 TTL)
    _cacheService.setMemoryCache(
      CacheKeys.petProfiles,
      petSummaries,
      ttl: CacheTTL.long,
    );

    return petSummaries;
  }

  // 기존 호환성을 위해 유지
  Future<List<PetProfileEntity>> getPetProfiles() async {
    // 로컬 데이터 소스에서 실제 펫 프로필 가져오기
    await Future.delayed(_mockDelay);
    return PetProfileLocalDatasource.getPetProfiles();
  }

  @override
  Future<WalkSummary> getWalkSummary() async {
    // 캐시에서 산책 요약 정보 확인
    final cachedWalkSummary = _cacheService.getMemoryCache<WalkSummary>(
      CacheKeys.walkSummary,
    );

    if (cachedWalkSummary != null) {
      debugPrint('⚡ getWalkSummary: 캐시에서 산책 요약 정보 반환');
      return cachedWalkSummary;
    }

    // 로컬 Mock 데이터 직접 생성
    await Future.delayed(_mockDelay);

    const todayDuration = Duration(minutes: 35);
    const isWeeklyRecord = true; // 35분은 이번주 최장 기록

    const walkSummary = WalkSummary(
      todayWalks: 2,
      todayDistance: 3.5,
      todayDuration: todayDuration,
      weeklyGoal: 20.0,
      weeklyProgress: 15.5,
      isWeeklyRecord: isWeeklyRecord,
    );

    // 산책 요약 정보 캐시 저장 (15분 TTL)
    _cacheService.setMemoryCache(
      CacheKeys.walkSummary,
      walkSummary,
      ttl: CacheTTL.medium,
    );

    return walkSummary;
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    // 캐시에서 건강 요약 정보 확인
    final cachedHealthSummary = _cacheService.getMemoryCache<HealthSummary>(
      CacheKeys.healthSummary,
    );

    if (cachedHealthSummary != null) {
      debugPrint('⚡ getPetHealthSummary: 캐시에서 건강 요약 정보 반환');
      return cachedHealthSummary;
    }

    // 로컬 데이터 소스에서 실제 펫 프로필 가져오기
    await Future.delayed(_mockDelay);
    final petProfiles = PetProfileLocalDatasource.getPetProfiles();

    // 실제 펫 데이터 기반으로 건강 요약 생성
    final totalPets = petProfiles.length;
    final healthyPets = petProfiles.where((pet) => pet.isActive).length;
    final petsNeedingAttention = totalPets - healthyPets;

    // 빈 알림 리스트 (실제 펫이 없으므로)
    final alerts = <HealthAlert>[];

    final healthSummary = HealthSummary(
      totalPets: totalPets,
      healthyPets: healthyPets,
      petsNeedingAttention: petsNeedingAttention,
      alerts: alerts,
    );

    // 건강 요약 정보 캐시 저장 (15분 TTL)
    _cacheService.setMemoryCache(
      CacheKeys.healthSummary,
      healthSummary,
      ttl: CacheTTL.medium,
    );

    return healthSummary;
  }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async {
    // 캐시에서 예약 정보 확인
    final cachedAppointments = _cacheService
        .getMemoryCache<List<AppointmentSummary>>(CacheKeys.appointments);

    if (cachedAppointments != null) {
      debugPrint('⚡ getUpcomingAppointments: 캐시에서 예약 정보 반환');
      return cachedAppointments;
    }

    // 로컬 데이터 직접 생성
    await Future.delayed(_mockDelay);

    final appointments = [
      AppointmentSummary(
        id: 'app-1',
        title: '健康診断',
        scheduledTime: DateTime.now().add(const Duration(days: 3)),
        type: 'health_check',
        petName: 'マックス',
      ),
      AppointmentSummary(
        id: 'app-2',
        title: '予防接種',
        scheduledTime: DateTime.now().add(const Duration(days: 7)),
        type: 'vaccination',
        petName: 'ルナ',
      ),
    ];

    // 예약 정보 캐시 저장 (15분 TTL)
    _cacheService.setMemoryCache(
      CacheKeys.appointments,
      appointments,
      ttl: CacheTTL.medium,
    );

    return appointments;
  }

  // 개발 모드용 지연 시간 상수
  static Duration get _mockDelay => AppConfig.current.environment == 'test'
      ? const Duration(milliseconds: 1)
      : const Duration(milliseconds: 250);
}
