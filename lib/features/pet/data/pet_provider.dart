import 'package:aipet_frontend/features/pet/data/services/pet_local_storage_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_provider.g.dart';

/// ペットリストプロバイダー
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

/// 選択中のペットIDプロバイダー
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

/// 選択中のペットプロバイダー
@riverpod
Future<PetProfileEntity?> selectedPet(Ref ref) async {
  final selectedId = await ref.watch(selectedPetIdProvider.future);
  if (selectedId == null || selectedId.isEmpty) return null;

  return PetLocalStorageService.getPetById(selectedId);
}
