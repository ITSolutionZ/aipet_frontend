import 'package:aipet_frontend/features/pet_profile/data/repositories/pet_profile_repository_impl.dart';
import 'package:aipet_frontend/features/pet_profile/data/services/pet_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_profile_providers.g.dart';

/// PetProfileRepository 프로바이더
@riverpod
PetProfileRepository petProfileRepository(Ref ref) {
  return PetProfileRepositoryImpl();
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
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
    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.createPet(pet);
    if (result.isSuccess) {
      await refresh();
      return result.dataOrNull!;
    } else {
      throw Exception(result.error);
    }
  }

  /// 펫 업데이트
  Future<void> updatePet(PetProfileEntity pet) async {
    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.updatePet(pet);
    if (result.isSuccess) {
      await refresh();
    } else {
      throw Exception(result.error);
    }
  }

  /// 펫 삭제
  Future<void> deletePet(String id) async {
    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.deletePet(id);
    if (result.isSuccess) {
      await refresh();
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
    state = await AsyncValue.guard(() async {
      await PetLocalStorageService.addPet(pet);
      return PetLocalStorageService.getPets();
    });
  }

  /// ペットを更新
  Future<void> updatePet(PetProfileEntity pet) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await PetLocalStorageService.updatePet(pet);
      return PetLocalStorageService.getPets();
    });
  }

  /// ペットを削除
  Future<void> deletePet(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await PetLocalStorageService.deletePet(id);
      return PetLocalStorageService.getPets();
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
