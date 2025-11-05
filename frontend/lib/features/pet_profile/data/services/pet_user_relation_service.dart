import 'package:uuid/uuid.dart';


import '../../../../shared/shared.dart';
/// 펫-사용자 관계 관리 서비스
///
/// 복수 관리 유저 지원을 위한 서비스
class PetUserRelationService {
  static PetUserRelationService? _instance;
  static PetUserRelationService get instance {
    _instance ??= PetUserRelationService._();
    return _instance!;
  }

  PetUserRelationService._();

  final LocalDatabaseService _dbService = LocalDatabaseService.instance;
  final Uuid _uuid = const Uuid();

  /// 펫에 사용자 추가 (관리자 등록)
  Future<bool> addUserToPet({
    required String petId,
    required String userId,
    String role = 'owner',
    String? permissions,
  }) async {
    try {
      final db = await _dbService.database;

      // 중복 관계 확인
      final existing = await db.query(
        'pet_user_relations',
        where: 'petId = ? AND userId = ?',
        whereArgs: [petId, userId],
      );

      if (existing.isNotEmpty) {
        // 이미 존재하는 관계가 있으면 업데이트
        await db.update(
          'pet_user_relations',
          {
            'role': role,
            'permissions': permissions,
            'is_active': 1,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'petId = ? AND userId = ?',
          whereArgs: [petId, userId],
        );
        return true;
      }

      // 새로운 관계 생성
      await db.insert('pet_user_relations', {
        'id': _uuid.v4(),
        'petId': petId,
        'userId': userId,
        'role': role,
        'permissions': permissions,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      LoggerService.debug('펫-사용자 관계 추가 실패: $e');
      return false;
    }
  }

  /// 펫에서 사용자 제거
  Future<bool> removeUserFromPet({
    required String petId,
    required String userId,
  }) async {
    try {
      final db = await _dbService.database;

      await db.update(
        'pet_user_relations',
        {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'petId = ? AND userId = ?',
        whereArgs: [petId, userId],
      );

      return true;
    } catch (e) {
      LoggerService.debug('펫-사용자 관계 제거 실패: $e');
      return false;
    }
  }

  /// 펫의 모든 관리자 조회
  Future<List<Map<String, dynamic>>> getPetManagers(String petId) async {
    try {
      final db = await _dbService.database;

      final result = await db.rawQuery(
        '''
        SELECT
          pur.*,
          up.user_name,
          up.email,
          up.profile_image
        FROM pet_user_relations pur
        JOIN user_profiles up ON pur.userId = up.id
        WHERE pur.petId = ? AND pur.is_active = 1
        ORDER BY pur.created_at ASC
      ''',
        [petId],
      );

      return result;
    } catch (e) {
      LoggerService.debug('펫 관리자 조회 실패: $e');
      return [];
    }
  }

  /// 사용자가 관리하는 모든 펫 조회
  Future<List<Map<String, dynamic>>> getUserPets(String userId) async {
    try {
      final db = await _dbService.database;

      final result = await db.rawQuery(
        '''
        SELECT
          pur.*,
          p.name as pet_name,
          p.type as pet_type,
          p.breed as pet_breed,
          p.profile_image as pet_image
        FROM pet_user_relations pur
        JOIN pets p ON pur.petId = p.petId
        WHERE pur.userId = ? AND pur.is_active = 1 AND p.is_active = 1
        ORDER BY pur.created_at ASC
      ''',
        [userId],
      );

      return result;
    } catch (e) {
      LoggerService.debug('사용자 펫 조회 실패: $e');
      return [];
    }
  }

  /// 사용자의 펫 관리 권한 확인
  Future<bool> hasPetPermission({
    required String userId,
    required String petId,
    String? requiredRole,
  }) async {
    try {
      final db = await _dbService.database;

      const String query = '''
        SELECT role FROM pet_user_relations
        WHERE userId = ? AND petId = ? AND is_active = 1
      ''';

      final result = await db.rawQuery(query, [userId, petId]);

      if (result.isEmpty) return false;

      if (requiredRole != null) {
        final userRole = result.first['role'] as String;
        return _hasRequiredRole(userRole, requiredRole);
      }

      return true;
    } catch (e) {
      LoggerService.debug('펫 권한 확인 실패: $e');
      return false;
    }
  }

  /// 역할 권한 확인
  bool _hasRequiredRole(String userRole, String requiredRole) {
    const roleHierarchy = ['viewer', 'caretaker', 'owner', 'admin'];

    final userRoleIndex = roleHierarchy.indexOf(userRole);
    final requiredRoleIndex = roleHierarchy.indexOf(requiredRole);

    return userRoleIndex >= requiredRoleIndex;
  }

  /// 펫의 소유자 조회
  Future<Map<String, dynamic>?> getPetOwner(String petId) async {
    try {
      final db = await _dbService.database;

      final result = await db.rawQuery(
        '''
        SELECT
          pur.*,
          up.user_name,
          up.email,
          up.profile_image
        FROM pet_user_relations pur
        JOIN user_profiles up ON pur.userId = up.id
        WHERE pur.petId = ? AND pur.role = 'owner' AND pur.is_active = 1
        LIMIT 1
      ''',
        [petId],
      );

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      LoggerService.debug('펫 소유자 조회 실패: $e');
      return null;
    }
  }

  /// 사용자 역할 업데이트
  Future<bool> updateUserRole({
    required String petId,
    required String userId,
    required String newRole,
    String? permissions,
  }) async {
    try {
      final db = await _dbService.database;

      await db.update(
        'pet_user_relations',
        {
          'role': newRole,
          'permissions': permissions,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'petId = ? AND userId = ?',
        whereArgs: [petId, userId],
      );

      return true;
    } catch (e) {
      LoggerService.debug('사용자 역할 업데이트 실패: $e');
      return false;
    }
  }

  /// 펫의 관리자 수 조회
  Future<int> getPetManagerCount(String petId) async {
    try {
      final db = await _dbService.database;

      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM pet_user_relations
        WHERE petId = ? AND is_active = 1
      ''',
        [petId],
      );

      return result.first['count'] as int;
    } catch (e) {
      LoggerService.debug('펫 관리자 수 조회 실패: $e');
      return 0;
    }
  }

  /// 사용자가 관리하는 펫 수 조회
  Future<int> getUserPetCount(String userId) async {
    try {
      final db = await _dbService.database;

      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM pet_user_relations
        WHERE userId = ? AND is_active = 1
      ''',
        [userId],
      );

      return result.first['count'] as int;
    } catch (e) {
      LoggerService.debug('사용자 펫 수 조회 실패: $e');
      return 0;
    }
  }
}
