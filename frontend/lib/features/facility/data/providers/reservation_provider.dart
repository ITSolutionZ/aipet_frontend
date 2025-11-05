import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/scheduling/data/services/calendar_event_service.dart';
import '../../../../../features/scheduling/domain/entities/calendar_event_entity.dart';


part 'reservation_provider.g.dart';

/// 예약 상태 열거형
enum ReservationStatus {
  pending('예약대기'),
  confirmed('예약완료'),
  cancelled('예약취소');

  const ReservationStatus(this.displayName);
  final String displayName;
}

/// 예약 정보 모델
class HospitalReservation {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String petId;
  final String petName;
  final String reserverName;
  final String phoneNumber;
  final String purpose;
  final DateTime reservationDate;
  final String timeSlot;
  final String? symptoms;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HospitalReservation({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.petId,
    required this.petName,
    required this.reserverName,
    required this.phoneNumber,
    required this.purpose,
    required this.reservationDate,
    required this.timeSlot,
    this.symptoms,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hospitalId': hospitalId,
    'hospitalName': hospitalName,
    'petId': petId,
    'petName': petName,
    'reserverName': reserverName,
    'phoneNumber': phoneNumber,
    'purpose': purpose,
    'reservationDate': reservationDate.toIso8601String(),
    'timeSlot': timeSlot,
    'symptoms': symptoms,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory HospitalReservation.fromJson(Map<String, dynamic> json) =>
      HospitalReservation(
        id: json['id'] as String,
        hospitalId: json['hospitalId'] as String,
        hospitalName: json['hospitalName'] as String,
        petId: json['petId'] as String,
        petName: json['petName'] as String,
        reserverName: json['reserverName'] as String,
        phoneNumber: json['phoneNumber'] as String,
        purpose: json['purpose'] as String,
        reservationDate: DateTime.parse(json['reservationDate'] as String),
        timeSlot: json['timeSlot'] as String,
        symptoms: json['symptoms'] as String?,
        status: ReservationStatus.values.firstWhere(
          (status) => status.name == json['status'],
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  HospitalReservation copyWith({
    String? id,
    String? hospitalId,
    String? hospitalName,
    String? petId,
    String? petName,
    String? reserverName,
    String? phoneNumber,
    String? purpose,
    DateTime? reservationDate,
    String? timeSlot,
    String? symptoms,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HospitalReservation(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      reserverName: reserverName ?? this.reserverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      purpose: purpose ?? this.purpose,
      reservationDate: reservationDate ?? this.reservationDate,
      timeSlot: timeSlot ?? this.timeSlot,
      symptoms: symptoms ?? this.symptoms,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 예약 관리 프로바이더
@riverpod
class ReservationsNotifier extends _$ReservationsNotifier {
  static const String storageKey = 'hospital_reservations';

  @override
  Future<List<HospitalReservation>> build() async {
    try {
      final reservationsJsonString = await SecureStorageService.getString(
        storageKey,
      );

      if (reservationsJsonString != null) {
        final List<dynamic> reservationsJson =
            jsonDecode(reservationsJsonString) as List<dynamic>;
        final reservationsList = reservationsJson
            .map(
              (json) =>
                  HospitalReservation.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // 날짜순으로 정렬 (최신 순)
        reservationsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // ✅ 기존 예약을 캘린더에 동기화 (앱 시작 시 1회 실행)
        await _syncExistingReservationsToCalendar(reservationsList);

        return reservationsList;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('예약 정보 로드 실패: $e');
      }
      return [];
    }
  }

  /// 기존 예약들을 캘린더에 동기화 (최초 1회 실행)
  Future<void> _syncExistingReservationsToCalendar(
    List<HospitalReservation> reservations,
  ) async {
    try {
      // 캘린더에 이미 동기화되었는지 확인하는 플래그
      final syncedFlag = await SecureStorageService.getString(
        'reservations_synced_to_calendar',
      );

      if (syncedFlag == 'true') {
        // 이미 동기화됨
        return;
      }

      LoggerService.debug('📅 기존 예약을 캘린더에 동기화 중...');
      for (final reservation in reservations) {
        await _syncToCalendar(reservation);
      }

      // 동기화 완료 플래그 저장
      await SecureStorageService.setString(
        'reservations_synced_to_calendar',
        'true',
      );
      LoggerService.debug('✅ 모든 예약이 캘린더에 동기화되었습니다.');
    } catch (e) {
      LoggerService.debug('❌ 기존 예약 동기화 실패: $e');
    }
  }

  /// 새 예약 추가
  Future<void> addReservation(HospitalReservation reservation) async {
    final currentReservations = await future;
    final updatedReservations = [...currentReservations, reservation];

    await _saveToStorage(updatedReservations);
    state = AsyncValue.data(updatedReservations);

    // ✅ 캘린더 이벤트도 함께 생성
    await _syncToCalendar(reservation);
  }

  /// 예약 상태 업데이트
  Future<void> updateReservationStatus(
    String reservationId,
    ReservationStatus newStatus,
  ) async {
    final currentReservations = await future;
    final updatedReservations = currentReservations.map((reservation) {
      if (reservation.id == reservationId) {
        return reservation.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
      return reservation;
    }).toList();

    await _saveToStorage(updatedReservations);
    state = AsyncValue.data(updatedReservations);
  }

  /// 예약 삭제
  Future<void> removeReservation(String reservationId) async {
    final currentReservations = await future;
    final updatedReservations = currentReservations
        .where((reservation) => reservation.id != reservationId)
        .toList();

    await _saveToStorage(updatedReservations);
    state = AsyncValue.data(updatedReservations);

    // ✅ 캘린더 이벤트도 함께 삭제
    await _deleteFromCalendar(reservationId);
  }

  /// 특정 상태의 예약 목록 가져오기
  List<HospitalReservation> getReservationsByStatus(ReservationStatus status) {
    return state.maybeWhen(
      data: (reservations) =>
          reservations.where((r) => r.status == status).toList(),
      orElse: () => [],
    );
  }

  /// 특정 병원의 예약 목록 가져오기
  List<HospitalReservation> getReservationsByHospital(String hospitalId) {
    return state.maybeWhen(
      data: (reservations) =>
          reservations.where((r) => r.hospitalId == hospitalId).toList(),
      orElse: () => [],
    );
  }

  /// 스토리지에 저장
  Future<void> _saveToStorage(List<HospitalReservation> reservations) async {
    try {
      final reservationsJson = reservations.map((r) => r.toJson()).toList();
      final reservationsJsonString = jsonEncode(reservationsJson);
      await SecureStorageService.setString(storageKey, reservationsJsonString);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('예약 정보 저장 실패: $e');
      }
    }
  }

  /// 예약을 캘린더 이벤트로 변환하여 저장
  Future<void> _syncToCalendar(HospitalReservation reservation) async {
    try {
      // 예약 시간 파싱 (예: "09:00 - 10:00")
      final timeParts = reservation.timeSlot.split(' - ');
      final startTimeStr = timeParts.isNotEmpty ? timeParts[0] : '09:00';
      final endTimeStr = timeParts.length > 1 ? timeParts[1] : '10:00';

      // 시작 시간 생성
      final startHour = int.tryParse(startTimeStr.split(':')[0]) ?? 9;
      final startMinute = int.tryParse(startTimeStr.split(':')[1]) ?? 0;
      final startTime = DateTime(
        reservation.reservationDate.year,
        reservation.reservationDate.month,
        reservation.reservationDate.day,
        startHour,
        startMinute,
      );

      // 종료 시간 생성
      final endHour = int.tryParse(endTimeStr.split(':')[0]) ?? 10;
      final endMinute = int.tryParse(endTimeStr.split(':')[1]) ?? 0;
      final endTime = DateTime(
        reservation.reservationDate.year,
        reservation.reservationDate.month,
        reservation.reservationDate.day,
        endHour,
        endMinute,
      );

      // CalendarEventEntity 생성
      final calendarEvent = CalendarEventEntity(
        id: reservation.id, // 예약 ID와 동일하게 설정
        title: '${reservation.hospitalName} - ${reservation.purpose}',
        description:
            '予約者: ${reservation.reserverName}\nペット: ${reservation.petName}\n電話番号: ${reservation.phoneNumber}${reservation.symptoms != null ? '\n症状: ${reservation.symptoms}' : ''}',
        startTime: startTime,
        endTime: endTime,
        isAllDay: false,
        type: CalendarEventType.veterinary, // 병원 예약은 veterinary 타입
        petId: reservation.petId,
        petName: reservation.petName,
        location: reservation.hospitalName,
        hasAlarm: true, // 기본적으로 알람 활성화
        alarmSettings: const [
          AlarmSetting(
            minutesBefore: 1440, // 1일 전
            isEnabled: true,
          ),
          AlarmSetting(
            minutesBefore: 60, // 1시간 전
            isEnabled: true,
          ),
        ],
        createdAt: reservation.createdAt,
        updatedAt: reservation.updatedAt,
      );

      // CalendarEventService를 통해 저장
      await CalendarEventService.instance.saveCalendarEvent(calendarEvent);
      LoggerService.debug('✅ 예약이 캘린더에 동기화되었습니다: ${reservation.id}');
    } catch (e) {
      LoggerService.debug('❌ 캘린더 동기화 실패: $e');
      // 에러가 발생해도 예약 자체는 성공한 것으로 처리
    }
  }

  /// 캘린더에서 예약 이벤트 삭제
  Future<void> _deleteFromCalendar(String reservationId) async {
    try {
      await CalendarEventService.instance.deleteCalendarEvent(reservationId);
      LoggerService.debug('✅ 캘린더에서 예약이 삭제되었습니다: $reservationId');
    } catch (e) {
      LoggerService.debug('❌ 캘린더 삭제 실패: $e');
      // 에러가 발생해도 예약 삭제 자체는 성공한 것으로 처리
    }
  }
}

/// 예약 대기 상태 예약 목록
@riverpod
List<HospitalReservation> pendingReservations(Ref ref) {
  final reservations = ref.watch(reservationsProvider);
  return reservations.maybeWhen(
    data: (reservationList) => reservationList
        .where((r) => r.status == ReservationStatus.pending)
        .toList(),
    orElse: () => [],
  );
}

/// 예약 완료 상태 예약 목록
@riverpod
List<HospitalReservation> confirmedReservations(Ref ref) {
  final reservations = ref.watch(reservationsProvider);
  return reservations.maybeWhen(
    data: (reservationList) => reservationList
        .where((r) => r.status == ReservationStatus.confirmed)
        .toList(),
    orElse: () => [],
  );
}

/// 예약 취소 상태 예약 목록
@riverpod
List<HospitalReservation> cancelledReservations(Ref ref) {
  final reservations = ref.watch(reservationsProvider);
  return reservations.maybeWhen(
    data: (reservationList) => reservationList
        .where((r) => r.status == ReservationStatus.cancelled)
        .toList(),
    orElse: () => [],
  );
}
