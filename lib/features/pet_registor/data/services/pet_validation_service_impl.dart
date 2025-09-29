import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/services/pet_validation_service.dart';
import 'package:aipet_frontend/shared/core/services/validation_service.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 펫 등록 검증 서비스 구현체
///
/// shared의 ValidationService를 사용하여 중복 코드를 제거합니다.
class PetValidationServiceImpl implements PetValidationService {
  @override
  Future<Result<void>> validatePetName(String name) async {
    final oldResult = ValidationService.validatePetName(name);
    if (oldResult.isSuccess) {
      return const Success(null);
    } else {
      return Result.failure(oldResult.message);
    }
  }

  @override
  Future<Result<void>> validateWeight(double weight) async {
    final oldResult = ValidationService.validatePetWeight(weight);
    if (oldResult.isSuccess) {
      return const Success(null);
    } else {
      return Result.failure(oldResult.message);
    }
  }

  @override
  Future<Result<void>> validateMicrochipNumber(String number) async {
    final oldResult = ValidationService.validateMicrochipNumber(number);
    if (oldResult.isSuccess) {
      return const Success(null);
    } else {
      return Result.failure(oldResult.message);
    }
  }

  @override
  Future<Result<void>> validateBirthday(DateTime birthday) async {
    final oldResult = ValidationService.validatePetBirthday(birthday);
    if (oldResult.isSuccess) {
      return const Success(null);
    } else {
      return Result.failure(oldResult.message);
    }
  }

  @override
  Future<Result<void>> validatePetData(PetRegistrationDataEntity data) async {
    // 전체 데이터 검증
    final nameResult = await validatePetName(data.name ?? '');
    if (nameResult.isFailure) {
      return nameResult;
    }

    final weight = data.additionalInfo?['weight'] as double?;
    if (weight != null) {
      final weightResult = await validateWeight(weight);
      if (weightResult.isFailure) {
        return weightResult;
      }
    }

    final microchipNumber = data.additionalInfo?['microchipNumber'] as String?;
    if (microchipNumber != null && microchipNumber.isNotEmpty) {
      final microchipResult = await validateMicrochipNumber(microchipNumber);
      if (microchipResult.isFailure) {
        return microchipResult;
      }
    }

    if (data.birthDate != null) {
      final birthdayResult = await validateBirthday(data.birthDate!);
      if (birthdayResult.isFailure) {
        return birthdayResult;
      }
    }

    return const Success(null);
  }
}
