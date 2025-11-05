import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../shared/shared.dart';
import '../../../../../features/pet_profile/data/repositories/backend_pet_repository.dart';
import '../../../../../features/pet_profile/data/services/pet_local_storage_service.dart';
import '../../../../../features/pet_profile/domain/repositories/pet_profile_repository.dart';

part 'pet_profile_providers.g.dart';

/// PetProfileRepository 프로바이더 (백엔드 API 사용)
@riverpod
PetProfileRepository petProfileRepository(Ref ref) {
  LoggerService.debug('🚀 [PetProfile] BackendPetRepository 초기화');
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
    if (!ref.mounted) {
      LoggerService.debug(
        '⚠️ PetProfilesNotifier.createPet: Provider is disposed, skipping creation',
      );
      throw Exception('Provider disposed');
    }

    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.createPet(pet);
    if (result.isSuccess) {
      if (ref.mounted) {
        try {
          await refresh();
        } catch (e) {
          LoggerService.debug(
            '⚠️ PetProfilesNotifier.createPet: Refresh failed (provider disposed): $e',
          );
          // Provider가 disposed된 경우 무시하고 계속 진행
        }
      }
      return result.dataOrNull!;
    } else {
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
