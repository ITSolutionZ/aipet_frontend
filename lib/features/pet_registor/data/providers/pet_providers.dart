import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../repositories/pet_repository_impl.dart';

part 'pet_providers.g.dart';

/// PetRepository 프로바이더
@riverpod
PetRepository petRepository(Ref ref) {
  return PetRepositoryImpl();
}

/// 모든 펫 목록 프로바이더
@riverpod
class PetsNotifier extends _$PetsNotifier {
  @override
  Future<List<PetProfileEntity>> build() async {
    final repository = ref.watch(petRepositoryProvider);
    return repository.getAllPets();
  }

  /// 펫 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(petRepositoryProvider);
      return repository.getAllPets();
    });
  }

  /// 펫 생성
  Future<void> createPet(PetProfileEntity pet) async {
    final repository = ref.read(petRepositoryProvider);
    await repository.createPet(pet);
    await refresh();
  }

  /// 펫 업데이트
  Future<void> updatePet(PetProfileEntity pet) async {
    final repository = ref.read(petRepositoryProvider);
    await repository.updatePet(pet);
    await refresh();
  }

  /// 펫 삭제
  Future<void> deletePet(String id) async {
    final repository = ref.read(petRepositoryProvider);
    await repository.deletePet(id);
    await refresh();
  }
}

/// 개별 펫 프로바이더
@riverpod
Future<PetProfileEntity?> petById(Ref ref, String id) async {
  final repository = ref.watch(petRepositoryProvider);
  return repository.getPetById(id);
}

/// 현재 선택된 펫 프로바이더
@riverpod
class SelectedPetNotifier extends _$SelectedPetNotifier {
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
