import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aipet_frontend/shared/core/domain/entities/pet_entity.dart';

/// Home feature의 Pets Provider
///
/// pet_registor 의존성을 제거하고 home에서 필요한 최소 펫 데이터만 관리
final petsNotifierProvider = StateNotifierProvider<PetsNotifier, AsyncValue<List<PetEntity>>>(
  (ref) => PetsNotifier(),
);

/// Pets 상태 관리
class PetsNotifier extends StateNotifier<AsyncValue<List<PetEntity>>> {
  PetsNotifier() : super(const AsyncValue.loading()) {
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      // TODO: 실제 Repository에서 데이터 로드
      // 현재는 Mock 데이터 사용
      final pets = _getMockPets();
      state = AsyncValue.data(pets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mock 펫 데이터
  List<PetEntity> _getMockPets() {
    final now = DateTime.now();
    return [
      PetEntity(
        id: '1',
        name: 'ポチ',
        type: 'dog',
        breed: '柴犬',
        gender: 'male',
        size: 'medium',
        weight: 12.5,
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 3)), // 3 years old
        imagePath: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      PetEntity(
        id: '2',
        name: 'タマ',
        type: 'cat',
        breed: 'スコティッシュフォールド',
        gender: 'female',
        size: 'small',
        weight: 4.2,
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 2)), // 2 years old
        imagePath: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  /// 펫 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadPets();
  }
}