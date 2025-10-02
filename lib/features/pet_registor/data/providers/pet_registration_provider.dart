import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 등록 상태 프로바이더
final petRegistrationStateProvider =
    StateNotifierProvider<PetRegistrationNotifier, PetRegistrationDataEntity>((ref) {
      return PetRegistrationNotifier();
    });

/// 펫 등록 상태 관리
class PetRegistrationNotifier extends StateNotifier<PetRegistrationDataEntity> {
  PetRegistrationNotifier() : super(const PetRegistrationDataEntity());

  /// 펫 타입 설정
  void setPetType(String type) {
    state = state.copyWith(type: type);
  }

  /// 펫 품종 설정
  void setPetBreed(String breed) {
    state = state.copyWith(breed: breed);
  }

  /// 펫 이름 설정
  void setPetName(String name) {
    state = state.copyWith(name: name);
  }

  /// 펫 크기 설정
  void setPetSize(String size) {
    state = state.copyWith(additionalInfo: {...?state.additionalInfo, 'size': size});
  }

  /// 펫 몸무게 설정
  void setPetWeight(double weight) {
    state = state.copyWith(additionalInfo: {...?state.additionalInfo, 'weight': weight});
  }

  /// 펫 성별 설정
  void setPetGender(String gender) {
    state = state.copyWith(additionalInfo: {...?state.additionalInfo, 'gender': gender});
  }

  /// 펫 생년월일 설정
  void setPetBirthday(DateTime birthday) {
    state = state.copyWith(birthDate: birthday);
  }

  /// 펫 도착일 설정
  void setPetArrivalDate(DateTime arrivalDate) {
    state = state.copyWith(
      additionalInfo: {...?state.additionalInfo, 'arrivalDate': arrivalDate.toIso8601String()},
    );
  }

  /// 중성화 여부 설정
  void setNeutered(bool isNeutered) {
    state = state.copyWith(additionalInfo: {...?state.additionalInfo, 'isNeutered': isNeutered});
  }

  /// 펫 이미지 경로 설정
  void setPetImagePath(String? imagePath) {
    state = state.copyWith(imagePath: imagePath);
  }

  /// 마이크로칩 번호 설정
  void setMicrochipNumber(String? microchipNumber) {
    state = state.copyWith(
      additionalInfo: {...?state.additionalInfo, 'microchipNumber': microchipNumber},
    );
  }

  /// 커스텀 기본 이미지 경로 설정
  void setCustomDefaultImagePath(String imagePath) {
    state = state.copyWith(
      additionalInfo: {...?state.additionalInfo, 'customDefaultImagePath': imagePath},
    );
  }

  /// 상태 초기화
  void reset() {
    state = const PetRegistrationDataEntity();
  }

  /// 특정 필드만 초기화
  void resetField(String fieldName) {
    switch (fieldName) {
      case 'type':
        state = state.copyWith(type: null);
        break;
      case 'breed':
        state = state.copyWith(breed: null);
        break;
      case 'name':
        state = state.copyWith(name: null);
        break;
      case 'birthDate':
        state = state.copyWith(birthDate: null);
        break;
      case 'imagePath':
        state = state.copyWith(imagePath: null);
        break;
      default:
        // additionalInfo에서 제거
        final newAdditionalInfo = Map<String, dynamic>.from(state.additionalInfo ?? {});
        newAdditionalInfo.remove(fieldName);
        state = state.copyWith(additionalInfo: newAdditionalInfo);
    }
  }

  /// 펫 타입 선택 (레거시 호환)
  void selectPetType(String type) {
    setPetType(type);
  }

  /// 강아지 품종 선택 (레거시 호환)
  void selectDogBreed(String breed) {
    setPetBreed(breed);
  }

  /// 고양이 품종 선택 (레거시 호환)
  void selectCatBreed(String breed) {
    setPetBreed(breed);
  }

  /// 커스텀 품종 설정 (레거시 호환)
  void setCustomBreed(String customBreed) {
    setPetBreed(customBreed);
  }

  /// 펫 크기/체중 설정
  void setPetSizeWeight({String? size, double? weight}) {
    state = state.copyWith(petSize: size, petWeight: weight);
  }

  /// 펫 성별 및 중성화 상태 설정
  void setPetGenderInfo({String? gender, bool? isNeutered}) {
    state = state.copyWith(petGender: gender, isNeutered: isNeutered);
  }
}
