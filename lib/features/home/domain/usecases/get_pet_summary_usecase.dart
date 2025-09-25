import 'package:aipet_frontend/features/home/domain/entities/pet_summary_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 펫 요약 정보 조회 UseCase
class GetPetSummaryUseCase {
  final HomeRepository repository;

  GetPetSummaryUseCase(this.repository);

  /// 모든 펫 요약 정보 조회
  Future<Result<List<PetSummaryEntity>>> call() async {
    try {
      final data = await repository.getPetSummaries();
      return ResultFactory.success(data, 'ペット情報を取得しました');
    } catch (error) {
      return ResultFactory.failure<List<PetSummaryEntity>>(
        'ペット情報の取得に失敗しました: ${error.toString()}',
      );
    }
  }

  /// 특정 펫 요약 정보 조회
  Future<Result<PetSummaryEntity>> getById(String petId) async {
    try {
      final petsResult = await call();
      if (petsResult.isFailure) {
        return ResultFactory.failure<PetSummaryEntity>(petsResult.errorOrNull ?? 'エラーが発生しました');
      }

      final pets = petsResult.dataOrNull ?? [];
      final pet = pets.firstWhere(
        (pet) => pet.id == petId,
        orElse: () => throw Exception('ペットが見つかりませんでした'),
      );

      return ResultFactory.success(pet, 'ペット情報を取得しました');
    } catch (error) {
      return ResultFactory.failure<PetSummaryEntity>(
        'ペット情報の取得に失敗しました: ${error.toString()}',
      );
    }
  }
}
