import 'dart:convert';

import 'package:aipet_frontend/features/daily/data/services/reservation_local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reservation_list_provider.g.dart';

/// 예약 목록 상태 관리
class ReservationListState {
  final List<Map<String, dynamic>> reservations;
  final bool isLoading;
  final String? error;

  const ReservationListState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
  });

  ReservationListState copyWith({
    List<Map<String, dynamic>>? reservations,
    bool? isLoading,
    String? error,
  }) {
    return ReservationListState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 예약 목록 Notifier
@riverpod
class ReservationListNotifier extends _$ReservationListNotifier {
  @override
  ReservationListState build() {
    return const ReservationListState();
  }

  /// 예약 목록 로드 (로컬 저장소)
  Future<void> loadReservations({String? petId, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<Map<String, dynamic>> reservations;

      if (petId != null && status != null) {
        // 펫 ID와 상태 모두 필터링
        reservations =
            await ReservationLocalStorageService.getReservationsByPetAndStatus(
              petId,
              status,
            );
      } else if (petId != null) {
        // 펫 ID만 필터링
        reservations =
            await ReservationLocalStorageService.getReservationsByPet(petId);
      } else if (status != null) {
        // 상태만 필터링
        reservations =
            await ReservationLocalStorageService.getReservationsByStatus(
              status,
            );
      } else {
        // 전체 예약 목록
        reservations = await ReservationLocalStorageService.getReservations();
      }

      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 예약 취소 (로컬 저장소)
  Future<void> cancelReservation(
    String reservationId, {
    String? reason,
    String? detail,
  }) async {
    try {
      // 로컬 저장소에서 예약 상태 업데이트
      final allReservations =
          await ReservationLocalStorageService.getReservations();
      final updatedReservations = allReservations.map((reservation) {
        if (reservation['id'] == reservationId) {
          return {
            ...reservation,
            'status': ReservationLocalStorageService.cancelled,
            'updatedAt': DateTime.now(),
            'cancelledAt': DateTime.now(),
            'cancellationReason': reason ?? 'ユーザーキャンセル',
            'cancellationDetail': detail ?? '',
          };
        }
        return reservation;
      }).toList();

      // 로컬 저장소에 저장
      // ✅ ReservationLocalStorageService 사용
      final jsonString = jsonEncode(
        updatedReservations.map((r) {
          final map = Map<String, dynamic>.from(r);
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
            map['cancelledAt'] = (map['cancelledAt'] as DateTime)
                .toIso8601String();
          }
          return map;
        }).toList(),
      );
      await prefs.setString('reservations', jsonString);

      state = state.copyWith(reservations: updatedReservations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 예약 확인 (로컬 저장소)
  Future<void> confirmReservation(String reservationId) async {
    try {
      // 로컬 저장소에서 예약 상태 업데이트
      final allReservations =
          await ReservationLocalStorageService.getReservations();
      final updatedReservations = allReservations.map((reservation) {
        if (reservation['id'] == reservationId) {
          return {
            ...reservation,
            'status': ReservationLocalStorageService.confirmed,
            'updatedAt': DateTime.now(),
          };
        }
        return reservation;
      }).toList();

      // 로컬 저장소에 저장
      // ✅ ReservationLocalStorageService 사용
      final jsonString = jsonEncode(
        updatedReservations.map((r) {
          final map = Map<String, dynamic>.from(r);
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
          return map;
        }).toList(),
      );
      await prefs.setString('reservations', jsonString);

      state = state.copyWith(reservations: updatedReservations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
