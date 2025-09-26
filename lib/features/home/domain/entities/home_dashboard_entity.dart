/// 🏠 홈 대시보드 엔티티
///
/// 홈 화면에 표시되는 전체 대시보드 데이터
class HomeDashboardEntity {
  final String userId;
  final WeatherEntity? weather;
  final List<PetSummaryEntity> pets;
  final List<TodayAppointmentEntity> todayAppointments;
  final int totalWalkMinutes;
  final DateTime lastUpdated;

  const HomeDashboardEntity({
    required this.userId,
    this.weather,
    required this.pets,
    required this.todayAppointments,
    required this.totalWalkMinutes,
    required this.lastUpdated,
  });

  factory HomeDashboardEntity.empty() => HomeDashboardEntity(
        userId: '',
        weather: null,
        pets: const [],
        todayAppointments: const [],
        totalWalkMinutes: 0,
        lastUpdated: DateTime.now(),
      );

  /// 펫이 등록되어 있는지 확인
  bool get hasPets => pets.isNotEmpty;

  /// 오늘의 예약이 있는지 확인
  bool get hasTodayAppointments => todayAppointments.isNotEmpty;
}

/// 🌤️ 날씨 엔티티
class WeatherEntity {
  final double temperature;
  final String condition;
  final String icon;
  final String location;
  final DateTime timestamp;

  const WeatherEntity({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.location,
    required this.timestamp,
  });

  /// 산책하기 좋은 날씨인지 판단
  bool get isGoodForWalking {
    // 간단한 로직: 10도 이상, 30도 이하, 비가 오지 않는 경우
    return temperature >= 10 &&
           temperature <= 30 &&
           !condition.toLowerCase().contains('rain');
  }
}

/// 🐕 펫 요약 엔티티
class PetSummaryEntity {
  final String id;
  final String name;
  final String type;
  final String? imageUrl;
  final int age;
  final bool needsAttention;
  final String? attentionReason;

  const PetSummaryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
    required this.age,
    this.needsAttention = false,
    this.attentionReason,
  });
}

/// 📅 오늘의 예약 엔티티
class TodayAppointmentEntity {
  final String id;
  final String title;
  final DateTime scheduledTime;
  final String location;
  final String type;
  final bool isCompleted;

  const TodayAppointmentEntity({
    required this.id,
    required this.title,
    required this.scheduledTime,
    required this.location,
    required this.type,
    this.isCompleted = false,
  });

  /// 예약 시간까지 남은 시간 (분 단위)
  int get minutesUntilAppointment {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now).inMinutes;
    return difference > 0 ? difference : 0;
  }
}