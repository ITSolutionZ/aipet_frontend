import 'local_database_service.dart';

/// 시설 로컬 스토리지 서비스
class LocalFacilityService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// 시설 즐겨찾기 추가
  Future<String> addFavorite(Map<String, dynamic> facility) async {
    final db = await _dbService.database;
    final id = facility['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert(
      'facility_favorites',
      {
        'id': id,
        'facility_id': facility['facilityId'] ?? id,
        'facility_name': facility['name'],
        'facility_type': facility['type'],
        'address': facility['address'],
        'phone': facility['phone'],
        'latitude': facility['latitude'],
        'longitude': facility['longitude'],
        'metadata': facility['metadata']?.toString(),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  /// 즐겨찾기 시설 조회
  Future<List<Map<String, dynamic>>> getFavorites({String? facilityType}) async {
    final db = await _dbService.database;
    if (facilityType != null) {
      return await db.query(
        'facility_favorites',
        where: 'facility_type = ?',
        whereArgs: [facilityType],
        orderBy: 'created_at DESC',
      );
    } else {
      return await db.query(
        'facility_favorites',
        orderBy: 'created_at DESC',
      );
    }
  }

  /// 즐겨찾기 삭제
  Future<bool> removeFavorite(String facilityId) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'facility_favorites',
      where: 'facility_id = ?',
      whereArgs: [facilityId],
    );
    return count > 0;
  }

  /// 즐겨찾기 여부 확인
  Future<bool> isFavorite(String facilityId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'facility_favorites',
      where: 'facility_id = ?',
      whereArgs: [facilityId],
    );
    return results.isNotEmpty;
  }

  /// 최근 검색 기록 저장
  Future<bool> saveRecentSearches(List<Map<String, dynamic>> searches) async {
    return await _dbService.saveListToPrefs('facility_recent_searches', searches);
  }

  /// 최근 검색 기록 로드
  Future<List<Map<String, dynamic>>?> loadRecentSearches() async {
    return await _dbService.loadListFromPrefs('facility_recent_searches');
  }

  /// 검색 필터 설정 저장
  Future<bool> saveSearchFilters(Map<String, dynamic> filters) async {
    return await _dbService.saveJsonToPrefs('facility_search_filters', filters);
  }

  /// 검색 필터 설정 로드
  Future<Map<String, dynamic>?> loadSearchFilters() async {
    return await _dbService.loadJsonFromPrefs('facility_search_filters');
  }

  /// 예약 정보 저장 (임시)
  Future<bool> saveReservationDraft(Map<String, dynamic> reservation) async {
    return await _dbService.saveJsonToPrefs('facility_reservation_draft', reservation);
  }

  /// 예약 정보 로드 (임시)
  Future<Map<String, dynamic>?> loadReservationDraft() async {
    return await _dbService.loadJsonFromPrefs('facility_reservation_draft');
  }

  /// 예약 정보 삭제 (임시)
  Future<bool> clearReservationDraft() async {
    final prefs = await _dbService.prefs;
    return prefs.remove('facility_reservation_draft');
  }
}