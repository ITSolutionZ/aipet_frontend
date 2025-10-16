import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 데이터베이스 시각화 서비스
///
/// SQLite 데이터베이스의 구조와 데이터를 시각화하기 위한 서비스
class DatabaseVisualizationService {
  static DatabaseVisualizationService? _instance;
  static DatabaseVisualizationService get instance {
    _instance ??= DatabaseVisualizationService._();
    return _instance!;
  }

  DatabaseVisualizationService._();

  /// 데이터베이스 경로 가져오기
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'aipet_local.db');
  }

  /// 데이터베이스 파일 존재 여부 확인
  Future<bool> databaseExists() async {
    final path = await getDatabasePath();
    return File(path).exists();
  }

  /// 데이터베이스 파일 크기 가져오기
  Future<int> getDatabaseSize() async {
    final path = await getDatabasePath();
    final file = File(path);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// 모든 테이블 목록 가져오기
  Future<List<String>> getAllTables() async {
    final db = await _getDatabase();
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// 테이블 구조 정보 가져오기
  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    final db = await _getDatabase();
    return db.rawQuery('PRAGMA table_info($tableName)');
  }

  /// 테이블 데이터 개수 가져오기
  Future<int> getTableRowCount(String tableName) async {
    final db = await _getDatabase();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return result.first['count'] as int;
  }

  /// 테이블 데이터 샘플 가져오기 (최대 10개)
  Future<List<Map<String, dynamic>>> getTableSample(
    String tableName, {
    int limit = 10,
  }) async {
    final db = await _getDatabase();
    return db.query(tableName, limit: limit);
  }

  /// 데이터베이스 통계 정보 가져오기
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final tables = await getAllTables();
    final stats = <String, dynamic>{};

    for (final table in tables) {
      final rowCount = await getTableRowCount(table);
      final schema = await getTableSchema(table);

      stats[table] = {
        'rowCount': rowCount,
        'columns': schema.length,
        'schema': schema,
      };
    }

    return stats;
  }

  /// 펫 관련 데이터 통계
  Future<Map<String, dynamic>> getPetDataStats() async {
    final db = await _getDatabase();

    // 펫 수
    final petCount = await db.rawQuery('SELECT COUNT(*) as count FROM pets');
    final totalPets = petCount.first['count'] as int;

    // 활성 펫 수
    final activePetCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pets WHERE is_active = 1',
    );
    final activePets = activePetCount.first['count'] as int;

    // 펫 타입별 통계
    final petTypes = await db.rawQuery('''
      SELECT type, COUNT(*) as count
      FROM pets
      WHERE is_active = 1
      GROUP BY type
    ''');

    // 급식 기록 수
    final feedingCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM feeding_records',
    );
    final totalFeedings = feedingCount.first['count'] as int;

    // 산책 기록 수
    final walkCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM walk_records',
    );
    final totalWalks = walkCount.first['count'] as int;

    // 건강 기록 수
    final healthCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM health_records',
    );
    final totalHealthRecords = healthCount.first['count'] as int;

    // AI 채팅 수
    final chatCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ai_chats',
    );
    final totalChats = chatCount.first['count'] as int;

    return {
      'totalPets': totalPets,
      'activePets': activePets,
      'petTypes': petTypes,
      'totalFeedings': totalFeedings,
      'totalWalks': totalWalks,
      'totalHealthRecords': totalHealthRecords,
      'totalChats': totalChats,
    };
  }

  /// 최근 활동 데이터 가져오기
  Future<List<Map<String, dynamic>>> getRecentActivities({
    int limit = 20,
  }) async {
    final db = await _getDatabase();

    // 최근 급식 기록
    final recentFeedings = await db.query(
      'feeding_records',
      orderBy: 'created_at DESC',
      limit: limit ~/ 4,
    );

    // 최근 산책 기록
    final recentWalks = await db.query(
      'walk_records',
      orderBy: 'created_at DESC',
      limit: limit ~/ 4,
    );

    // 최근 건강 기록
    final recentHealth = await db.query(
      'health_records',
      orderBy: 'created_at DESC',
      limit: limit ~/ 4,
    );

    // 최근 AI 채팅
    final recentChats = await db.query(
      'ai_chats',
      orderBy: 'timestamp DESC',
      limit: limit ~/ 4,
    );

    return [
      ...recentFeedings.map((e) => {...e, 'type': 'feeding'}),
      ...recentWalks.map((e) => {...e, 'type': 'walk'}),
      ...recentHealth.map((e) => {...e, 'type': 'health'}),
      ...recentChats.map((e) => {...e, 'type': 'chat'}),
    ]..sort((a, b) {
      final aTime = a['created_at'] ?? a['timestamp'] ?? '';
      final bTime = b['created_at'] ?? b['timestamp'] ?? '';
      return bTime.compareTo(aTime);
    });
  }

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> _getDatabase() async {
    final path = await getDatabasePath();
    return openDatabase(path);
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    // 필요시 데이터베이스 연결 정리
  }
}
