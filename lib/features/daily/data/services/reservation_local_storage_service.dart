import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 예약 데이터 로컬 저장소 서비스
class ReservationLocalStorageService {
  static const String _keyReservations = 'reservations';

  /// 예약 상태 상수
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';

  /// 모든 예약 조회
  static Future<List<Map<String, dynamic>>> getReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyReservations);

    if (jsonString == null) {
      // 초기 데이터 설정
      await _initializeDefaultReservations();
      return getReservations();
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);

      // DateTime 필드 변환
      if (map['scheduledDate'] is String) {
        map['scheduledDate'] = DateTime.parse(map['scheduledDate'] as String);
      }
      if (map['createdAt'] is String) {
        map['createdAt'] = DateTime.parse(map['createdAt'] as String);
      }
      if (map['updatedAt'] is String) {
        map['updatedAt'] = DateTime.parse(map['updatedAt'] as String);
      }
      if (map['cancelledAt'] is String) {
        map['cancelledAt'] = DateTime.parse(map['cancelledAt'] as String);
      }

      return map;
    }).toList();
  }

  /// 예약 추가
  static Future<void> addReservation(Map<String, dynamic> reservation) async {
    final reservations = await getReservations();
    reservations.add(reservation);
    await _saveReservations(reservations);
  }

  /// 예약 업데이트
  static Future<void> updateReservation(
    Map<String, dynamic> reservation,
  ) async {
    final reservations = await getReservations();
    final index = reservations.indexWhere((r) => r['id'] == reservation['id']);

    if (index != -1) {
      reservations[index] = reservation;
      await _saveReservations(reservations);
    }
  }

  /// 예약 삭제
  static Future<void> deleteReservation(String id) async {
    final reservations = await getReservations();
    reservations.removeWhere((reservation) => reservation['id'] == id);
    await _saveReservations(reservations);
  }

  /// 펫별 예약 조회
  static Future<List<Map<String, dynamic>>> getReservationsByPet(
    String petId,
  ) async {
    final allReservations = await getReservations();
    return allReservations
        .where((reservation) => reservation['petId'] == petId)
        .toList();
  }

  /// 상태별 예약 조회
  static Future<List<Map<String, dynamic>>> getReservationsByStatus(
    String status,
  ) async {
    final allReservations = await getReservations();
    return allReservations
        .where((reservation) => reservation['status'] == status)
        .toList();
  }

  /// 펫 ID와 상태로 예약 조회
  static Future<List<Map<String, dynamic>>> getReservationsByPetAndStatus(
    String? petId,
    String status,
  ) async {
    final allReservations = await getReservations();

    if (petId == null) {
      return allReservations
          .where((reservation) => reservation['status'] == status)
          .toList();
    }

    return allReservations
        .where(
          (reservation) =>
              reservation['petId'] == petId && reservation['status'] == status,
        )
        .toList();
  }

  /// 예약 저장
  static Future<void> _saveReservations(
    List<Map<String, dynamic>> reservations,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // DateTime을 ISO8601 문자열로 변환
    final serializedList = reservations.map((reservation) {
      final map = Map<String, dynamic>.from(reservation);

      if (map['scheduledDate'] is DateTime) {
        map['scheduledDate'] = (map['scheduledDate'] as DateTime)
            .toIso8601String();
      }
      if (map['createdAt'] is DateTime) {
        map['createdAt'] = (map['createdAt'] as DateTime).toIso8601String();
      }
      if (map['updatedAt'] is DateTime) {
        map['updatedAt'] = (map['updatedAt'] as DateTime).toIso8601String();
      }
      if (map['cancelledAt'] is DateTime) {
        map['cancelledAt'] = (map['cancelledAt'] as DateTime).toIso8601String();
      }

      return map;
    }).toList();

    final jsonString = jsonEncode(serializedList);
    await prefs.setString(_keyReservations, jsonString);
  }

  /// 초기 예약 데이터 설정
  static Future<void> _initializeDefaultReservations() async {
    final now = DateTime.now();

    final defaultReservations = <Map<String, dynamic>>[
      {
        'id': 'reservation_1',
        'petId': 'pet_1',
        'petName': 'モコ',
        'facilityId': 'facility_1',
        'facilityName': 'さくら動物病院',
        'serviceType': '健康診断',
        'scheduledDate': now.add(const Duration(days: 3)),
        'scheduledTime': '10:00',
        'status': pending,
        'notes': '定期健康診断の予約',
        'createdAt': now.subtract(const Duration(days: 5)),
        'updatedAt': now.subtract(const Duration(days: 5)),
      },
      {
        'id': 'reservation_2',
        'petId': 'pet_1',
        'petName': 'モコ',
        'facilityId': 'facility_2',
        'facilityName': 'ペットサロン みらい',
        'serviceType': 'トリミング',
        'scheduledDate': now.add(const Duration(days: 7)),
        'scheduledTime': '14:30',
        'status': confirmed,
        'notes': 'カットとシャンプー',
        'createdAt': now.subtract(const Duration(days: 10)),
        'updatedAt': now.subtract(const Duration(days: 2)),
      },
    ];

    await _saveReservations(defaultReservations);
  }

  /// 모든 예약 데이터 삭제
  static Future<void> clearAllReservations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReservations);
  }

  /// 상태 표시 이름 반환
  static String getStatusDisplayName(String status) {
    switch (status) {
      case pending:
        return '予約待ち';
      case confirmed:
        return '予約確定';
      case cancelled:
        return 'キャンセル済み';
      case completed:
        return '完了';
      default:
        return '不明';
    }
  }

  /// 상태별 색상 반환
  static Color getStatusColor(String status) {
    switch (status) {
      case pending:
        return const Color(0xFFFF9500); // 오렌지
      case confirmed:
        return const Color(0xFF34C759); // 그린
      case cancelled:
        return const Color(0xFFFF3B30); // 레드
      case completed:
        return const Color(0xFF007AFF); // 블루
      default:
        return const Color(0xFF8E8E93); // 그레이
    }
  }

  /// 상태별 아이콘 반환
  static IconData getStatusIcon(String status) {
    switch (status) {
      case pending:
        return Icons.schedule;
      case confirmed:
        return Icons.check_circle;
      case cancelled:
        return Icons.cancel;
      case completed:
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }
}
