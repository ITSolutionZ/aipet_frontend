import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/entities/pet_summary_entity.dart';

/// 펫 요약 정보 조회 UseCase
class GetPetSummaryUseCase {
  final HomeRepository repository;

  GetPetSummaryUseCase(this.repository);

  /// 모든 펫 요약 정보 조회
  Future<List<PetSummaryEntity>> call() async {
    return repository.getPetSummaries();
  }

  /// 특정 펫 요약 정보 조회
  Future<PetSummaryEntity?> getById(String petId) async {
    final pets = await repository.getPetSummaries();
    try {
      return pets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }
}
