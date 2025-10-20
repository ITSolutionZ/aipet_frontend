import 'package:aipet_frontend/features/settings/domain/entities/settings_entity.dart';
import 'package:aipet_frontend/shared/services/local_database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// 사용자 프로필 로컬 서비스
class LocalUserService {
  final LocalDatabaseService _databaseService = LocalDatabaseService.instance;
  final Uuid _uuid = const Uuid();

  /// 사용자 프로필 저장/업데이트
  Future<bool> saveUserProfile(UserProfileEntity profile) async {
    try {
      final db = await _databaseService.database;

      // 기존 프로필이 있는지 확인
      final existingProfiles = await db.query(
        'user_profiles',
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      if (existingProfiles.isNotEmpty) {
        // 업데이트
        await db.update(
          'user_profiles',
          {
            'user_name': profile.userName,
            'email': profile.email,
            'name_katakana': profile.nameKatakana,
            'contact': profile.contact,
            'profile_image': profile.profileImage,
            'updated_at': profile.updatedAt.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [profile.id],
        );
      } else {
        // 새로 생성
        await db.insert('user_profiles', {
          'id': profile.id,
          'user_name': profile.userName,
          'email': profile.email,
          'name_katakana': profile.nameKatakana,
          'contact': profile.contact,
          'profile_image': profile.profileImage,
          'created_at': profile.createdAt.toIso8601String(),
          'updated_at': profile.updatedAt.toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      debugPrint('❌ 사용자 프로필 저장 실패: $e');
      return false;
    }
  }

  /// 사용자 프로필 로드
  Future<UserProfileEntity?> loadUserProfile() async {
    try {
      final db = await _databaseService.database;
      final profiles = await db.query('user_profiles', limit: 1);

      if (profiles.isEmpty) return null;

      final profile = profiles.first;
      return UserProfileEntity(
        id: profile['id'] as String,
        userName: profile['user_name'] as String,
        email: profile['email'] as String,
        nameKatakana: profile['name_katakana'] as String?,
        contact: profile['contact'] as String?,
        profileImage: profile['profile_image'] as String?,
        createdAt: DateTime.parse(profile['created_at'] as String),
        updatedAt: DateTime.parse(profile['updated_at'] as String),
      );
    } catch (e) {
      debugPrint('❌ 사용자 프로필 로드 실패: $e');
      return null;
    }
  }

  /// 사용자 프로필 삭제
  Future<bool> deleteUserProfile(String id) async {
    try {
      final db = await _databaseService.database;
      await db.delete('user_profiles', where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      debugPrint('❌ 사용자 프로필 삭제 실패: $e');
      return false;
    }
  }

  /// 새 사용자 프로필 생성
  Future<UserProfileEntity> createUserProfile({
    required String userName,
    required String email,
    String? nameKatakana,
    String? contact,
    String? profileImage,
  }) async {
    final now = DateTime.now();
    return UserProfileEntity(
      id: _uuid.v4(),
      userName: userName,
      email: email,
      nameKatakana: nameKatakana,
      contact: contact,
      profileImage: profileImage,
      createdAt: now,
      updatedAt: now,
    );
  }
}
