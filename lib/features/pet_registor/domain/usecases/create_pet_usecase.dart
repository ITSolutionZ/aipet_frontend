import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

class CreatePetUseCase {
  final PetRepository repository;

  CreatePetUseCase(this.repository);

  Future<Result<PetProfileEntity>> call(PetProfileEntity pet) async {
    try {
      final result = await repository.createPet(pet);
      if (result.isSuccess) {
        return Success(result.dataOrNull!, result.errorOrNull);
      } else {
        return Result.failure(result.errorOrNull!);
      }
    } catch (error) {
      return Result.failure('ペットの作成に失敗しました: ${error.toString()}');
    }
  }
}
