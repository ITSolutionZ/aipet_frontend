/// 예약 시간 관련 Mock 데이터 서비스
///
/// 시설 예약 시간 슬롯과 관련된 Mock 데이터를 제공합니다.
class BookingMockData {
  /// 기본 시간 슬롯 Mock 데이터
  static List<String> getDefaultTimeSlots() {
    return [
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
    ];
  }

  /// 병원 예약 시간 슬롯
  static List<String> getHospitalTimeSlots() {
    return [
      '09:00',
      '09:30',
      '10:00',
      '10:30',
      '11:00',
      '11:30',
      '14:00',
      '14:30',
      '15:00',
      '15:30',
      '16:00',
      '16:30',
    ];
  }

  /// 그루밍샵 예약 시간 슬롯
  static List<String> getGroomingTimeSlots() {
    return [
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
    ];
  }

  /// 시설 타입별 시간 슬롯 조회
  static List<String> getTimeSlotsByFacilityType(String facilityType) {
    switch (facilityType.toLowerCase()) {
      case 'hospital':
      case 'veterinary':
        return getHospitalTimeSlots();
      case 'grooming':
      case 'salon':
        return getGroomingTimeSlots();
      default:
        return getDefaultTimeSlots();
    }
  }

  /// 예약 가능한 날짜 범위 (오늘부터 30일 후까지)
  static List<DateTime> getAvailableDates() {
    final today = DateTime.now();
    final availableDates = <DateTime>[];

    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));
      // 일요일 제외
      if (date.weekday != 7) {
        availableDates.add(date);
      }
    }

    return availableDates;
  }

  /// 특정 날짜에 예약 불가능한 시간 슬롯 Mock 데이터
  static List<String> getUnavailableSlots(DateTime date, String facilityType) {
    // 오늘이면 현재 시간 이전 슬롯은 비활성화
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final unavailableSlots = <String>[];

    if (targetDate.isAtSameMomentAs(today)) {
      final currentHour = now.hour;
      final timeSlots = getTimeSlotsByFacilityType(facilityType);

      for (final slot in timeSlots) {
        final slotHour = int.parse(slot.split(':')[0]);
        if (slotHour <= currentHour) {
          unavailableSlots.add(slot);
        }
      }
    }

    // 랜덤하게 일부 슬롯을 예약 불가능하게 설정
    if (date.weekday == 6) {
      // 토요일은 더 많이 예약됨
      unavailableSlots.addAll(['14:00', '15:00', '16:00']);
    } else if (date.weekday == 5) {
      // 금요일
      unavailableSlots.addAll(['10:00', '11:00']);
    }

    return unavailableSlots;
  }

  /// 시간 슬롯이 예약 가능한지 확인
  static bool isTimeSlotAvailable(
    DateTime date,
    String timeSlot,
    String facilityType,
  ) {
    final unavailableSlots = getUnavailableSlots(date, facilityType);
    return !unavailableSlots.contains(timeSlot);
  }
}
