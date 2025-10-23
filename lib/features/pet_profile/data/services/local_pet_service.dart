import 'dart:convert';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import 'package:aipet_frontend/shared/services/local_database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// 펫 정보 로컬 스토리지 서비스
class LocalPetService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// 모든 펫 조회
  Future<List<Map<String, dynamic>>> getAllPets() async {
    try {
      LoggerService.debug('🐾 LocalPetService.getAllPets: 시작');
      final db = await _dbService.database;
      final results = await db.query(
        'pets',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );
      LoggerService.debug('🐾 LocalPetService.getAllPets: ${results.length}개 펫 조회 완료');

      // additionalInfo를 JSON 문자열에서 Map으로 파싱
      return results.map((pet) => _parsePetData(pet)).toList();
    } catch (error, stackTrace) {
      LoggerService.debug('❌ LocalPetService.getAllPets: 에러 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');
      // 에러 발생 시 빈 리스트 반환
      return [];
    }
  }

  /// 펫 데이터 파싱 - additionalInfo를 JSON에서 Map으로 변환
  Map<String, dynamic> _parsePetData(Map<String, dynamic> petData) {
    // read-onlyマップを変更可能なマップにコピー
    final parsedData = Map<String, dynamic>.from(petData);

    try {
      if (parsedData['additionalInfo'] is String) {
        final additionalInfoJson = parsedData['additionalInfo'] as String;
        LoggerService.debug('📖 Parsing additionalInfo from JSON: $additionalInfoJson');
        parsedData['additionalInfo'] = jsonDecode(additionalInfoJson);
        LoggerService.debug('✅ additionalInfo parsed: ${parsedData['additionalInfo']}');
      }
    } catch (e) {
      LoggerService.debug('⚠️  additionalInfo 파싱 실패: $e');
      LoggerService.debug('⚠️  원본 데이터: ${parsedData['additionalInfo']}');
      // 파싱 실패 시 빈 Map 사용
      parsedData['additionalInfo'] = {};
    }
    return parsedData;
  }

  /// 특정 펫 조회
  Future<Map<String, dynamic>?> getPetById(String petId) async {
    try {
      LoggerService.debug('🐾 LocalPetService.getPetById: $petId 조회 시작');
      final db = await _dbService.database;
      final results = await db.query(
        'pets',
        where: 'petId = ?',
        whereArgs: [petId],
      );
      var result = results.isNotEmpty ? results.first : null;
      LoggerService.debug(
        '🐾 LocalPetService.getPetById: ${result != null ? "펫 발견" : "펫 없음"}',
      );
      // additionalInfo 파싱
      if (result != null) {
        result = _parsePetData(result);
      }
      return result;
    } catch (error, stackTrace) {
      LoggerService.debug('❌ LocalPetService.getPetById: 에러 발생 - $error');
      LoggerService.debug('📍 StackTrace: $stackTrace');
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
    LoggerService.debug('🔍 ===== LocalPetService.addPet 시작 =====');
    LoggerService.debug('🔍 petData 전체: $petData');
    LoggerService.debug('🔍 petData keys: ${petData.keys.toList()}');

    // additionalInfo에서 값 추출
    final additionalInfo =
        petData['additionalInfo'] as Map<String, dynamic>? ?? {};

    LoggerService.debug('🔍 additionalInfo: $additionalInfo');
    LoggerService.debug('🔍 additionalInfo type: ${additionalInfo.runtimeType}');
    LoggerService.debug('🔍 additionalInfo keys: ${additionalInfo.keys.toList()}');
    LoggerService.debug(
      '🔍 registrationNumber from additionalInfo: ${additionalInfo['registrationNumber']}',
    );
    LoggerService.debug(
      '🔍 guardianName from additionalInfo: ${additionalInfo['guardianName']}',
    );
    LoggerService.debug(
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
      'pet_status': petData['petStatus']?.toString() ?? 'active',
      'created_at': now,
      'updated_at': now,
      // ✅ additionalInfo 전체를 JSON 문자열로 저장
      'additionalInfo': jsonEncode(
        _sanitizeAdditionalInfoForDb(additionalInfo),
      ),
    };

    LoggerService.debug('💾 LocalPetService.addPet - 저장할 데이터:');
    LoggerService.debug(
      '   - registration_number: ${insertData['registration_number']}',
    );
    LoggerService.debug('   - guardian_name: ${insertData['guardian_name']}');
    LoggerService.debug('   - institution_name: ${insertData['institution_name']}');

    await db.insert(
      'pets',
      insertData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 저장 후 확인
    final saved = await getPetById(id);
    LoggerService.debug('✅ LocalPetService.addPet - 저장 후 조회:');
    LoggerService.debug('   - registration_number: ${saved?['registration_number']}');
    LoggerService.debug('   - guardian_name: ${saved?['guardian_name']}');
    LoggerService.debug('   - institution_name: ${saved?['institution_name']}');

    return id;
  }

  /// 펫 정보 업데이트
  Future<bool> updatePet(String petId, Map<String, dynamic> petData) async {
    try {
      LoggerService.debug('🐾 LocalPetService.updatePet: $petId 업데이트 시작');
      LoggerService.debug('🔍 petData keys: ${petData.keys.toList()}');
      LoggerService.debug(
        '🔍 additionalInfo type: ${petData['additionalInfo']?.runtimeType}',
      );

      final db = await _dbService.database;

      // additionalInfo에서 값 추출
      final additionalInfo =
          petData['additionalInfo'] as Map<String, dynamic>? ?? {};

      // SQLite에 저장할 데이터 준비
      final updateData = {
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
            (additionalInfo['isNeutered'] == true ||
                petData['neutered'] == true)
            ? 1
            : 0,
        'pet_status': petData['petStatus']?.toString() ?? 'active',
        'updated_at': DateTime.now().toIso8601String(),
        // ✅ additionalInfo 전체를 JSON 문자열로 저장
        'additionalInfo': jsonEncode(
          _sanitizeAdditionalInfoForDb(additionalInfo),
        ),
      };

      LoggerService.debug('💾 LocalPetService.updatePet - 저장할 데이터:');
      LoggerService.debug(
        '   - registration_number: ${updateData['registration_number']}',
      );
      LoggerService.debug('   - guardian_name: ${updateData['guardian_name']}');
      LoggerService.debug('   - institution_name: ${updateData['institution_name']}');
      LoggerService.debug('   - additionalInfo (JSON): ${updateData['additionalInfo']}');

      final count = await db.update(
        'pets',
        updateData,
        where: 'petId = ?',
        whereArgs: [petId],
      );

      LoggerService.debug('✅ LocalPetService.updatePet: $count개 행 업데이트됨');
      return count > 0;
    } catch (e, stackTrace) {
      LoggerService.debug('❌ LocalPetService.updatePet: 에러 발생 - $e');
      LoggerService.debug('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// additionalInfo를 데이터베이스에 저장 가능한 형태로 정제
  Map<String, dynamic> _sanitizeAdditionalInfoForDb(
    Map<String, dynamic> additionalInfo,
  ) {
    if (additionalInfo.isEmpty) {
      return {};
    }

    final result = <String, dynamic>{};

    additionalInfo.forEach((key, value) {
      try {
        // List 타입 필드 처리
        if (value is List) {
          // List<String>으로 변환
          final sanitizedList = List<String>.from(value.whereType<String>());
          if (sanitizedList.isNotEmpty) {
            result[key] = sanitizedList;
            LoggerService.debug('💾 [$key] List saved: ${sanitizedList.length} items');
          }
        }
        // String 타입 필드 처리
        else if (value is String) {
          result[key] = value;
        }
        // num 타입 필드 처리
        else if (value is num) {
          result[key] = value;
        }
        // bool 타입 필드 처리
        else if (value is bool) {
          result[key] = value;
        }
        // null은 제외
        else if (value != null) {
          result[key] = value.toString();
          LoggerService.debug('⚠️  [$key] 알 수 없는 타입 변환됨: ${value.runtimeType}');
        }
      } catch (e) {
        LoggerService.debug('⚠️  [$key] 필드 정제 실패: $e');
      }
    });

    return result;
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
