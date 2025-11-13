import 'package:aipet_frontend/features/pet_profile/data/repositories/backend_pet_repository.dart';
import 'package:aipet_frontend/features/pet_profile/data/services/pet_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_providers.g.dart';

/// PetProfileRepository 프로바이더 (Backend API 사용)
/// 로컬 저장소를 사용하려면 PetProfileRepositoryImpl()로 변경하세요
@riverpod
PetProfileRepository petProfileRepository(Ref ref) {
  LoggerService.debug('🚀 [PetProfile] BackendPetRepository (API) 초기화');
  return BackendPetRepository();
}

/// 모든 펫 목록 프로바이더
@riverpod
class PetProfilesNotifier extends _$PetProfilesNotifier {
  @override
  Future<List<PetProfileEntity>> build() async {
    try {
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getAllPets();
      if (result.isSuccess) {
        return result.dataOrNull ?? [];
      } else {
        throw Exception(result.error);
      }
    } catch (e) {
      rethrow;
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

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (!ref.mounted) {
        throw Exception('Provider disposed during refresh');
      }
      final repository = ref.read(petProfileRepositoryProvider);
      final result = await repository.getAllPets();
      if (result.isSuccess) {
        return result.dataOrNull ?? [];
      } else {
        throw Exception(result.error);
      }
    });
  }

  /// 펫 생성
  Future<PetProfileEntity> createPet(PetProfileEntity pet) async {
    print('🎯 ===== PetProfilesNotifier.createPet 시작 =====');
    print('🎯 펫 정보:');
    print('   - ID: ${pet.id}');
    print('   - 이름: ${pet.name}');
    print('   - 타입: ${pet.type}');
    print('   - 품종: ${pet.breed}');
    print('   - 성별: ${pet.gender}');
    print('   - 체중: ${pet.weight}');
    print('   - 생일: ${pet.birthDate}');
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

    print('🎯 Repository로 펫 생성 요청...');
    LoggerService.debug('🎯 Repository로 펫 생성 요청...');
    final repository = ref.read(petProfileRepositoryProvider);
    print('🎯 Repository 타입: ${repository.runtimeType}');
    final result = await repository.createPet(pet);
    print('🎯 Repository 응답 받음: ${result.isSuccess}');

    if (result.isSuccess) {
      print('✅ Repository에서 펫 생성 성공!');
      print('   생성된 펫 ID: ${result.dataOrNull?.id}');
      LoggerService.debug('✅ Repository에서 펫 생성 성공!');
      LoggerService.debug('   생성된 펫 ID: ${result.dataOrNull?.id}');

      if (ref.mounted) {
        try {
          LoggerService.debug('🔄 펫 목록 새로고침 중...');
          await refresh();
          LoggerService.debug('✅ 펫 목록 새로고침 완료');
        } catch (e) {
          LoggerService.debug('⚠️ 새로고침 실패 (무시): $e');
          // Provider가 disposed된 경우 무시하고 계속 진행
        }
      }
      return result.dataOrNull!;
    } else {
      print('❌ Repository에서 펫 생성 실패');
      print('   에러: ${result.error}');
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
      if (ref.mounted) {
        try {
          await refresh();
        } catch (e) {
          LoggerService.debug(
            '⚠️ PetProfilesNotifier.updatePet: Refresh failed (provider disposed): $e',
          );
          // Provider가 disposed된 경우 무시하고 계속 진행
        }
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
      if (ref.mounted) {
        try {
          await refresh();
        } catch (e) {
          LoggerService.debug(
            '⚠️ PetProfilesNotifier.deletePet: Refresh failed (provider disposed): $e',
          );
          // Provider가 disposed된 경우 무시하고 계속 진행
        }
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
