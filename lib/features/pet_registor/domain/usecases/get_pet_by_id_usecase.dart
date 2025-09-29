import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class GetPetByIdUseCase {
  final PetRepository repository;

  GetPetByIdUseCase(this.repository);

  Future<Result<PetProfileEntity?>> call(String id) async {
    try {
      final result = await repository.getPetById(id);
      if (result.isSuccess) {
        return Result.success('ペット情報を取得しました', result.dataOrNull!);
      } else {
        return Result.failure('ペット情報の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('ペット情報の取得に失敗しました: ${error.toString()}');
    }
  }
}
