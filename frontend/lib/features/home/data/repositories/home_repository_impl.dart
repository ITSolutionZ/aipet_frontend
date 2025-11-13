import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/app/services/local_storage_service.dart';
import 'package:aipet_frontend/app/services/ultra_fast_cache_service.dart';
import 'package:aipet_frontend/shared/shared.dart';

import '../../domain/domain.dart';
import '../mappers/pet_mapper.dart';
import '../mappers/weather_mapper.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final WeatherService _weatherService = WeatherService();
  final CacheService _cacheService = CacheService();
  final UltraFastCacheService _ultraFastCache = UltraFastCacheService();
  final LocalStorageService _localStorageService = LocalStorageService.instance;

  @override
  Future<HomeDashboardEntity> getDashboardData() async {
    try {
      LoggerService.debug('🏠 HomeRepositoryImpl: getDashboardData 시작');

      // 1단계: 초고속 캐시 확인 (즉시 반환 가능)
      final ultraFastCached = await _ultraFastCache.getUltraFastDashboard();
      if (ultraFastCached != null) {
        LoggerService.debug('🚀 HomeRepositoryImpl: 초고속 캐시에서 기본 데이터 즉시 반환');

        // ⚠️ 중요: 날씨 데이터만 실시간 GPS 위치로 업데이트
        LoggerService.debug('🌤️ HomeRepositoryImpl: GPS 기반 실시간 날씨 데이터 취득 중...');
        final freshWeather = await getCurrentWeather(userTriggered: true);

        // 날씨 데이터만 업데이트된 대시보드 반환
        final updatedDashboard = HomeDashboardEntity(
          currentTime: ultraFastCached.currentTime,
          weather: freshWeather ?? ultraFastCached.weather,
          petProfiles: ultraFastCached.petProfiles,
          upcomingAppointments: ultraFastCached.upcomingAppointments,
          petHealthSummary: ultraFastCached.petHealthSummary,
          walkSummary: ultraFastCached.walkSummary,
        );

        LoggerService.debug('✅ HomeRepositoryImpl: 실시간 날씨로 업데이트 완료');
        return updatedDashboard;
      }

      // 2단계: 데이터 없음 - 새로 로딩
      LoggerService.debug('🔄 HomeRepositoryImpl: 새 데이터 로딩 시작...');

      // 개별 데이터 병렬 로딩
      final results = await Future.wait([
        getCurrentWeather(userTriggered: true), // GPS 기반 실시간 날씨
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

      LoggerService.debug('✅ HomeRepositoryImpl: 병렬 데이터 조회 완료');

      final now = DateTime.now();
      final currentTime = DateTimeUtils.formatTime(now);

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

      LoggerService.debug('✅ HomeRepositoryImpl: getDashboardData 완료');
      return dashboard;
    } catch (error, stackTrace) {
      LoggerService.debug(
        '💥 HomeRepositoryImpl: getDashboardData 실패 - $error',
      );
      LoggerService.debug('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<WeatherEntity?> getCurrentWeather({
    WeatherLocationEntity? location,
    bool userTriggered = false,
  }) async {
    try {
      // WeatherService를 사용하여 실시간 GPS 위치 기반 날씨 데이터 조회
      // 캐시를 사용하지 않고 항상 사용자의 현재 위치로 날씨 조회
      WeatherLocation? weatherLocation;
      if (location != null) {
        weatherLocation = WeatherMapper.toDataLocation(location);
        LoggerService.debug('📍 getCurrentWeather: 지정된 위치 사용 - ${location.name}');
      } else {
        LoggerService.debug('📍 getCurrentWeather: GPS 위치 자동 감지 사용');
      }

      final weatherData = await _weatherService.getCurrentWeather(
        location: weatherLocation,
        userTriggered: userTriggered,
      );

      if (weatherData != null) {
        final weatherEntity = WeatherMapper.toEntity(weatherData);

        LoggerService.debug(
          '✅ getCurrentWeather: 날씨 데이터 취득 성공 - ${weatherEntity.location}, ${weatherEntity.temperature}°C',
        );

        // 위치 기반 캐시 키 생성 (위도, 경도를 포함)
        final cacheKey = '${CacheKeys.weather}_${weatherEntity.location}';

        // 날씨 데이터 캐시 저장 (3분 TTL - GPS 위치 기반이므로 짧게 설정)
        await _cacheService.setCache(
          cacheKey,
          weatherEntity,
          ttl: const Duration(minutes: 3),
        );

        return weatherEntity;
      }

      return null;
    } catch (e) {
      LoggerService.debug('❌ getCurrentWeather: 에러 발생 - $e');
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
      LoggerService.debug('🐾 getPetSummaries: 시작');

      // 캐시에서 펫 요약 정보 확인
      final cachedPetSummaries = _cacheService.getCache<List<PetSummaryEntity>>(
        CacheKeys.petProfiles,
      );

      if (cachedPetSummaries != null) {
        LoggerService.debug('⚡ getPetSummaries: 캐시에서 펫 요약 정보 반환');
        return cachedPetSummaries;
      }

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();
      LoggerService.debug('🐾 getPetSummaries: 로컬 스토리지 초기화 완료');

      // 로컬 스토리지에서 펫 정보 가져오기 (실제 데이터)
      final petProfiles = await _localStorageService.pet.getAllPets();
      LoggerService.debug(
        '🐾 getPetSummaries: 로컬에서 ${petProfiles.length}개 펫 데이터 조회',
      );

      // 빈 데이터인 경우 빈 리스트 반환
      if (petProfiles.isEmpty) {
        LoggerService.debug('🐾 getPetSummaries: 펫 데이터가 없음 - 빈 리스트 반환');
        final emptySummaries = <PetSummaryEntity>[];

        // 빈 리스트도 캐시에 저장
        await _cacheService.setCache(
          CacheKeys.petProfiles,
          emptySummaries,
          ttl: CacheTTL.long,
        );

        return emptySummaries;
      }

      // 펫 데이터를 요약 엔티티로 변환
      final petSummaries = PetMapper.toSummaryEntityListFromMaps(petProfiles);
      LoggerService.debug(
        '🐾 getPetSummaries: ${petSummaries.length}개 펫 요약 정보 생성 완료',
      );

      // 펫 요약 정보 캐시 저장 (1시간 TTL)
      await _cacheService.setCache(
        CacheKeys.petProfiles,
        petSummaries,
        ttl: CacheTTL.long,
      );

      return petSummaries;
    } catch (error, stackTrace) {
      LoggerService.debug('❌ getPetSummaries: 에러 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');

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
      LoggerService.debug('🚶 getWalkSummary: 시작');

      // 캐시에서 산책 요약 정보 확인
      final cachedWalkSummary = _cacheService.getCache<WalkSummary>(
        CacheKeys.walkSummary,
      );

      if (cachedWalkSummary != null) {
        LoggerService.debug('⚡ getWalkSummary: 캐시에서 산책 요약 정보 반환');
        return cachedWalkSummary;
      }

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();

      // 로컬 스토리지에서 산책 기록 가져오기 (실제 데이터)
      final pets = await _localStorageService.pet.getAllPets();
      LoggerService.debug('🚶 getWalkSummary: ${pets.length}개 펫 데이터 조회');

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
          LoggerService.debug(
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
      await _cacheService.setCache(
        CacheKeys.walkSummary,
        walkSummary,
        ttl: CacheTTL.medium,
      );

      LoggerService.debug(
        '🚶 getWalkSummary: 완료 - 오늘 $todayWalks회, 거리 ${todayDistance}km, 시간 ${todayDuration.inMinutes}분',
      );
      return walkSummary;
    } catch (error, stackTrace) {
      LoggerService.debug('❌ getWalkSummary: 에러 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');

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
      LoggerService.debug('🏥 getPetHealthSummary: 시작');

      // 캐시에서 건강 요약 정보 확인
      final cachedHealthSummary = _cacheService.getCache<HealthSummary>(
        CacheKeys.healthSummary,
      );

      if (cachedHealthSummary != null) {
        LoggerService.debug('⚡ getPetHealthSummary: 캐시에서 건강 요약 정보 반환');
        return cachedHealthSummary;
      }

      await Future.delayed(_mockDelay);

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();

      // 로컬 스토리지에서 펫 정보와 건강 기록 가져오기
      final pets = await _localStorageService.pet.getAllPets();
      LoggerService.debug('🏥 getPetHealthSummary: ${pets.length}개 펫 데이터 조회');

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
          LoggerService.debug(
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
      await _cacheService.setCache(
        CacheKeys.healthSummary,
        healthSummary,
        ttl: CacheTTL.medium,
      );

      LoggerService.debug(
        '🏥 getPetHealthSummary: 완료 - 총 ${pets.length}마리, 건강 $healthyPets마리, 주의 $petsNeedingAttention마리',
      );
      return healthSummary;
    } catch (error, stackTrace) {
      LoggerService.debug('❌ getPetHealthSummary: 에러 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');

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
      LoggerService.debug('📅 getUpcomingAppointments: 시작');

      // 캐시에서 예약 정보 확인
      final cachedAppointments = _cacheService
          .getCache<List<AppointmentSummary>>(CacheKeys.appointments);

      if (cachedAppointments != null) {
        LoggerService.debug('⚡ getUpcomingAppointments: 캐시에서 예약 정보 반환');
        return cachedAppointments;
      }

      // 로컬 스토리지 초기화 확인
      await _localStorageService.initialize();

      // 로컬 스토리지에서 스케줄 정보 가져오기 (실제 데이터)
      final schedules = await _localStorageService.schedule
          .getUpcomingSchedules(limit: 10);
      LoggerService.debug(
        '📅 getUpcomingAppointments: ${schedules.length}개 스케줄 조회',
      );

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
                LoggerService.debug(
                  '⚠️ getUpcomingAppointments: 펫 조회 실패 - $petError',
                );
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
          LoggerService.debug(
            '⚠️ getUpcomingAppointments: 스케줄 처리 실패 - $scheduleError',
          );
          // 개별 스케줄 에러는 무시하고 계속 진행
        }
      }

      // 예약 정보 캐시 저장 (15분 TTL)
      await _cacheService.setCache(
        CacheKeys.appointments,
        appointments,
        ttl: CacheTTL.medium,
      );

      LoggerService.debug(
        '📅 getUpcomingAppointments: 완료 - ${appointments.length}개 예약',
      );
      return appointments;
    } catch (error, stackTrace) {
      LoggerService.debug('❌ getUpcomingAppointments: 에러 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');

      // 에러 발생 시 빈 예약 리스트 반환
      return <AppointmentSummary>[];
    }
  }

  // 개발 모드용 지연 시간 상수 (실제 데이터 사용으로 지연 시간 단축)
  static Duration get _mockDelay => AppConfig.current.environment == 'test'
      ? const Duration(milliseconds: 1)
      : const Duration(milliseconds: 100);
}
