/// 예약 관련 Mock 데이터 서비스
///
/// 예약 요약 정보와 관련된 Mock 데이터를 제공합니다.
class AppointmentMockData {
  /// 예약 시간 목업 데이터
  static List<DateTime> getMockAppointmentTimes(DateTime baseDate) {
    return [
      DateTime(baseDate.year, baseDate.month, baseDate.day, 14, 0), // 오늘 14:00
      DateTime(baseDate.year, baseDate.month, baseDate.day, 16, 30), // 오늘 16:30
      DateTime(baseDate.year, baseDate.month, baseDate.day + 1, 10, 0), // 내일 10:00
      DateTime(baseDate.year, baseDate.month, baseDate.day + 2, 15, 0), // 모레 15:00
      DateTime(baseDate.year, baseDate.month, baseDate.day + 3, 9, 30), // 3일 후 9:30
      DateTime(baseDate.year, baseDate.month, baseDate.day + 5, 11, 0), // 5일 후 11:00
    ];
  }

  /// 펫 타입별 예약 수 Mock 데이터
  static Map<String, int> getUpcomingAppointmentCount() {
    return {'dog': 3, 'cat': 1, 'rabbit': 2, 'hamster': 1, 'default': 2};
  }

  /// 펫 타입별 이번 달 총 예약 수 Mock 데이터
  static Map<String, int> getMonthlyAppointmentCount() {
    return {'dog': 6, 'cat': 3, 'rabbit': 5, 'hamster': 2, 'default': 4};
  }

  /// 다음 예약 시간을 계산하여 표시 형식으로 반환
  static String getNextAppointmentTime(DateTime now) {
    final mockAppointments = getMockAppointmentTimes(now);

    // 현재 시간 이후의 가장 빠른 예약 찾기
    DateTime? nextAppointment;
    for (final appointment in mockAppointments) {
      if (appointment.isAfter(now)) {
        if (nextAppointment == null || appointment.isBefore(nextAppointment)) {
          nextAppointment = appointment;
        }
      }
    }

    if (nextAppointment == null) {
      return '予約なし';
    }

    // 오늘인지 내일인지 확인
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(
      nextAppointment.year,
      nextAppointment.month,
      nextAppointment.day,
    );

    if (appointmentDay.isAtSameMomentAs(today)) {
      // 오늘
      final hour = nextAppointment.hour.toString().padLeft(2, '0');
      final minute = nextAppointment.minute.toString().padLeft(2, '0');
      return '今日 $hour:$minute';
    } else if (appointmentDay.difference(today).inDays == 1) {
      // 내일
      final hour = nextAppointment.hour.toString().padLeft(2, '0');
      final minute = nextAppointment.minute.toString().padLeft(2, '0');
      return '明日 $hour:$minute';
    } else {
      // 그 이후
      final month = nextAppointment.month;
      final day = nextAppointment.day;
      final hour = nextAppointment.hour.toString().padLeft(2, '0');
      final minute = nextAppointment.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
  }

  /// 펫 타입에 따른 예약 수 조회
  static int getUpcomingCountByPetType(String? petType) {
    final counts = getUpcomingAppointmentCount();
    return counts[petType] ?? counts['default']!;
  }

  /// 펫 타입에 따른 이번 달 예약 수 조회
  static int getMonthlyCountByPetType(String? petType) {
    final counts = getMonthlyAppointmentCount();
    return counts[petType] ?? counts['default']!;
  }
}
