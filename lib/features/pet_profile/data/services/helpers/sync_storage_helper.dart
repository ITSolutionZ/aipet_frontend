import 'package:aipet_frontend/shared/core/data/result_types.dart';
import 'package:aipet_frontend/shared/core/domain/common_errors.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/secure_storage_service.dart';
import 'package:aipet_frontend/shared/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';

import '../../models/pet_profile_api_model.dart';
import '../pet_api_service.dart';
import '../pet_sync_service.dart';

/// 동기화 스토리지 헬퍼
class SyncStorageHelper {
  /// Pending 로컬 변경사항 가져오기
  static Future<List<Map<String, dynamic>>> getPendingLocalChanges() async {
    try {
      final changesJson = await SecureStorageService.getJson(
        'pending_pet_changes',
      );
      if (changesJson != null && changesJson['changes'] is List) {
        return List<Map<String, dynamic>>.from(changesJson['changes']);
      }
    } catch (e) {
      // 로그만 남기고 빈 리스트 반환
    }
    return [];
  }

  /// Pending 변경사항 추가
  static Future<void> addPendingChange(
    String type,
    PetProfileEntity pet,
  ) async {
    try {
      final existingChanges = await getPendingLocalChanges();
      existingChanges.add({
        'type': type,
        'data': pet.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await SecureStorageService.setJson('pending_pet_changes', {
        'changes': existingChanges,
      });
    } catch (e) {
      // 로그만 남기고 계속 진행
    }
  }

  /// Pending 변경사항 클리어
  static Future<void> clearPendingChanges() async {
    try {
      await SecureStorageService.remove('pending_pet_changes');
    } catch (e) {
      // 로그만 남기고 계속 진행
    }
  }

  /// 동기화 메타데이터 업데이트
  static Future<void> updateSyncMetadata() async {
    try {
      await SecureStorageService.setJson('pet_sync_metadata', {
        'last_sync': DateTime.now().toIso8601String(),
        'sync_version': 1,
        'status': 'completed',
      });
    } catch (e) {
      // 로그만 남기고 계속 진행
    }
  }

  /// 캐시된 펫 데이터 가져오기
  static Future<ResultState<List<PetProfileEntity>>> getCachedPets(
    CacheService cacheService,
  ) async {
    try {
      final cachedData = await cacheService.getPersistentCache(
        'synced_pet_profiles',
      );
      if (cachedData == null) {
        return const Success([]);
      }

      final petsData = cachedData['pets'] as List<dynamic>;
      final pets = petsData
          .map(
            (petData) =>
                PetProfileEntity.fromJson(Map<String, dynamic>.from(petData)),
          )
          .toList();

      return Success(pets);
    } catch (e) {
      return Result.failure(
        CacheError('캐시된 펫 데이터 로드 실패', details: e.toString()),
      );
    }
  }

  /// 마지막 동기화 시간 가져오기
  static Future<ResultState<DateTime?>> getLastSyncTime() async {
    try {
      final metadata = await SecureStorageService.getJson('pet_sync_metadata');
      if (metadata != null && metadata['last_sync'] is String) {
        final lastSync = DateTime.parse(metadata['last_sync']);
        return Success(lastSync);
      }
      return const Success(null);
    } catch (e) {
      return Result.failure(
        CacheError('마지막 동기화 시간 조회 실패', details: e.toString()),
      );
    }
  }

  /// 동기화 필요 여부 확인
  static Future<ResultState<bool>> needsSync() async {
    try {
      final lastSyncResult = await getLastSyncTime();
      if (lastSyncResult.isFailure || lastSyncResult.dataOrNull == null) {
        return const Success(true);
      }

      final lastSync = lastSyncResult.dataOrNull!;
      final timeSinceSync = DateTime.now().difference(lastSync);

      return Success(timeSinceSync.inHours > 1);
    } catch (e) {
      return const Success(true);
    }
  }

  /// 동기화 변경사항 적용
  static Future<ResultState<PetProfileEntity?>> applySyncChange(
    Map<String, dynamic> change,
    PetApiService petApiService,
  ) async {
    try {
      final type = change['type'] as String;
      final data = change['data'] as Map<String, dynamic>;

      switch (type) {
        case 'create':
          final petData = PetProfileEntity.fromJson(data);
          final request = PetProfileCreateRequest.fromDomain(petData);
          final result = await petApiService.createPet(request);
          if (result.isSuccess) {
            return Success(result.dataOrNull!.toDomain());
          }
          return Result.failure(result.errorOrNull!);

        case 'update':
          final petId = data['id'] as String;
          final updateData = Map<String, dynamic>.from(data);
          updateData.remove('id');
          final request = PetProfileUpdateRequest.fromJson(updateData);
          final result = await petApiService.updatePet(petId, request);
          if (result.isSuccess) {
            return Success(result.dataOrNull!.toDomain());
          }
          return Result.failure(result.errorOrNull!);

        case 'delete':
          final petId = data['id'] as String;
          final result = await petApiService.deletePet(petId);
          if (result.isSuccess) {
            return const Success(null);
          }
          return Result.failure(result.errorOrNull!);

        default:
          return Result.failure(
            ValidationError(field: 'sync_type', reason: '알 수 없는 동기화 타입: $type'),
          );
      }
    } catch (e) {
      return Result.failure(SyncError('동기화 변경사항 적용 실패', details: e.toString()));
    }
  }
}
