import '../../../../app/controllers/base_controller.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/usecase_providers.dart';
import '../../domain/domain.dart';

class PetCoreController extends BaseController {
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

  /// 모든 펫 목록 가져오기
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
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

  /// ID로 펫 가져오기
  Future<Result<PetProfileEntity>> getPetById(String id) async {
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

  /// 펫 생성
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
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

  /// 펫 업데이트
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
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

  /// 펫 삭제
  Future<Result<void>> deletePet(String id) async {
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
