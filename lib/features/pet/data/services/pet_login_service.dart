import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';

import 'pet_cache_clear_service.dart';
import 'pet_local_storage_service.dart';

/// 로그인 시 펫 데이터 로드 서비스
/// 사용자 로그인 후 저장된 펫 데이터를 불러오는 기능을 제공
class PetLoginService {
  /// 로그인 성공 시 펫 데이터 로드
  ///
  /// [userId] 로그인한 사용자 ID
  /// [return] 로드된 펫 프로필 리스트
  static Future<List<PetProfileEntity>> loadUserPetsOnLogin(
    String userId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🐾 PetLoginService: 사용자 $userId의 펫 데이터 로드 시작');
      }

      // 로그인 시 기존 캐시 클리어 (목업 데이터 제거)
      await PetCacheClearService.clearAllPetCache();

      // 로컬 저장소에서 사용자의 펫 데이터 로드
      final savedPets = await PetLocalStorageService.getPets();

      // 사용자 ID에 맞는 펫들만 필터링
      final userPets = savedPets.where((pet) => pet.ownerId == userId).toList();

      // 저장된 펫이 없는 경우 빈 리스트 반환
      if (userPets.isEmpty) {
        if (kDebugMode) {
          debugPrint('🐾 PetLoginService: 저장된 펫이 없음 - 빈 리스트 반환');
        }
        return [];
      }

      if (kDebugMode) {
        debugPrint('🐾 PetLoginService: 로드된 펫 수: ${userPets.length}');
        for (final pet in userPets) {
          debugPrint('  - ${pet.name} (${pet.type}, ${pet.breed})');
        }
      }

      return userPets;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ PetLoginService: 펫 데이터 로드 실패: $error');
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// 로그인 시 펫 데이터 초기화 (새 사용자용)
  ///
  /// [userId] 새 사용자 ID
  /// [return] 초기화 완료 여부
  static Future<bool> initializePetsForNewUser(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🐾 PetLoginService: 새 사용자 $userId의 펫 데이터 초기화');
      }

      // 새 사용자용 빈 펫 리스트 저장
      await PetLocalStorageService.savePets([]);

      if (kDebugMode) {
        debugPrint('✅ PetLoginService: 새 사용자 펫 데이터 초기화 완료');
      }

      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ PetLoginService: 새 사용자 펫 데이터 초기화 실패: $error');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// 사용자별 펫 데이터 백업
  ///
  /// [userId] 사용자 ID
  /// [pets] 백업할 펫 데이터
  /// [return] 백업 완료 여부
  static Future<bool> backupUserPets(
    String userId,
    List<PetProfileEntity> pets,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🐾 PetLoginService: 사용자 $userId의 펫 데이터 백업 시작');
        debugPrint('  - 백업할 펫 수: ${pets.length}');
      }

      // 사용자 ID로 펫 데이터 업데이트
      final updatedPets = pets
          .map((pet) => pet.copyWith(ownerId: userId))
          .toList();

      // 로컬 저장소에 저장
      await PetLocalStorageService.savePets(updatedPets);

      if (kDebugMode) {
        debugPrint('✅ PetLoginService: 펫 데이터 백업 완료');
      }

      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ PetLoginService: 펫 데이터 백업 실패: $error');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// 사용자 로그아웃 시 펫 데이터 정리
  ///
  /// [userId] 로그아웃하는 사용자 ID
  /// [return] 정리 완료 여부
  static Future<bool> cleanupUserPetsOnLogout(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🐾 PetLoginService: 사용자 $userId 로그아웃 시 펫 데이터 정리');
      }

      // 현재 사용자의 펫 데이터 가져오기
      final currentPets = await PetLocalStorageService.getPets();
      final userPets = currentPets
          .where((pet) => pet.ownerId == userId)
          .toList();

      // 사용자별 펫 데이터는 로컬에 유지 (다음 로그인 시 사용)
      // 필요한 경우 캐시만 정리

      if (kDebugMode) {
        debugPrint('✅ PetLoginService: 로그아웃 시 펫 데이터 정리 완료');
        debugPrint('  - 유지된 펫 수: ${userPets.length}');
      }

      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ PetLoginService: 로그아웃 시 펫 데이터 정리 실패: $error');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// 사용자별 펫 통계 정보
  ///
  /// [userId] 사용자 ID
  /// [return] 펫 통계 정보
  static Future<Map<String, dynamic>> getUserPetStatistics(
    String userId,
  ) async {
    try {
      final pets = await loadUserPetsOnLogin(userId);

      if (pets.isEmpty) {
        return {
          'totalPets': 0,
          'activePets': 0,
          'petTypes': {},
          'averageAge': 0.0,
          'averageWeight': 0.0,
          'hasPets': false,
        };
      }

      final activePets = pets.where((pet) => pet.isActive).length;
      final petTypes = <String, int>{};

      for (final pet in pets) {
        petTypes[pet.type] = (petTypes[pet.type] ?? 0) + 1;
      }

      final averageAge =
          pets.map((pet) => pet.age).reduce((a, b) => a + b) / pets.length;
      final averageWeight =
          pets.map((pet) => pet.weight).reduce((a, b) => a + b) / pets.length;

      return {
        'totalPets': pets.length,
        'activePets': activePets,
        'petTypes': petTypes,
        'averageAge': averageAge,
        'averageWeight': averageWeight,
        'hasPets': true,
      };
    } catch (error) {
      if (kDebugMode) {
        debugPrint('❌ PetLoginService: 펫 통계 정보 생성 실패: $error');
      }
      return {
        'totalPets': 0,
        'activePets': 0,
        'petTypes': {},
        'averageAge': 0.0,
        'averageWeight': 0.0,
        'hasPets': false,
        'error': error.toString(),
      };
    }
  }

  /// 로그인 로그 생성
  ///
  /// [userId] 사용자 ID
  /// [pets] 로드된 펫 데이터
  /// [return] 로그인 로그 문자열
  static String generateLoginLog(String userId, List<PetProfileEntity> pets) {
    final timestamp = DateTime.now().toIso8601String();
    final petNames = pets.map((pet) => pet.name).join(', ');

    return '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐾 펫 로그인 로그
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 로그인 시간: $timestamp
👤 사용자 ID: $userId
🐾 등록된 펫: ${pets.length}마리
📝 펫 목록: ${petNames.isNotEmpty ? petNames : '등록된 펫 없음'}

${pets.isNotEmpty ? '📋 펫 상세 정보:' : ''}
${pets.map((pet) => '  • ${pet.name} (${pet.typeName}${pet.breed != null ? ' - ${pet.breed}' : ''}, ${pet.age}세, ${pet.weight}kg)').join('\n')}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
  }
}
