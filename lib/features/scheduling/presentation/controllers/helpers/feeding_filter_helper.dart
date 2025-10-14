/// 급여 기록 필터링 헬퍼
class FeedingFilterHelper {
  /// 날짜 범위로 기록 필터링
  static List<dynamic> filterRecordsByDate(
    List<dynamic> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      final recordDate = record.fedTime;
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 급여 기록 검색
  static List<dynamic> searchRecords(List<dynamic> records, String query) {
    if (query.isEmpty) return records;

    final lowerQuery = query.toLowerCase();
    return records.where((record) {
      return record.petName.toLowerCase().contains(lowerQuery) ||
          record.foodType.toLowerCase().contains(lowerQuery) ||
          record.foodBrand.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
