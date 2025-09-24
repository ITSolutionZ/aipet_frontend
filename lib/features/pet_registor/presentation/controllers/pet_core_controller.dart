import 'package:aipet_frontend/features/onboarding/data/providers/usecase_providers.dart';
import 'package:aipet_frontend/features/onboarding/domain/domain.dart';
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
  Future<Result<List<PetProfileEntity>>> getAll() async {
    try {
      final result = await _getAllPetsUseCase.call();
      if (result.isSuccess) {
        return Result.success(result.message, result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('펫 목록을 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> getById(String id) async {
    try {
      final result = await _getPetByIdUseCase.call(id);
      if (result.isSuccess) {
        if (result.data == null) {
          return Result.failure('펫을 찾을 수 없습니다');
        }
        return Result.success(result.message, result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('펫 정보를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> create(PetProfileEntity pet) async {
    try {
      final result = await _createPetUseCase.call(pet);
      if (result.isSuccess) {
        return Result.success(result.message, result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> update(PetProfileEntity pet) async {
    try {
      final result = await _updatePetUseCase.call(pet);
      if (result.isSuccess) {
        return Result.success(result.message, result.data!);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final result = await _deletePetUseCase.call(id);
      if (result.isSuccess) {
        return Result.success(result.message, null);
      } else {
        return Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }
}
