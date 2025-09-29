import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 펫 검증 서비스 인터페이스
abstract class PetValidationService {
  /// 펫 이름 검증
  Future<Result<void>> validatePetName(String name);

  /// 펫 몸무게 검증
  Future<Result<void>> validateWeight(double weight);

  /// 마이크로칩 번호 검증
  Future<Result<void>> validateMicrochipNumber(String microchipNumber);

  /// 생년월일 검증
  Future<Result<void>> validateBirthday(DateTime birthday);

  /// 전체 펫 데이터 검증
  Future<Result<void>> validatePetData(PetRegistrationDataEntity data);
}
