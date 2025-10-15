import 'package:sqflite/sqflite.dart';

import 'local_database_service.dart';

/// 펫 정보 로컬 스토리지 서비스
class LocalPetService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// 모든 펫 조회
  Future<List<Map<String, dynamic>>> getAllPets() async {
    final db = await _dbService.database;
    return db.query(
      'pets',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
  }

  /// 특정 펫 조회
  Future<Map<String, dynamic>?> getPetById(String petId) async {
    final db = await _dbService.database;
    final results = await db.query(
      'pets',
      where: 'petId = ?',
      whereArgs: [petId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// 펫 추가
  Future<String> addPet(Map<String, dynamic> petData) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await db.insert('pets', {
      'petId': id,
      'name': petData['name'],
      'type': petData['type'],
      'breed': petData['breed'],
      'age': petData['age'],
      'weight': petData['weight'],
      'gender': petData['gender'],
      'birth_date': petData['birthDate']?.toString(),
      'profile_image': petData['profileImage'],
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
      'data': petData.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  /// 펫 정보 업데이트
  Future<bool> updatePet(String petId, Map<String, dynamic> petData) async {
    final db = await _dbService.database;
    final count = await db.update(
      'pets',
      {...petData, 'updated_at': DateTime.now().toIso8601String()},
      where: 'petId = ?',
      whereArgs: [petId],
    );
    return count > 0;
  }

  /// 펫 삭제 (소프트 삭제)
  Future<bool> deletePet(String petId) async {
    final db = await _dbService.database;
    final count = await db.update(
      'pets',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'petId = ?',
      whereArgs: [petId],
    );
    return count > 0;
  }

  /// 급식 기록 추가
  Future<String> addFeedingRecord(Map<String, dynamic> record) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('feeding_records', {
      'id': id,
      'pet_id': record['petId'],
      'amount': record['amount'],
      'food_type': record['foodType'],
      'feeding_time':
          record['feedingTime']?.toString() ?? DateTime.now().toIso8601String(),
      'notes': record['notes'],
      'created_at': DateTime.now().toIso8601String(),
    });
    return id;
  }

  /// 펫의 급식 기록 조회
  Future<List<Map<String, dynamic>>> getFeedingRecords(
    String petId, {
    int limit = 50,
  }) async {
    final db = await _dbService.database;
    return db.query(
      'feeding_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'feeding_time DESC',
      limit: limit,
    );
  }

  /// 산책 기록 추가
  Future<String> addWalkRecord(Map<String, dynamic> record) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('walk_records', {
      'id': id,
      'pet_id': record['petId'],
      'duration': record['duration'],
      'distance': record['distance'],
      'route': record['route'],
      'start_time':
          record['startTime']?.toString() ?? DateTime.now().toIso8601String(),
      'end_time':
          record['endTime']?.toString() ?? DateTime.now().toIso8601String(),
      'notes': record['notes'],
      'created_at': DateTime.now().toIso8601String(),
    });
    return id;
  }

  /// 펫의 산책 기록 조회
  Future<List<Map<String, dynamic>>> getWalkRecords(
    String petId, {
    int limit = 50,
  }) async {
    final db = await _dbService.database;
    return db.query(
      'walk_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'start_time DESC',
      limit: limit,
    );
  }

  /// 건강 기록 추가
  Future<String> addHealthRecord(Map<String, dynamic> record) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('health_records', {
      'id': id,
      'pet_id': record['petId'],
      'record_type': record['recordType'],
      'title': record['title'],
      'description': record['description'],
      'date': record['date']?.toString() ?? DateTime.now().toIso8601String(),
      'vet_name': record['vetName'],
      'hospital_name': record['hospitalName'],
      'attachments': record['attachments'],
      'created_at': DateTime.now().toIso8601String(),
    });
    return id;
  }

  /// 펫의 건강 기록 조회
  Future<List<Map<String, dynamic>>> getHealthRecords(
    String petId, {
    String? recordType,
  }) async {
    final db = await _dbService.database;
    if (recordType != null) {
      return db.query(
        'health_records',
        where: 'pet_id = ? AND record_type = ?',
        whereArgs: [petId, recordType],
        orderBy: 'date DESC',
      );
    } else {
      return db.query(
        'health_records',
        where: 'pet_id = ?',
        whereArgs: [petId],
        orderBy: 'date DESC',
      );
    }
  }

  /// 활동 기록 추가 또는 업데이트
  Future<String> upsertActivity(Map<String, dynamic> activity) async {
    final db = await _dbService.database;
    final id =
        activity['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await db.insert('activities', {
      'id': id,
      'pet_id': activity['petId'],
      'activity_type': activity['activityType'],
      'name': activity['name'],
      'progress': activity['progress'] ?? 0,
      'is_completed': activity['isCompleted'] == true ? 1 : 0,
      'metadata': activity['metadata']?.toString(),
      'created_at': activity['createdAt'] ?? now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  /// 펫의 활동 기록 조회
  Future<List<Map<String, dynamic>>> getActivities(
    String petId, {
    String? activityType,
  }) async {
    final db = await _dbService.database;
    if (activityType != null) {
      return db.query(
        'activities',
        where: 'pet_id = ? AND activity_type = ?',
        whereArgs: [petId, activityType],
        orderBy: 'created_at DESC',
      );
    } else {
      return db.query(
        'activities',
        where: 'pet_id = ?',
        whereArgs: [petId],
        orderBy: 'created_at DESC',
      );
    }
  }
}
