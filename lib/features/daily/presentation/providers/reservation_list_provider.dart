import 'package:aipet_frontend/shared/testing/mock_data/features/facility/reservation_mock_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class ReservationListNotifier extends StateNotifier<ReservationListState> {
  ReservationListNotifier() : super(const ReservationListState());

  /// 예약 목록 로드
  Future<void> loadReservations({String? petId, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      List<Map<String, dynamic>> reservations;

      if (petId != null && status != null) {
        // 펫 ID와 상태 모두 필터링
        reservations = ReservationMockData.getReservationsByPetAndStatus(
          petId,
          status,
        );
      } else if (petId != null) {
        // 펫 ID만 필터링
        reservations = ReservationMockData.getReservationsByPet(petId);
      } else if (status != null) {
        // 상태만 필터링
        reservations = ReservationMockData.getReservationsByStatus(status);
      } else {
        // 전체 예약 목록
        reservations = ReservationMockData.getMockReservations();
      }

      state = state.copyWith(reservations: reservations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 예약 취소
  Future<void> cancelReservation(
    String reservationId, {
    String? reason,
    String? detail,
  }) async {
    try {
      // Mock 데이터에서 예약 상태 업데이트
      final updatedReservations = state.reservations.map((reservation) {
        if (reservation['id'] == reservationId) {
          return {
            ...reservation,
            'status': ReservationMockData.cancelled,
            'updatedAt': DateTime.now(),
            'cancelledAt': DateTime.now(),
            'cancellationReason': reason ?? '사용자 취소',
            'cancellationDetail': detail ?? '',
          };
        }
        return reservation;
      }).toList();

      state = state.copyWith(reservations: updatedReservations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 예약 확인
  Future<void> confirmReservation(String reservationId) async {
    try {
      // Mock 데이터에서 예약 상태 업데이트
      final updatedReservations = state.reservations.map((reservation) {
        if (reservation['id'] == reservationId) {
          return {
            ...reservation,
            'status': ReservationMockData.confirmed,
            'updatedAt': DateTime.now(),
          };
        }
        return reservation;
      }).toList();

      state = state.copyWith(reservations: updatedReservations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// 예약 목록 Provider
final reservationListProvider =
    StateNotifierProvider<ReservationListNotifier, ReservationListState>(
      (ref) => ReservationListNotifier(),
    );
