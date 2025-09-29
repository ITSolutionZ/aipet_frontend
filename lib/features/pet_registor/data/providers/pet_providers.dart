import 'package:aipet_frontend/features/pet_registor/data/repositories/pet_repository_impl.dart';
import 'package:aipet_frontend/features/pet_registor/data/repositories/pet_repository_mockito_impl.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pet_providers.g.dart';

/// PetRepository 프로바이더 (Mockito 버전)
///
/// Mockito를 사용하여 테스트 가능성을 높입니다.
@riverpod
PetRepository petRepository(Ref ref) {
  return PetRepositoryMockitoImpl();
}

/// Legacy PetRepository 프로바이더 (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
@riverpod
PetRepository legacyPetRepository(Ref ref) {
  return PetRepositoryImpl();
}

/// 모든 펫 목록 프로바이더
@riverpod
class PetsNotifier extends _$PetsNotifier {
  @override
  Future<List<PetProfileEntity>> build() async {
    try {
      final repository = ref.read(petRepositoryProvider);
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
      final repository = ref.read(petRepositoryProvider);
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
    final repository = ref.read(petRepositoryProvider);
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
    final repository = ref.read(petRepositoryProvider);
    final result = await repository.updatePet(pet);
    if (result.isSuccess) {
      await refresh();
    } else {
      throw Exception(result.error);
    }
  }

  /// 펫 삭제
  Future<void> deletePet(String id) async {
    final repository = ref.read(petRepositoryProvider);
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
Future<PetProfileEntity?> petById(Ref ref, String id) async {
  final repository = ref.watch(petRepositoryProvider);
  final result = await repository.getPetById(id);
  if (result.isSuccess) {
    return result.dataOrNull;
  } else {
    throw Exception(result.error);
  }
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
