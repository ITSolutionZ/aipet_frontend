import 'package:aipet_frontend/features/pet_registor/data/providers/usecase_providers.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/create_pet_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/delete_pet_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_all_pets_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/usecases/update_pet_usecase.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart' as coreResult;
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';

class PetCoreController extends CrudController<PetProfileEntity> {
  PetCoreController(super.ref);

  // UseCase 인스턴스 - Dependency Injection 사용
  late final GetAllPetsUseCase _getAllPetsUseCase = ref.read(
    getAllPetsUseCaseProvider,
  );
  late final GetPetByIdUseCase _getPetByIdUseCase = ref.read(
    getPetByIdUseCaseProvider,
  );
  late final CreatePetUseCase _createPetUseCase = ref.read(
    createPetUseCaseProvider,
  );
  late final UpdatePetUseCase _updatePetUseCase = ref.read(
    updatePetUseCaseProvider,
  );
  late final DeletePetUseCase _deletePetUseCase = ref.read(
    deletePetUseCaseProvider,
  );

  @override
  Future<coreResult.Result<List<PetProfileEntity>>> getAll() async {
    try {
      final result = await _getAllPetsUseCase.call();
      if (result.isSuccess) {
        return coreResult.Result.success(
          '펫 목록을 성공적으로 가져왔습니다',
          result.dataOrNull!,
        );
      } else {
        return coreResult.Failure(result.errorOrNull!);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return coreResult.Failure(
        '펫 목록을 가져오는데 실패했습니다: ${error.toString()}',
      );
    }
  }

  @override
  Future<coreResult.Result<PetProfileEntity>> getById(String id) async {
    try {
      final result = await _getPetByIdUseCase.call(id);
      if (result.isSuccess) {
        if (result.dataOrNull == null) {
          return coreResult.Failure('펫을 찾을 수 없습니다');
        }
        return coreResult.Result.success(
          '펫 목록을 성공적으로 가져왔습니다',
          result.dataOrNull!,
        );
      } else {
        return coreResult.Failure(result.errorOrNull!);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return coreResult.Failure(
        '펫 정보를 가져오는데 실패했습니다: ${error.toString()}',
      );
    }
  }

  @override
  Future<coreResult.Result<PetProfileEntity>> create(
    PetProfileEntity pet,
  ) async {
    try {
      final result = await _createPetUseCase.call(pet);
      if (result.isSuccess) {
        return coreResult.Result.success(
          '펫 목록을 성공적으로 가져왔습니다',
          result.dataOrNull!,
        );
      } else {
        return coreResult.Failure(result.errorOrNull!);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return coreResult.Failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<coreResult.Result<PetProfileEntity>> update(
    PetProfileEntity pet,
  ) async {
    try {
      final result = await _updatePetUseCase.call(pet);
      if (result.isSuccess) {
        return coreResult.Result.success(
          '펫 목록을 성공적으로 가져왔습니다',
          result.dataOrNull!,
        );
      } else {
        return coreResult.Failure(result.errorOrNull!);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return coreResult.Failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<coreResult.Result<void>> delete(String id) async {
    try {
      final result = await _deletePetUseCase.call(id);
      if (result.isSuccess) {
        return coreResult.Result.success('펫이 성공적으로 삭제되었습니다', null);
      } else {
        return coreResult.Failure(result.errorOrNull!);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return coreResult.Failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }
}
