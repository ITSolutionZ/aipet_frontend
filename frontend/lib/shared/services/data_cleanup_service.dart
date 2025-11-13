import 'package:aipet_frontend/shared/services/local_database_service.dart';
import 'package:flutter/foundation.dart';

/// 데이터 정리 서비스
///
/// 깨진 데이터나 중복 데이터를 정리하는 기능을 제공합니다.
class DataCleanupService {
  static final DataCleanupService _instance = DataCleanupService._internal();
  factory DataCleanupService() => _instance;
  DataCleanupService._internal();

  /// 깨진 펫 이름을 수정
  Future<bool> fixCorruptedPetNames() async {
    try {
      final database = await LocalDatabaseService.instance.database;

      // 깨진 문자 패턴 (한글 자음/모음만 있는 경우)
      final corruptedPattern = RegExp(r'^[ㄱ-ㅎㅏ-ㅣ]+$');

      // 깨진 펫 이름을 가진 레코드 조회
      final corruptedPets = await database.query(
        'pets',
        where: 'name REGEXP ?',
        whereArgs: [corruptedPattern.pattern],
      );

      debugPrint('🔍 Found ${corruptedPets.length} corrupted pet names');

      for (final pet in corruptedPets) {
        final petId = pet['petId'] as String;
        final newName = 'ペット${petId.substring(petId.length - 4)}';

        // 펫 이름 업데이트
        await database.update(
          'pets',
          {'name': newName},
          where: 'petId = ?',
          whereArgs: [petId],
        );

        debugPrint('✅ Fixed pet name: ${pet['name']} -> $newName');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error fixing corrupted pet names: $e');
      return false;
    }
  }

  /// 중복된 펫 데이터 정리
  Future<bool> cleanupDuplicatePetData() async {
    try {
      final database = await LocalDatabaseService.instance.database;

      // 중복된 펫 ID 찾기
      final duplicatePets = await database.rawQuery('''
        SELECT petId, COUNT(*) as count
        FROM pets
        GROUP BY petId
        HAVING COUNT(*) > 1
      ''');

      debugPrint('🔍 Found ${duplicatePets.length} duplicate pet IDs');

      for (final duplicate in duplicatePets) {
        final petId = duplicate['petId'] as String;

        // 중복된 레코드 중 가장 최근 것만 남기고 삭제
        await database.rawDelete(
          '''
          DELETE FROM pets
          WHERE petId = ? AND rowid NOT IN (
            SELECT MAX(rowid) FROM pets WHERE petId = ?
          )
        ''',
          [petId, petId],
        );

        debugPrint('✅ Cleaned up duplicate pet: $petId');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error cleaning up duplicate pets: $e');
      return false;
    }
  }

  /// 모든 데이터 정리 작업 실행
  Future<bool> performFullCleanup() async {
    try {
      debugPrint('🧹 Starting full data cleanup...');

      final fixNames = await fixCorruptedPetNames();
      final cleanupDuplicates = await cleanupDuplicatePetData();

      if (fixNames && cleanupDuplicates) {
        debugPrint('✅ Full data cleanup completed successfully');
        return true;
      } else {
        debugPrint('⚠️ Some cleanup operations failed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error during full cleanup: $e');
      return false;
    }
  }
}
