import 'package:table_calendar/table_calendar.dart';

import '../../../../../../../features/walk/domain/entities/walk_record_entity.dart';

/// 달력 데이터 처리 헬퍼
class WalkCalendarDataHelper {
  /// 특정 날짜의 산책 기록 가져오기 (최신순 정렬)
  static List<WalkRecordEntity> getEventsForDay(
    DateTime day,
    List<WalkRecordEntity> walkRecords,
  ) {
    final records = walkRecords.where((record) {
      return isSameDay(record.startTime, day);
    }).toList();

    // 최신순 정렬
    records.sort((a, b) => b.startTime.compareTo(a.startTime));

    return records;
  }

  /// 펫 필터 적용
  static List<WalkRecordEntity> applyPetFilter(
    List<WalkRecordEntity> records,
    String? selectedPetFilter,
  ) {
    if (selectedPetFilter == null) return records;

    return records.where((record) {
      return record.petId == selectedPetFilter;
    }).toList();
  }

  /// 오래된 기록 삭제 (6개월 이상)
  static List<WalkRecordEntity> filterRecentRecords(
    List<WalkRecordEntity> walkRecords,
  ) {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

    return walkRecords.where((record) {
      return record.startTime.isAfter(sixMonthsAgo);
    }).toList();
  }

  /// 삭제된 기록 개수 계산
  static int calculateDeletedCount(
    List<WalkRecordEntity> originalRecords,
    List<WalkRecordEntity> recentRecords,
  ) {
    return originalRecords.length - recentRecords.length;
  }
}
