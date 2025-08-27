import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

/// 예약 컨트롤러
class BookingController extends StateNotifier<BookingState> {
  BookingController({required String facilityId})
    : super(BookingState(facilityId: facilityId)) {
    _loadFacilityData();
  }

  /// 시설 데이터 로드
  void _loadFacilityData() {
    final facility = MockDataService.getMockFacilityById(state.facilityId);
    state = state.copyWith(facility: facility);
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    // selectedDate는 초기화 리스트에서만 설정되므로 직접 state 수정
    state = BookingState(
      facilityId: state.facilityId,
      facility: state.facility,
      selectedTime: state.selectedTime,
      selectedServices: state.selectedServices,
      services: state.services,
      isBookingConfirmed: state.isBookingConfirmed,
      error: state.error,
    )..selectedDate = date;
  }

  /// 시간 선택
  void selectTime(String time) {
    state = state.copyWith(selectedTime: time);
  }

  /// 서비스 토글
  void toggleService(int index) {
    final newServices = List<Map<String, dynamic>>.from(state.services);
    newServices[index]['selected'] = !newServices[index]['selected'];

    final newSelectedServices = <String>[];
    for (int i = 0; i < newServices.length; i++) {
      if (newServices[i]['selected']) {
        newSelectedServices.add(newServices[i]['name']);
      }
    }

    state = state.copyWith(
      services: newServices,
      selectedServices: newSelectedServices,
    );
  }

  /// 예약 확인
  void confirmBooking() {
    if (state.selectedServices.isEmpty) {
      state = state.copyWith(error: 'サービスを選択してください。');
      return;
    }

    // 예약 로직 처리
    state = state.copyWith(isBookingConfirmed: true);
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 예약 상태
class BookingState {
  final String facilityId;
  final Facility? facility;
  late DateTime selectedDate;
  final String selectedTime;
  final List<String> selectedServices;
  final List<Map<String, dynamic>> services;
  final bool isBookingConfirmed;
  final String? error;

  BookingState({
    required this.facilityId,
    this.facility,
    this.selectedTime = '11:00',
    this.selectedServices = const ['Haircut'],
    this.services = const [
      {'name': 'カット', 'price': '￥30', 'selected': true},
      {'name': 'バス', 'price': '￥20', 'selected': false},
      {'name': '爪切り', 'price': '￥20', 'selected': false},
    ],
    this.isBookingConfirmed = false,
    this.error,
  }) : selectedDate = DateTime.now().add(const Duration(days: 1));

  BookingState copyWith({
    String? facilityId,
    Facility? facility,
    String? selectedTime,
    List<String>? selectedServices,
    List<Map<String, dynamic>>? services,
    bool? isBookingConfirmed,
    String? error,
  }) {
    return BookingState(
      facilityId: facilityId ?? this.facilityId,
      facility: facility ?? this.facility,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedServices: selectedServices ?? this.selectedServices,
      services: services ?? this.services,
      isBookingConfirmed: isBookingConfirmed ?? this.isBookingConfirmed,
      error: error ?? this.error,
    );
  }
}

/// 컨트롤러 프로바이더
final bookingControllerProvider =
    StateNotifierProvider.family<BookingController, BookingState, String>((
      ref,
      facilityId,
    ) {
      return BookingController(facilityId: facilityId);
    });
