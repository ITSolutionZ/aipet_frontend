import '../../../pet_registor/domain/entities/pet_profile_entity.dart';

class HomeDashboardEntity {
  final String currentTime;
  final WeatherInfo weather;
  final List<AppointmentSummary> upcomingAppointments;
  final HealthSummary petHealthSummary;
  final WalkSummary walkSummary;
  final List<PetProfileEntity> petProfiles;

  const HomeDashboardEntity({
    required this.currentTime,
    required this.weather,
    required this.upcomingAppointments,
    required this.petHealthSummary,
    required this.walkSummary,
    required this.petProfiles,
  });
}

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

class HealthAlert {
  final String petName;
  final String message;
  final AlertSeverity severity;

  const HealthAlert({
    required this.petName,
    required this.message,
    required this.severity,
  });
}

enum AlertSeverity { low, medium, high }

class WalkSummary {
  final int todayWalks;
  final double todayDistance;
  final Duration todayDuration;
  final int weeklyGoal;
  final int weeklyProgress;

  const WalkSummary({
    required this.todayWalks,
    required this.todayDistance,
    required this.todayDuration,
    required this.weeklyGoal,
    required this.weeklyProgress,
  });
}

// PetProfile 클래스 제거 - PetProfileEntity 사용
// HealthStatus enum은 PetProfileEntity로 이동
