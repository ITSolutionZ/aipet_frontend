import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/core/domain/result.dart' as core_result;
import '../../../../shared/shared.dart';
import '../../data/providers/usecase_providers.dart';
import '../../domain/usecases/create_pet_usecase.dart';
import '../../domain/usecases/delete_pet_usecase.dart';
import '../../domain/usecases/get_all_pets_usecase.dart';
import '../../domain/usecases/get_pet_profile_usecase.dart';
import '../../domain/usecases/update_pet_usecase.dart';

class PetProfileCoreController extends CrudController<PetProfileEntity> {
  PetProfileCoreController(WidgetRef ref) : super(ref);

  // UseCase 인스턴스 - Dependency Injection 사용 (getter로 변경)
  GetAllPetsUseCase get _getAllPetsUseCase => super.ref.read(
        getAllPetsUseCaseProvider,
      );
  GetPetProfileUseCase get _getPetProfileUseCase => super.ref.read(
        getPetProfileUseCaseProvider,
      );
  CreatePetUseCase get _createPetUseCase => super.ref.read(
        createPetUseCaseProvider,
      );
  UpdatePetUseCase get _updatePetUseCase => super.ref.read(
        updatePetUseCaseProvider,
      );
  DeletePetUseCase get _deletePetUseCase => super.ref.read(
        deletePetUseCaseProvider,
      );

  @override
  Future<core_result.Result<List<PetProfileEntity>>> getAll() async {
    try {
      final result = await _getAllPetsUseCase.call();
      if (result.isSuccess) {
        return core_result.Result.success(
          '펫 목록을 성공적으로 가져왔습니다',
          result.dataOrNull!,
        );
      } else {
        return core_result.Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return core_result.Result.failure(
        '펫 목록을 가져오는데 실패했습니다: ${error.toString()}',
      );
    }
  }

  @override
  Future<core_result.Result<PetProfileEntity>> getById(String id) async {
    try {
      final result = await _getPetProfileUseCase.call(id);
      if (result.isSuccess && result.dataOrNull != null) {
        return core_result.Result.success(
          '펫 정보를 성공적으로 가져왔습니다',
          result.dataOrNull!,
        );
      } else {
        return core_result.Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return core_result.Result.failure(
        '펫 정보를 가져오는데 실패했습니다: ${error.toString()}',
      );
    }
  }

  @override
  Future<core_result.Result<PetProfileEntity>> create(
    PetProfileEntity entity,
  ) async {
    try {
      final result = await _createPetUseCase.call(entity);
      if (result.isSuccess) {
        return core_result.Result.success(
          '펫이 성공적으로 생성되었습니다',
          result.dataOrNull!,
        );
      } else {
        return core_result.Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return core_result.Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<core_result.Result<PetProfileEntity>> update(
    PetProfileEntity entity,
  ) async {
    try {
      final result = await _updatePetUseCase.call(entity);
      if (result.isSuccess) {
        return core_result.Result.success(
          '펫 정보가 성공적으로 업데이트되었습니다',
          result.dataOrNull!,
        );
      } else {
        return core_result.Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return core_result.Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<core_result.Result<void>> delete(String id) async {
    try {
      final result = await _deletePetUseCase.call(id);
      if (result.isSuccess) {
        return core_result.Result.success(
          '펫이 성공적으로 삭제되었습니다',
          result.dataOrNull,
        );
      } else {
        return core_result.Result.failure(result.message);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
      return core_result.Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }
}
