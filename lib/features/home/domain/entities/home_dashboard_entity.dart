import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../../data/models/weather_model.dart';

// 예약 정보 요약
class AppointmentSummary {
  final String id;
  final String title;
  final DateTime scheduledTime;
  final String type;
  final String petName;

  const AppointmentSummary({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.type,
    required this.petName,
  });
}

// 건강 상태 요약
class HealthSummary {
  final int totalPets;
  final int healthyPets;
  final int petsNeedingAttention;
  final List<HealthAlert> alerts;

  const HealthSummary({
    required this.totalPets,
    required this.healthyPets,
    required this.petsNeedingAttention,
    required this.alerts,
  });
}

// 건강 알림
class HealthAlert {
  final String petName;
  final String message;

  const HealthAlert({required this.petName, required this.message});
}

// 산책 요약
class WalkSummary {
  final int todayWalks;
  final double todayDistance;
  final Duration todayDuration;
  final double weeklyGoal;
  final double weeklyProgress;

  const WalkSummary({
    required this.todayWalks,
    required this.todayDistance,
    required this.todayDuration,
    required this.weeklyGoal,
    required this.weeklyProgress,
  });
}

class HomeDashboardEntity {
  final String currentTime;
  final WeatherData weather;
  final List<PetProfileEntity> petProfiles;
  final List<AppointmentSummary> upcomingAppointments;
  final HealthSummary petHealthSummary;
  final WalkSummary walkSummary;

  const HomeDashboardEntity({
    required this.currentTime,
    required this.weather,
    required this.petProfiles,
    required this.upcomingAppointments,
    required this.petHealthSummary,
    required this.walkSummary,
  });
}

// 기존 WeatherInfo 클래스 (하위 호환성을 위해 유지)
class WeatherInfo {
  final double temperature;
  final String condition;
  final String iconCode;
  final String location;

  const WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.location,
  });
}
