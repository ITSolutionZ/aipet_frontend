import 'package:aipet_frontend/app/services/ultra_fast_cache_service.dart';
import 'package:aipet_frontend/features/pet_profile/data/repositories/firestore_pet_repository.dart';
import 'package:aipet_frontend/features/pet_profile/data/services/pet_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_providers.g.dart';

/// PetProfileRepository 프로바이더
///
/// Firebase Firestore를 사용하려면 FirestorePetRepository()를 사용하세요
/// Backend API를 사용하려면 BackendPetRepository()를 사용하세요
/// 로컬 저장소를 사용하려면 PetProfileRepositoryImpl()로 변경하세요
@riverpod
PetProfileRepository petProfileRepository(Ref ref) {
  // Firebase Firestore 사용 (기본값)
  LoggerService.debug('🚀 [PetProfile] FirestorePetRepository (Firebase) 초기화');
  return FirestorePetRepository();

  // Backend API 사용 (주석 해제하여 사용)
  // LoggerService.debug('🚀 [PetProfile] BackendPetRepository (API) 초기화');
  // return BackendPetRepository();
}

/// 모든 펫 목록 프로바이더
@riverpod
class PetProfilesNotifier extends _$PetProfilesNotifier {
  @override
  Future<List<PetProfileEntity>> build() async {
    try {
      LoggerService.debug('🐾 PetProfilesNotifier.build() 시작');

      // ✅ 1단계: 로컬 캐시 확인 (1회 이상 로그인한 유저)
      final cachedPets = await PetLocalStorageService.getPets();
      if (cachedPets.isNotEmpty) {
        LoggerService.debug('✅ 로컬 캐시에서 ${cachedPets.length}개 펫 로드 (빠른 로딩)');
        return cachedPets;
      }

      // ✅ 2단계: 첫 로그인 - Firebase에서 펫 데이터 로드 (타임아웃 5초)
      LoggerService.debug('📡 첫 로그인 감지 - Firebase에서 펫 데이터 로드');
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getAllPets();

      // ✅ 성공이든 실패든 결과 반환 (빈 리스트 포함)
      final pets = result.dataOrNull ?? [];
      LoggerService.debug('✅ Firebase에서 ${pets.length}개 펫 로드 완료');

      // ✅ Firebase 데이터를 로컬 캐시에 저장 (다음 로그인에서 사용)
      if (pets.isNotEmpty) {
        for (final pet in pets) {
          await PetLocalStorageService.addPet(pet);
        }
        LoggerService.debug('✅ Firebase 데이터를 로컬 캐시에 저장 (${pets.length}개)');
      }

      return pets;
    } catch (e) {
      LoggerService.debug('❌ PetProfilesNotifier.build() 에러: $e - 빈 리스트 반환');
      // ✅ 에러 발생 시에도 빈 리스트 반환 (앱 크래시 방지)
      return [];
    }
  }

  /// 펫 목록 새로고침
  Future<void> refresh() async {
    if (!ref.mounted) {
      LoggerService.debug(
        '⚠️ PetProfilesNotifier.refresh: Provider is disposed, skipping refresh',
      );
      return;
    }

    // ✅ 홈 화면 캐시 무효화
    _invalidateHomeCache();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) {
        throw Exception('Provider disposed during refresh');
      }
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getAllPets();
      if (result.isSuccess) {
        final pets = result.dataOrNull ?? [];

        // ✅ Firestore 데이터를 로컬 캐시에 저장 (다음 로딩 속도 향상)
        if (pets.isNotEmpty) {
          for (final pet in pets) {
            await PetLocalStorageService.updatePet(pet);
          }
          LoggerService.debug('✅ 새로고침 데이터를 로컬 캐시에 저장 (${pets.length}개)');
        }

        return pets;
      } else {
        throw Exception(result.error);
      }
    });
  }

  /// 홈 화면 캐시 무효화
  void _invalidateHomeCache() {
    try {
      // CacheService의 펫 프로필 캐시 무효화
      CacheService().invalidateCache(CacheKeys.petProfiles);

      // UltraFastCache 무효화
      UltraFastCacheService().invalidateCache();

      LoggerService.debug('✅ 홈 화면 캐시 무효화 완료');
    } catch (e) {
      LoggerService.debug('⚠️ 캐시 무효화 실패 (무시): $e');
    }
  }

  /// 펫 생성
  Future<PetProfileEntity> createPet(PetProfileEntity pet) async {
    LoggerService.debug('🎯 ===== PetProfilesNotifier.createPet 시작 =====');
    LoggerService.debug('🎯 펫 정보:');
    LoggerService.debug('   - ID: ${pet.id}');
    LoggerService.debug('   - 이름: ${pet.name}');
    LoggerService.debug('   - 타입: ${pet.type}');
    LoggerService.debug('   - 품종: ${pet.breed}');
    LoggerService.debug('   - 성별: ${pet.gender}');
    LoggerService.debug('   - 체중: ${pet.weight}');
    LoggerService.debug('   - 생일: ${pet.birthDate}');

    if (!ref.mounted) {
      LoggerService.debug('⚠️ Provider가 이미 disposed됨');
      throw Exception('Provider disposed');
    }

    LoggerService.debug('🎯 Repository로 펫 생성 요청...');
    final repository = ref.read(petProfileRepositoryProvider);
    LoggerService.debug('🎯 Repository 타입: ${repository.runtimeType}');
    final result = await repository.createPet(pet);
    LoggerService.debug('🎯 Repository 응답 받음: ${result.isSuccess}');

    if (result.isSuccess) {
      LoggerService.debug('✅ Repository에서 펫 생성 성공!');
      LoggerService.debug('   생성된 펫 ID: ${result.dataOrNull?.id}');

      final createdPet = result.dataOrNull!;

      // ✅ 로컬 캐시에 즉시 저장
      await PetLocalStorageService.addPet(createdPet);
      LoggerService.debug('✅ 생성된 펫을 로컬 캐시에 저장: ${createdPet.id}');

      // ✅ 홈 화면 캐시 무효화 (다음 로딩 시 새 데이터 표시)
      _invalidateHomeCache();

      if (ref.mounted) {
        // ✅ 상태에 새 펫 추가 (Firebase 재조회 없이 즉시 반영)
        final currentPets = state.asData?.value ?? [];
        final updatedPets = [...currentPets, createdPet];
        state = AsyncValue.data(updatedPets);
        LoggerService.debug('✅ 상태에 새 펫 추가 완료 (${updatedPets.length}개)');
      }

      return createdPet;
    } else {
      LoggerService.debug('❌ Repository에서 펫 생성 실패');
      LoggerService.debug('   에러: ${result.error}');
      throw Exception(result.error);
    }
  }

  /// 펫 업데이트
  Future<void> updatePet(PetProfileEntity pet) async {
    // Providerが破棄されていないかチェック
    if (!ref.mounted) {
      LoggerService.debug(
        '⚠️ PetProfilesNotifier.updatePet: Provider is disposed, skipping update',
      );
      return;
    }

    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.updatePet(pet);
    if (result.isSuccess) {
      // ✅ 로컬 캐시 즉시 업데이트
      await PetLocalStorageService.updatePet(pet);
      LoggerService.debug('✅ 업데이트된 펫을 로컬 캐시에 저장: ${pet.id}');

      // ✅ 홈 화면 캐시 무효화
      _invalidateHomeCache();

      if (ref.mounted) {
        // ✅ 상태에서 펫 업데이트 (Firebase 재조회 없이 즉시 반영)
        final currentPets = state.asData?.value ?? [];
        final updatedPets = currentPets.map((p) => p.id == pet.id ? pet : p).toList();
        state = AsyncValue.data(updatedPets);
        LoggerService.debug('✅ 상태에서 펫 업데이트 완료');
      }
    } else {
      throw Exception(result.error);
    }
  }

  /// 펫 삭제
  Future<void> deletePet(String id) async {
    if (!ref.mounted) {
      LoggerService.debug(
        '⚠️ PetProfilesNotifier.deletePet: Provider is disposed, skipping deletion',
      );
      return;
    }

    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.deletePet(id);
    if (result.isSuccess) {
      // ✅ 로컬 캐시에서 즉시 삭제
      await PetLocalStorageService.deletePet(id);
      LoggerService.debug('✅ 펫을 로컬 캐시에서 삭제: $id');

      // ✅ 홈 화면 캐시 무효화
      _invalidateHomeCache();

      if (ref.mounted) {
        // ✅ 상태에서 펫 삭제 (Firebase 재조회 없이 즉시 반영)
        final currentPets = state.asData?.value ?? [];
        final updatedPets = currentPets.where((p) => p.id != id).toList();
        state = AsyncValue.data(updatedPets);
        LoggerService.debug('✅ 상태에서 펫 삭제 완료 (${updatedPets.length}개)');
      }
    } else {
      throw Exception(result.error);
    }
  }
}

/// 개별 펫 프로바이더
@riverpod
Future<PetProfileEntity?> petProfileById(Ref ref, String id) async {
  final repository = ref.watch(petProfileRepositoryProvider);
  final result = await repository.getPetById(id);
  if (result.isSuccess) {
    return result.dataOrNull;
  } else {
    throw Exception(result.error);
  }
}

/// 현재 선택된 펫 프로바이더
@riverpod
class SelectedPetProfileNotifier extends _$SelectedPetProfileNotifier {
  @override
  PetProfileEntity? build() {
    return null;
  }

  /// 펫 선택
  void selectPet(PetProfileEntity pet) {
    state = pet;
  }

  /// 선택 해제
  void clearSelection() {
    state = null;
  }
}

/// 選択中のペットIDプロバイダー (pet 폴더에서 통합)
@riverpod
class SelectedPetId extends _$SelectedPetId {
  @override
  Future<String?> build() async {
    return PetLocalStorageService.getSelectedPetId();
  }

  /// ペットを選択
  Future<void> selectPet(String petId) async {
    await PetLocalStorageService.saveSelectedPetId(petId);
    state = AsyncValue.data(petId);
  }

  /// 選択解除
  Future<void> clearSelection() async {
    await PetLocalStorageService.saveSelectedPetId('');
    state = const AsyncValue.data(null);
  }
}

/// 選択中のペットプロバイダー (pet 폴더에서 통합)
@riverpod
Future<PetProfileEntity?> selectedPet(Ref ref) async {
  final selectedId = await ref.watch(selectedPetIdProvider.future);
  if (selectedId == null || selectedId.isEmpty) return null;

  return PetLocalStorageService.getPetById(selectedId);
}

/// ペットリストプロバイダー (pet 폴더에서 통합 - PetLocalStorageService 사용)
@riverpod
class PetList extends _$PetList {
  @override
  Future<List<PetProfileEntity>> build() async {
    return PetLocalStorageService.getPets();
  }

  /// ペットを追加
  Future<void> addPet(PetProfileEntity pet) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() async {
          await PetLocalStorageService.addPet(pet);
          return PetLocalStorageService.getPets();
        }).then((result) {
          // 상태 업데이트 후 mounted 확인
          if (!ref.mounted) {
            LoggerService.debug(
              '⚠️ PetList.addPet: Provider is disposed after operation',
            );
          }
          return result;
        });
  }

  /// ペットを更新
  Future<void> updatePet(PetProfileEntity pet) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() async {
          await PetLocalStorageService.updatePet(pet);
          return PetLocalStorageService.getPets();
        }).then((result) {
          // 상태 업데이트 후 mounted 확인
          if (!ref.mounted) {
            LoggerService.debug(
              '⚠️ PetList.updatePet: Provider is disposed after operation',
            );
          }
          return result;
        });
  }

  /// ペットを削除
  Future<void> deletePet(String id) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() async {
          await PetLocalStorageService.deletePet(id);
          return PetLocalStorageService.getPets();
        }).then((result) {
          // 상태 업데이트 후 mounted 확인
          if (!ref.mounted) {
            LoggerService.debug(
              '⚠️ PetList.deletePet: Provider is disposed after operation',
            );
          }
          return result;
        });
  }

  /// リフレッシュ
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return PetLocalStorageService.getPets();
    });
  }
}
