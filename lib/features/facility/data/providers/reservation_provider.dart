import 'dart:convert';

import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
        return reservationsList;
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('예약 정보 로드 실패: $e');
      }
      return [];
    }
  }

  /// 새 예약 추가
  Future<void> addReservation(HospitalReservation reservation) async {
    final currentReservations = await future;
    final updatedReservations = [...currentReservations, reservation];

    await _saveToStorage(updatedReservations);
    state = AsyncValue.data(updatedReservations);
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
        debugPrint('예약 정보 저장 실패: $e');
      }
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
