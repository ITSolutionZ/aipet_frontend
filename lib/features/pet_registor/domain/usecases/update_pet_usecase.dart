import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.updatePet(pet);
      if (result.isSuccess) {
        return Success(result.dataOrNull!, 'ペット情報が更新されました');
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ペットの更新に失敗しました: ${error.toString()}');
    }
  }
}
