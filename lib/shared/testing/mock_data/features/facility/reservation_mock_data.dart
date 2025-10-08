import 'package:flutter/material.dart';

/// 예약 관리 Mock 데이터 서비스
///
/// 예약 현황과 관련된 Mock 데이터를 제공합니다.
class ReservationMockData {
  /// 예약 상태 enum
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';

  /// Mock 예약 목록
  static List<Map<String, dynamic>> getMockReservations() {
    final now = DateTime.now();
    return [
      {
        'id': 'reservation_1',
        'petId': '1',
        'petName': 'MAX',
        'facilityName': '우리동물병원',
        'facilityType': 'hospital',
        'serviceType': '건강검진',
        'status': pending,
        'scheduledDate': now.add(const Duration(days: 2)),
        'scheduledTime': '14:00',
        'duration': 60,
        'notes': '연간 건강검진 예약',
        'createdAt': now.subtract(const Duration(days: 1)),
        'updatedAt': now.subtract(const Duration(hours: 2)),
      },
      {
        'id': 'reservation_2',
        'petId': '2',
        'petName': 'LUNA',
        'facilityName': '펫샵 루나',
        'facilityType': 'grooming',
        'serviceType': '미용',
        'status': confirmed,
        'scheduledDate': now.add(const Duration(days: 5)),
        'scheduledTime': '10:00',
        'duration': 90,
        'notes': '털 정리 및 목욕',
        'createdAt': now.subtract(const Duration(days: 3)),
        'updatedAt': now.subtract(const Duration(hours: 1)),
      },
      {
        'id': 'reservation_3',
        'petId': '3',
        'petName': 'MOMO',
        'facilityName': '우리동물병원',
        'facilityType': 'hospital',
        'serviceType': '예방접종',
        'status': confirmed,
        'scheduledDate': now.add(const Duration(days: 7)),
        'scheduledTime': '16:00',
        'duration': 30,
        'notes': '연간 종합백신 접종',
        'createdAt': now.subtract(const Duration(days: 5)),
        'updatedAt': now.subtract(const Duration(minutes: 30)),
      },
      {
        'id': 'reservation_4',
        'petId': '1',
        'petName': 'MAX',
        'facilityName': '펫샵 루나',
        'facilityType': 'grooming',
        'serviceType': '미용',
        'status': cancelled,
        'scheduledDate': now.subtract(const Duration(days: 1)),
        'scheduledTime': '15:00',
        'duration': 60,
        'notes': '일정 변경으로 취소',
        'createdAt': now.subtract(const Duration(days: 7)),
        'updatedAt': now.subtract(const Duration(days: 1)),
        'cancelledAt': now.subtract(const Duration(days: 1)),
        'cancellationReason': '일정 변경',
      },
      {
        'id': 'reservation_5',
        'petId': '4',
        'petName': 'ココ',
        'facilityName': '토끼전문병원',
        'facilityType': 'hospital',
        'serviceType': '건강검진',
        'status': pending,
        'scheduledDate': now.add(const Duration(days: 3)),
        'scheduledTime': '11:00',
        'duration': 45,
        'notes': '토끼 건강검진',
        'createdAt': now.subtract(const Duration(hours: 6)),
        'updatedAt': now.subtract(const Duration(hours: 3)),
      },
    ];
  }

  /// 상태별 예약 목록 조회
  static List<Map<String, dynamic>> getReservationsByStatus(String status) {
    return getMockReservations()
        .where((reservation) => reservation['status'] == status)
        .toList();
  }

  /// 펫별 예약 목록 조회
  static List<Map<String, dynamic>> getReservationsByPet(String petId) {
    return getMockReservations()
        .where((reservation) => reservation['petId'] == petId)
        .toList();
  }

  /// 펫별 상태별 예약 목록 조회
  static List<Map<String, dynamic>> getReservationsByPetAndStatus(
    String? petId,
    String status,
  ) {
    return getMockReservations()
        .where(
          (reservation) =>
              (petId == null || reservation['petId'] == petId) &&
              reservation['status'] == status,
        )
        .toList();
  }

  /// 예약 상태별 한글 표시명
  static String getStatusDisplayName(String status) {
    switch (status) {
      case pending:
        return '예약대기';
      case confirmed:
        return '예약확정';
      case cancelled:
        return '예약취소';
      default:
        return '알 수 없음';
    }
  }

  /// 예약 상태별 색상
  static Color getStatusColor(String status) {
    switch (status) {
      case pending:
        return Colors.orange;
      case confirmed:
        return Colors.green;
      case cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 예약 상태별 아이콘
  static IconData getStatusIcon(String status) {
    switch (status) {
      case pending:
        return Icons.schedule;
      case confirmed:
        return Icons.check_circle;
      case cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
