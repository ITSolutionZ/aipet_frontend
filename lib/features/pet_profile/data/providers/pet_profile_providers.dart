import 'package:aipet_frontend/features/pet_profile/data/repositories/pet_profile_repository_impl.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        throw Exception(result.errorOrNull);
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
        throw Exception(result.errorOrNull);
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
      throw Exception(result.errorOrNull);
    }
  }

  /// 펫 업데이트
  Future<void> updatePet(PetProfileEntity pet) async {
    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.updatePet(pet);
    if (result.isSuccess) {
      await refresh();
    } else {
      throw Exception(result.errorOrNull);
    }
  }

  /// 펫 삭제
  Future<void> deletePet(String id) async {
    final repository = ref.read(petProfileRepositoryProvider);
    final result = await repository.deletePet(id);
    if (result.isSuccess) {
      await refresh();
    } else {
      throw Exception(result.errorOrNull);
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
    throw Exception(result.errorOrNull);
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
