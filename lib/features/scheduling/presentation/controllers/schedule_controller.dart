import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import '../../domain/usecases/manage_schedules_usecase.dart';

/// 스케줄 상태
class ScheduleState {
  final bool isLoading;
  final String? error;
  final List<ScheduleEntity> schedules;
  final ScheduleEntity? selectedSchedule;
  final DateTime selectedDate;
  final ScheduleType? selectedType;
  final ScheduleStatistics? statistics;

  const ScheduleState({
    this.isLoading = false,
    this.error,
    this.schedules = const [],
    this.selectedSchedule,
    required this.selectedDate,
    this.selectedType,
    this.statistics,
  });

  ScheduleState copyWith({
    bool? isLoading,
    String? error,
    List<ScheduleEntity>? schedules,
    ScheduleEntity? selectedSchedule,
    DateTime? selectedDate,
    ScheduleType? selectedType,
    ScheduleStatistics? statistics,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      schedules: schedules ?? this.schedules,
      selectedSchedule: selectedSchedule ?? this.selectedSchedule,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedType: selectedType ?? this.selectedType,
      statistics: statistics ?? this.statistics,
    );
  }
}

/// 스케줄 컨트롤러
class ScheduleController extends StateNotifier<ScheduleState> {
  final GetAllSchedulesUseCase _getAllSchedulesUseCase;
  final GetSchedulesByDateUseCase _getSchedulesByDateUseCase;
  final GetTodaySchedulesUseCase _getTodaySchedulesUseCase;
  final GetThisWeekSchedulesUseCase _getThisWeekSchedulesUseCase;
  final GetSchedulesByTypeUseCase _getSchedulesByTypeUseCase;
  final CreateScheduleUseCase _createScheduleUseCase;
  final UpdateScheduleUseCase _updateScheduleUseCase;
  final DeleteScheduleUseCase _deleteScheduleUseCase;
  final UpdateScheduleStatusUseCase _updateScheduleStatusUseCase;
  // final MarkScheduleAsCompletedUseCase _markScheduleAsCompletedUseCase; // 今後実装予定
  final CancelScheduleUseCase _cancelScheduleUseCase;

  ScheduleController({
    required GetAllSchedulesUseCase getAllSchedulesUseCase,
    required GetSchedulesByDateUseCase getSchedulesByDateUseCase,
    required GetTodaySchedulesUseCase getTodaySchedulesUseCase,
    required GetThisWeekSchedulesUseCase getThisWeekSchedulesUseCase,
    required GetSchedulesByTypeUseCase getSchedulesByTypeUseCase,
    required CreateScheduleUseCase createScheduleUseCase,
    required UpdateScheduleUseCase updateScheduleUseCase,
    required DeleteScheduleUseCase deleteScheduleUseCase,
    required UpdateScheduleStatusUseCase updateScheduleStatusUseCase,
    // required MarkScheduleAsCompletedUseCase markScheduleAsCompletedUseCase, // 今後実装予定
    required CancelScheduleUseCase cancelScheduleUseCase,
  }) : _getAllSchedulesUseCase = getAllSchedulesUseCase,
       _getSchedulesByDateUseCase = getSchedulesByDateUseCase,
       _getTodaySchedulesUseCase = getTodaySchedulesUseCase,
       _getThisWeekSchedulesUseCase = getThisWeekSchedulesUseCase,
       _getSchedulesByTypeUseCase = getSchedulesByTypeUseCase,
       _createScheduleUseCase = createScheduleUseCase,
       _updateScheduleUseCase = updateScheduleUseCase,
       _deleteScheduleUseCase = deleteScheduleUseCase,
       _updateScheduleStatusUseCase = updateScheduleStatusUseCase,
       // _markScheduleAsCompletedUseCase = markScheduleAsCompletedUseCase, // 今後実装予定
       _cancelScheduleUseCase = cancelScheduleUseCase,
       super(ScheduleState(selectedDate: DateTime.now()));

  /// 모든 스케줄 로드
  Future<void> loadAllSchedules() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final schedules = await _getAllSchedulesUseCase();
      state = state.copyWith(isLoading: false, schedules: schedules);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 특정 날짜의 스케줄 로드
  Future<void> loadSchedulesByDate(DateTime date) async {
    state = state.copyWith(isLoading: true, error: null, selectedDate: date);

    try {
      final schedules = await _getSchedulesByDateUseCase(date);
      state = state.copyWith(isLoading: false, schedules: schedules);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 오늘의 스케줄 로드
  Future<void> loadTodaySchedules() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final schedules = await _getTodaySchedulesUseCase();
      state = state.copyWith(
        isLoading: false,
        schedules: schedules,
        selectedDate: DateTime.now(),
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 이번 주 스케줄 로드
  Future<void> loadThisWeekSchedules() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final schedules = await _getThisWeekSchedulesUseCase();
      state = state.copyWith(isLoading: false, schedules: schedules);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 특정 타입의 스케줄 로드
  Future<void> loadSchedulesByType(ScheduleType type) async {
    state = state.copyWith(isLoading: true, error: null, selectedType: type);

    try {
      final schedules = await _getSchedulesByTypeUseCase(type);
      state = state.copyWith(isLoading: false, schedules: schedules);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 스케줄 생성
  Future<void> createSchedule(ScheduleEntity schedule) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdSchedule = await _createScheduleUseCase(schedule);
      final updatedSchedules = [...state.schedules, createdSchedule];
      state = state.copyWith(isLoading: false, schedules: updatedSchedules);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 스케줄 업데이트
  Future<void> updateSchedule(ScheduleEntity schedule) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSchedule = await _updateScheduleUseCase(schedule);
      final updatedSchedules = state.schedules.map((s) {
        return s.id == updatedSchedule.id ? updatedSchedule : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        schedules: updatedSchedules,
        selectedSchedule: state.selectedSchedule?.id == updatedSchedule.id
            ? updatedSchedule
            : state.selectedSchedule,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteScheduleUseCase(id);
      final updatedSchedules = state.schedules
          .where((s) => s.id != id)
          .toList();
      state = state.copyWith(
        isLoading: false,
        schedules: updatedSchedules,
        selectedSchedule: state.selectedSchedule?.id == id
            ? null
            : state.selectedSchedule,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 스케줄 상태 업데이트
  Future<void> updateScheduleStatus(String id, ScheduleStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSchedule = await _updateScheduleStatusUseCase(id, status);
      final updatedSchedules = state.schedules.map((s) {
        return s.id == updatedSchedule.id ? updatedSchedule : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        schedules: updatedSchedules,
        selectedSchedule: state.selectedSchedule?.id == updatedSchedule.id
            ? updatedSchedule
            : state.selectedSchedule,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 스케줄 완료 처리
  Future<void> markScheduleAsCompleted(String id) async {
    await updateScheduleStatus(id, ScheduleStatus.completed);
  }

  /// 스케줄 취소 처리
  Future<void> cancelSchedule(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSchedule = await _cancelScheduleUseCase(id, reason);
      final updatedSchedules = state.schedules.map((s) {
        return s.id == updatedSchedule.id ? updatedSchedule : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        schedules: updatedSchedules,
        selectedSchedule: state.selectedSchedule?.id == updatedSchedule.id
            ? updatedSchedule
            : state.selectedSchedule,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  /// 스케줄 선택
  void selectSchedule(ScheduleEntity? schedule) {
    state = state.copyWith(selectedSchedule: schedule);
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 필터 초기화
  void clearFilters() {
    state = state.copyWith(selectedType: null);
  }
}
