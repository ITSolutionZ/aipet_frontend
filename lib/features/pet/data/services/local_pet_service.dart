import 'package:aipet_frontend/shared/services/local_database_service.dart';
import 'package:sqflite/sqflite.dart';

/// 펫 정보 로컬 스토리지 서비스
class LocalPetService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// 모든 펫 조회
  Future<List<Map<String, dynamic>>> getAllPets() async {
    try {
      print('🐾 LocalPetService.getAllPets: 시작');
      final db = await _dbService.database;
      final results = await db.query(
        'pets',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );
      print('🐾 LocalPetService.getAllPets: ${results.length}개 펫 조회 완료');
      return results;
    } catch (error, stackTrace) {
      print('❌ LocalPetService.getAllPets: 에러 발생 - $error');
      print('📍 StackTrace: $stackTrace');
      // 에러 발생 시 빈 리스트 반환
      return [];
    }
  }

  /// 특정 펫 조회
  Future<Map<String, dynamic>?> getPetById(String petId) async {
    try {
      print('🐾 LocalPetService.getPetById: $petId 조회 시작');
      final db = await _dbService.database;
      final results = await db.query(
        'pets',
        where: 'petId = ?',
        whereArgs: [petId],
      );
      final result = results.isNotEmpty ? results.first : null;
      print(
        '🐾 LocalPetService.getPetById: ${result != null ? "펫 발견" : "펫 없음"}',
      );
      return result;
    } catch (error, stackTrace) {
      print('❌ LocalPetService.getPetById: 에러 발생 - $error');
      print('📍 StackTrace: $stackTrace');
      // 에러 발생 시 null 반환
      return null;
    }
  }

  /// 펫 추가
  Future<String> addPet(Map<String, dynamic> petData) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    // 디버그: 원본 petData 전체 확인
    print('🔍 ===== LocalPetService.addPet 시작 =====');
    print('🔍 petData 전체: $petData');
    print('🔍 petData keys: ${petData.keys.toList()}');

    // additionalInfo에서 값 추출
    final additionalInfo =
        petData['additionalInfo'] as Map<String, dynamic>? ?? {};

    print('🔍 additionalInfo: $additionalInfo');
    print('🔍 additionalInfo type: ${additionalInfo.runtimeType}');
    print('🔍 additionalInfo keys: ${additionalInfo.keys.toList()}');
    print(
      '🔍 registrationNumber from additionalInfo: ${additionalInfo['registrationNumber']}',
    );
    print(
      '🔍 guardianName from additionalInfo: ${additionalInfo['guardianName']}',
    );
    print(
      '🔍 institutionName from additionalInfo: ${additionalInfo['institutionName']}',
    );

    final insertData = {
      'petId': id,
      'name': petData['name'],
      'type': petData['type'],
      'breed': petData['breed'],
      'age': petData['age'],
      'weight': petData['weight'],
      'gender': petData['gender'],
      'birth_date': petData['birthDate']?.toString(),
      'profile_image': petData['imagePath'] ?? petData['profileImage'],
      'registration_number': additionalInfo['registrationNumber'],
      'guardian_name': additionalInfo['guardianName'],
      'institution_name': additionalInfo['institutionName'],
      'is_neutered':
          (additionalInfo['isNeutered'] == true || petData['neutered'] == true)
          ? 1
          : 0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
      'data': petData.toString(),
    };

    print('💾 LocalPetService.addPet - 저장할 데이터:');
    print('   - registration_number: ${insertData['registration_number']}');
    print('   - guardian_name: ${insertData['guardian_name']}');
    print('   - institution_name: ${insertData['institution_name']}');

    await db.insert(
      'pets',
      insertData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 저장 후 확인
    final saved = await getPetById(id);
    print('✅ LocalPetService.addPet - 저장 후 조회:');
    print('   - registration_number: ${saved?['registration_number']}');
    print('   - guardian_name: ${saved?['guardian_name']}');
    print('   - institution_name: ${saved?['institution_name']}');

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
