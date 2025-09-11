import '../../../../app/controllers/base_controller.dart';
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
  Future<PetCoreResult> getAllPets() async {
    try {
      final pets = await _getAllPetsUseCase.call();
      return PetCoreResult.success('펫 목록을 가져왔습니다', pets);
    } catch (error) {
      handleError(error);
      return PetCoreResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// ID로 펫 가져오기
  Future<PetCoreResult> getPetById(String id) async {
    try {
      final pet = await _getPetByIdUseCase.call(id);
      if (pet == null) {
        return PetCoreResult.failure('펫을 찾을 수 없습니다');
      }
      return PetCoreResult.success('펫 정보를 가져왔습니다', pet);
    } catch (error) {
      handleError(error);
      return PetCoreResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 펫 생성
  Future<PetCoreResult> createPet(PetProfileEntity pet) async {
    try {
      final newPet = await _createPetUseCase.call(pet);
      return PetCoreResult.success('펫이 생성되었습니다', newPet);
    } catch (error) {
      handleError(error);
      return PetCoreResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 펫 업데이트
  Future<PetCoreResult> updatePet(PetProfileEntity pet) async {
    try {
      final updatedPet = await _updatePetUseCase.call(pet);
      return PetCoreResult.success('펫 정보가 업데이트되었습니다', updatedPet);
    } catch (error) {
      handleError(error);
      return PetCoreResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 펫 삭제
  Future<PetCoreResult> deletePet(String id) async {
    try {
      await _deletePetUseCase.call(id);
      return PetCoreResult.success('펫이 삭제되었습니다');
    } catch (error) {
      handleError(error);
      return PetCoreResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}

class PetCoreResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const PetCoreResult._(this.isSuccess, this.message, this.data);

  factory PetCoreResult.success(String message, [dynamic data]) =>
      PetCoreResult._(true, message, data);
  factory PetCoreResult.failure(String message) =>
      PetCoreResult._(false, message, null);
}
