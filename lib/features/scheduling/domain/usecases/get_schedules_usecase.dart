import 'package:aipet_frontend/features/scheduling/domain/entities/schedule_entity.dart';
import 'package:aipet_frontend/features/scheduling/domain/repositories/schedule_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 모든 스케줄 가져오기 Use Case
class GetAllSchedulesUseCase {
  final ScheduleRepository repository;

  GetAllSchedulesUseCase(this.repository);

  Future<Result<List<ScheduleEntity>>> call() async {
    try {
      final schedules = await repository.getAllSchedules();
      return Result.success('スケジュール一覧を取得しました', schedules);
    } catch (error) {
      return Result.failure('스케줄 목록 로드 실패: $error');
    }
  }
}

/// 특정 펫의 스케줄 가져오기 Use Case
class GetSchedulesByPetIdUseCase {
  final ScheduleRepository repository;

  GetSchedulesByPetIdUseCase(this.repository);

  Future<Result<List<ScheduleEntity>>> call(String petId) async {
    try {
      final schedules = await repository.getSchedulesByPetId(petId);
      return Result.success('ペットのスケジュールを取得しました', schedules);
    } catch (error) {
      return Result.failure('펫의 스케줄 로드 실패: $error');
    }
  }
}

/// 특정 날짜의 스케줄 가져오기 Use Case
class GetSchedulesByDateUseCase {
  final ScheduleRepository repository;

  GetSchedulesByDateUseCase(this.repository);

  Future<List<ScheduleEntity>> call(DateTime date) async {
    return repository.getSchedulesByDate(date);
  }
}

/// 특정 기간의 스케줄 가져오기 Use Case
class GetSchedulesByDateRangeUseCase {
  final ScheduleRepository repository;

  GetSchedulesByDateRangeUseCase(this.repository);

  Future<List<ScheduleEntity>> call(DateTime startDate, DateTime endDate) async {
    return repository.getSchedulesByDateRange(startDate, endDate);
  }
}

/// 특정 스케줄 가져오기 Use Case
class GetScheduleByIdUseCase {
  final ScheduleRepository repository;

  GetScheduleByIdUseCase(this.repository);

  Future<ScheduleEntity?> call(String id) async {
    return repository.getScheduleById(id);
  }
}

/// 오늘의 스케줄 가져오기 Use Case
class GetTodaySchedulesUseCase {
  final ScheduleRepository repository;

  GetTodaySchedulesUseCase(this.repository);

  Future<List<ScheduleEntity>> call() async {
    return repository.getTodaySchedules();
  }
}

/// 내일의 스케줄 가져오기 Use Case
class GetTomorrowSchedulesUseCase {
  final ScheduleRepository repository;

  GetTomorrowSchedulesUseCase(this.repository);

  Future<List<ScheduleEntity>> call() async {
    return repository.getTomorrowSchedules();
  }
}

/// 이번 주 스케줄 가져오기 Use Case
class GetThisWeekSchedulesUseCase {
  final ScheduleRepository repository;

  GetThisWeekSchedulesUseCase(this.repository);

  Future<List<ScheduleEntity>> call() async {
    return repository.getThisWeekSchedules();
  }
}

/// 특정 타입의 스케줄 가져오기 Use Case
class GetSchedulesByTypeUseCase {
  final ScheduleRepository repository;

  GetSchedulesByTypeUseCase(this.repository);

  Future<List<ScheduleEntity>> call(ScheduleType type) async {
    return repository.getSchedulesByType(type);
  }
}

/// 시설 예약 스케줄 가져오기 Use Case
class GetFacilityBookingsUseCase {
  final ScheduleRepository repository;

  GetFacilityBookingsUseCase(this.repository);

  Future<List<ScheduleEntity>> call() async {
    return repository.getFacilityBookings();
  }
}

/// 스케줄 검색 Use Case
class SearchSchedulesUseCase {
  final ScheduleRepository repository;

  SearchSchedulesUseCase(this.repository);

  Future<List<ScheduleEntity>> call(String query) async {
    return repository.searchSchedules(query);
  }
}

/// 스케줄 통계 가져오기 Use Case
class GetScheduleStatisticsUseCase {
  final ScheduleRepository repository;

  GetScheduleStatisticsUseCase(this.repository);

  Future<ScheduleStatistics> call() async {
    return repository.getScheduleStatistics();
  }
}
