import '../entities/pet_registration_data_entity.dart';

/// 펫 등록 검증 서비스 인터페이스
/// Domain Layer의 비즈니스 로직을 정의
abstract class PetValidationService {
  /// 다음 단계로 이동할 수 있는지 확인
  bool canProceedToNextStep(PetRegistrationDataEntity data, int currentStep);

  /// 등록이 완료 상태인지 확인 (모든 필수 정보가 입력되었는지)
  bool isRegistrationComplete(PetRegistrationDataEntity data);

  /// 현재 단계 이후에 더 많은 데이터가 있는지 확인
  bool hasDataBeyondStep(PetRegistrationDataEntity data, int currentStep);

  /// 현재 선택된 품종 반환 (일반 품종 또는 커스텀 품종)
  String? getCurrentBreed(PetRegistrationDataEntity data);

  /// 펫 이름 유효성 검증
  bool isValidPetName(String? name);

  /// 체중 유효성 검증
  bool isValidWeight(double? weight);

  /// 마이크로칩 번호 유효성 검증
  bool isValidMicrochipNumber(String? number);
}

