import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/home/data/mappers/pet_mapper.dart';
import 'package:aipet_frontend/features/home/data/mappers/weather_mapper.dart';
import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/data/services/weather_service.dart';
import 'package:aipet_frontend/features/home/domain/entities/entities.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:aipet_frontend/shared/services/local_storage_service.dart';
import 'package:aipet_frontend/shared/services/ultra_fast_cache_service.dart';
import 'package:flutter/material.dart';

class HomeRepositoryImpl implements HomeRepository {
  final WeatherService _weatherService = WeatherService();
  final CacheService _cacheService = CacheService();
  final UltraFastCacheService _ultraFastCache = UltraFastCacheService();
  final LocalStorageService _localStorageService = LocalStorageService.instance;

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
      temperature: 23.0,
      location: '東京',
      weatherId: 800, // 맑음
      description: '晴れ',
      feelsLike: 25.0,
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
    try {
      debugPrint('🐾 getPetSummaries: 시작');

      // 캐시에서 펫 요약 정보 확인
      final cachedPetSummaries = _cacheService
          .getMemoryCache<List<PetSummaryEntity>>(CacheKeys.petProfiles);

      if (cachedPetSummaries != null) {
        debugPrint('⚡ getPetSummaries: 캐시에서 펫 요약 정보 반환');
        return cachedPetSummaries;
      }

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();
      debugPrint('🐾 getPetSummaries: 로컬 스토리지 초기화 완료');

      // 로컬 스토리지에서 펫 정보 가져오기 (실제 데이터)
      final petProfiles = await _localStorageService.pet.getAllPets();
      debugPrint('🐾 getPetSummaries: 로컬에서 ${petProfiles.length}개 펫 데이터 조회');

      // 빈 데이터인 경우 빈 리스트 반환
      if (petProfiles.isEmpty) {
        debugPrint('🐾 getPetSummaries: 펫 데이터가 없음 - 빈 리스트 반환');
        final emptySummaries = <PetSummaryEntity>[];

        // 빈 리스트도 캐시에 저장
        _cacheService.setMemoryCache(
          CacheKeys.petProfiles,
          emptySummaries,
          ttl: CacheTTL.long,
        );

        return emptySummaries;
      }

      // 펫 데이터를 요약 엔티티로 변환
      final petSummaries = PetMapper.toSummaryEntityListFromMaps(petProfiles);
      debugPrint('🐾 getPetSummaries: ${petSummaries.length}개 펫 요약 정보 생성 완료');

      // 펫 요약 정보 캐시 저장 (1시간 TTL)
      _cacheService.setMemoryCache(
        CacheKeys.petProfiles,
        petSummaries,
        ttl: CacheTTL.long,
      );

      return petSummaries;
    } catch (error, stackTrace) {
      debugPrint('❌ getPetSummaries: 에러 발생 - $error');
      debugPrint('📍 StackTrace: $stackTrace');

      // 에러 발생 시 빈 리스트 반환 (앱 크래시 방지)
      return <PetSummaryEntity>[];
    }
  }

  // 기존 호환성을 위해 유지
  Future<List<PetProfileEntity>> getPetProfiles() async {
    // 로컬 스토리지에서 펫 정보 가져오기 (실제 데이터)
    final petData = await _localStorageService.pet.getAllPets();
    return PetMapper.fromMapList(petData);
  }

  @override
  Future<WalkSummary> getWalkSummary() async {
    try {
      debugPrint('🚶 getWalkSummary: 시작');

      // 캐시에서 산책 요약 정보 확인
      final cachedWalkSummary = _cacheService.getMemoryCache<WalkSummary>(
        CacheKeys.walkSummary,
      );

      if (cachedWalkSummary != null) {
        debugPrint('⚡ getWalkSummary: 캐시에서 산책 요약 정보 반환');
        return cachedWalkSummary;
      }

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();

      // 로컬 스토리지에서 산책 기록 가져오기 (실제 데이터)
      final pets = await _localStorageService.pet.getAllPets();
      debugPrint('🚶 getWalkSummary: ${pets.length}개 펫 데이터 조회');

      int todayWalks = 0;
      double todayDistance = 0.0;
      Duration todayDuration = Duration.zero;

      // 각 펫의 오늘 산책 기록 집계
      for (final pet in pets) {
        try {
          final walkRecords = await _localStorageService.pet.getWalkRecords(
            pet['petId'] ?? pet['id'] ?? '',
          );
          final today = DateTime.now();

          for (final record in walkRecords) {
            final startTime = DateTime.tryParse(record['start_time'] ?? '');
            if (startTime != null &&
                startTime.year == today.year &&
                startTime.month == today.month &&
                startTime.day == today.day) {
              todayWalks++;
              todayDistance += (record['distance'] ?? 0.0) as double;
              todayDuration += Duration(seconds: record['duration'] ?? 0);
            }
          }
        } catch (petError) {
          debugPrint(
            '⚠️ getWalkSummary: 펫 ${pet['name']} 산책 기록 조회 실패 - $petError',
          );
          // 개별 펫 에러는 무시하고 계속 진행
        }
      }

      // 이번주 최장 기록 여부 계산 (예시: 30분 이상이면 최장 기록으로 처리)
      final isWeeklyRecord = todayDuration.inMinutes >= 30;

      final walkSummary = WalkSummary(
        todayWalks: todayWalks,
        todayDistance: todayDistance,
        todayDuration: todayDuration,
        weeklyGoal: 10.0,
        weeklyProgress: todayDistance / 10.0 * 100,
        isWeeklyRecord: isWeeklyRecord,
      );

      // 산책 요약 정보 캐시 저장 (15분 TTL)
      _cacheService.setMemoryCache(
        CacheKeys.walkSummary,
        walkSummary,
        ttl: CacheTTL.medium,
      );

      debugPrint(
        '🚶 getWalkSummary: 완료 - 오늘 $todayWalks회, 거리 ${todayDistance}km, 시간 ${todayDuration.inMinutes}분',
      );
      return walkSummary;
    } catch (error, stackTrace) {
      debugPrint('❌ getWalkSummary: 에러 발생 - $error');
      debugPrint('📍 StackTrace: $stackTrace');

      // 에러 발생 시 기본 산책 요약 정보 반환
      return const WalkSummary(
        todayWalks: 0,
        todayDistance: 0.0,
        todayDuration: Duration.zero,
        weeklyGoal: 10.0,
        weeklyProgress: 0.0,
        isWeeklyRecord: false,
      );
    }
  }

  @override
  Future<HealthSummary> getPetHealthSummary() async {
    try {
      debugPrint('🏥 getPetHealthSummary: 시작');

      // 캐시에서 건강 요약 정보 확인
      final cachedHealthSummary = _cacheService.getMemoryCache<HealthSummary>(
        CacheKeys.healthSummary,
      );

      if (cachedHealthSummary != null) {
        debugPrint('⚡ getPetHealthSummary: 캐시에서 건강 요약 정보 반환');
        return cachedHealthSummary;
      }

      await Future.delayed(_mockDelay);

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();

      // 로컬 스토리지에서 펫 정보와 건강 기록 가져오기
      final pets = await _localStorageService.pet.getAllPets();
      debugPrint('🏥 getPetHealthSummary: ${pets.length}개 펫 데이터 조회');

      final alerts = <HealthAlert>[];
      int healthyPets = 0;
      int petsNeedingAttention = 0;

      for (final pet in pets) {
        try {
          final healthRecords = await _localStorageService.pet.getHealthRecords(
            pet['petId'] ?? pet['id'] ?? '',
          );

          // 최근 건강 검진 확인 (30일 이내)
          final now = DateTime.now();
          bool needsCheckup = true;

          for (final record in healthRecords) {
            final recordDate = DateTime.tryParse(record['date'] ?? '');
            if (recordDate != null && now.difference(recordDate).inDays < 30) {
              needsCheckup = false;
              break;
            }
          }

          if (needsCheckup) {
            alerts.add(
              HealthAlert(petName: pet['name'] ?? '', message: '健康診断が必要です'),
            );
            petsNeedingAttention++;
          } else {
            healthyPets++;
          }
        } catch (petError) {
          debugPrint(
            '⚠️ getPetHealthSummary: 펫 ${pet['name']} 건강 기록 조회 실패 - $petError',
          );
          // 개별 펫 에러는 무시하고 계속 진행
          healthyPets++;
        }
      }

      final healthSummary = HealthSummary(
        totalPets: pets.length,
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

      debugPrint(
        '🏥 getPetHealthSummary: 완료 - 총 ${pets.length}마리, 건강 $healthyPets마리, 주의 $petsNeedingAttention마리',
      );
      return healthSummary;
    } catch (error, stackTrace) {
      debugPrint('❌ getPetHealthSummary: 에러 발생 - $error');
      debugPrint('📍 StackTrace: $stackTrace');

      // 에러 발생 시 기본 건강 요약 정보 반환
      return const HealthSummary(
        totalPets: 0,
        healthyPets: 0,
        petsNeedingAttention: 0,
        alerts: [],
      );
    }
  }

  @override
  Future<List<AppointmentSummary>> getUpcomingAppointments() async {
    try {
      debugPrint('📅 getUpcomingAppointments: 시작');

      // 캐시에서 예약 정보 확인
      final cachedAppointments = _cacheService
          .getMemoryCache<List<AppointmentSummary>>(CacheKeys.appointments);

      if (cachedAppointments != null) {
        debugPrint('⚡ getUpcomingAppointments: 캐시에서 예약 정보 반환');
        return cachedAppointments;
      }

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();

      // 로컬 스토리지에서 스케줄 정보 가져오기 (실제 데이터)
      final schedules = await _localStorageService.schedule
          .getUpcomingSchedules(limit: 10);
      debugPrint('📅 getUpcomingAppointments: ${schedules.length}개 스케줄 조회');

      final appointments = <AppointmentSummary>[];

      for (final schedule in schedules) {
        try {
          final scheduledTime = DateTime.tryParse(schedule['time'] ?? '');
          if (scheduledTime != null) {
            // 펫 이름 가져오기
            String petName = '';
            final petId = schedule['pet_id'];
            if (petId != null) {
              try {
                final pet = await _localStorageService.pet.getPetById(petId);
                petName = pet?['name'] ?? '';
              } catch (petError) {
                debugPrint('⚠️ getUpcomingAppointments: 펫 조회 실패 - $petError');
                petName = 'Unknown Pet';
              }
            }

            appointments.add(
              AppointmentSummary(
                id: schedule['id'] ?? '',
                title: schedule['title'] ?? '',
                scheduledTime: scheduledTime,
                type: schedule['type'] ?? 'other',
                petName: petName,
              ),
            );
          }
        } catch (scheduleError) {
          debugPrint('⚠️ getUpcomingAppointments: 스케줄 처리 실패 - $scheduleError');
          // 개별 스케줄 에러는 무시하고 계속 진행
        }
      }

      // 예약 정보 캐시 저장 (15분 TTL)
      _cacheService.setMemoryCache(
        CacheKeys.appointments,
        appointments,
        ttl: CacheTTL.medium,
      );

      debugPrint('📅 getUpcomingAppointments: 완료 - ${appointments.length}개 예약');
      return appointments;
    } catch (error, stackTrace) {
      debugPrint('❌ getUpcomingAppointments: 에러 발생 - $error');
      debugPrint('📍 StackTrace: $stackTrace');

      // 에러 발생 시 빈 예약 리스트 반환
      return <AppointmentSummary>[];
    }
  }

  // 개발 모드용 지연 시간 상수 (실제 데이터 사용으로 지연 시간 단축)
  static Duration get _mockDelay => AppConfig.current.environment == 'test'
      ? const Duration(milliseconds: 1)
      : const Duration(milliseconds: 100);
}
