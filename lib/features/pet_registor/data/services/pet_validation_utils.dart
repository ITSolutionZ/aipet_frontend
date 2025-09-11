import '../../domain/entities/pet_registration_data_entity.dart';
import 'pet_validation_service_impl.dart';

/// 펫 검증 유틸리티 클래스
/// 기존 코드와의 호환성을 위한 정적 메서드 제공
class PetValidationUtils {
  static final PetValidationServiceImpl _service = PetValidationServiceImpl();

  /// 다음 단계로 이동할 수 있는지 확인
  static bool canProceedToNextStep(PetRegistrationDataEntity data, int currentStep) =>
      _service.canProceedToNextStep(data, currentStep);

  /// 등록이 완료 상태인지 확인 (모든 필수 정보가 입력되었는지)
  static bool isRegistrationComplete(PetRegistrationDataEntity data) =>
      _service.isRegistrationComplete(data);

  /// 현재 단계 이후에 더 많은 데이터가 있는지 확인
  static bool hasDataBeyondStep(PetRegistrationDataEntity data, int currentStep) =>
      _service.hasDataBeyondStep(data, currentStep);

  /// 현재 선택된 품종 반환 (일반 품종 또는 커스텀 품종)
  static String? getCurrentBreed(PetRegistrationDataEntity data) =>
      _service.getCurrentBreed(data);

  /// 펫 이름 유효성 검증
  static bool isValidPetName(String? name) =>
      _service.isValidPetName(name);

  /// 체중 유효성 검증
  static bool isValidWeight(double? weight) =>
      _service.isValidWeight(weight);

  /// 마이크로칩 번호 유효성 검증
  static bool isValidMicrochipNumber(String? number) =>
      _service.isValidMicrochipNumber(number);
}