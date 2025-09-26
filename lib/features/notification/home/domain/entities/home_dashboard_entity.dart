import 'pet_summary_entity.dart';
import 'weather_entity.dart';

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
  final WeatherEntity weather;
  final List<PetSummaryEntity> petProfiles;
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
