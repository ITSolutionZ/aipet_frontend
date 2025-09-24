import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart';

/// 펫 등록 데이터를 PetProfileEntity로 변환하는 유틸리티
class PetRegistrationConverter {
  static int _idCounter = 100;

  /// PetRegistrationData를 PetProfileEntity로 변환
  static PetProfileEntity convertToProfile(PetRegistrationDataEntity data) {
    if (data.petName == null || data.selectedPetType == null) {
      throw ArgumentError('필수 정보가 누락되었습니다 (이름, 펫 타입)');
    }

    final birthDate =
        data.petBirthday ?? DateTime.now().subtract(const Duration(days: 365));

    return PetProfileEntity(
      id: (++_idCounter).toString(),
      name: data.petName!,
      type: data.selectedPetType!,
      breed: _getBreedString(data),
      birthDate: birthDate,
      gender: data.petGender ?? 'unknown',
      weight: data.petWeight ?? 0.0,
      imagePath: _getImagePath(data),
      ownerId: 'current_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      additionalInfo: _buildAdditionalInfo(data),
    );
  }

  /// 품종 문자열 생성
  static String _getBreedString(PetRegistrationDataEntity data) {
    if (data.customBreed?.isNotEmpty == true) {
      return data.customBreed!;
    }

    if (data.selectedPetType == 'dog' && data.selectedDogBreed != null) {
      return _convertDogBreedToDisplayName(data.selectedDogBreed!);
    }

    if (data.selectedPetType == 'cat' && data.selectedCatBreed != null) {
      return _convertCatBreedToDisplayName(data.selectedCatBreed!);
    }

    return '믹스';
  }

  /// 강아지 품종 표시명 변환
  static String _convertDogBreedToDisplayName(String breed) {
    const breedMap = {
      'shiba': '柴犬',
      'poodle': 'プードル',
      'pomeranian': 'ポメラニアン',
      'dachshund': 'ダックスフンド',
      'chiwawa': 'チワワ',
      'mixed': 'ミックス',
      'golden_retriever': 'ゴールデンレトリバー',
      'labrador': 'ラブラドール',
      'bulldog': 'ブルドッグ',
      'beagle': 'ビーグル',
      'german_shepherd': 'ジャーマンシェパード',
      'yorkshire_terrier': 'ヨークシャーテリア',
    };
    return breedMap[breed] ?? breed;
  }

  /// 고양이 품종 표시명 변환
  static String _convertCatBreedToDisplayName(String breed) {
    const breedMap = {
      'persian': 'ペルシャ',
      'maine_coon': 'メインクーン',
      'siamese': 'シャム',
      'ragdoll': 'ラグドール',
      'british_shorthair': 'ブリティッシュショートヘア',
      'scottish_fold': 'スコティッシュフォールド',
      'mixed': 'ミックス',
    };
    return breedMap[breed] ?? breed;
  }

  /// 이미지 경로 생성
  static String _getImagePath(PetRegistrationDataEntity data) {
    if (data.petImagePath != null && data.petImagePath!.isNotEmpty) {
      // 실제 이미지가 있는 경우 (String 경로 반환)
      return data.petImagePath!;
    }

    // 기본 이미지 경로 반환
    final petType = data.selectedPetType;
    final breed = data.selectedPetType == 'dog'
        ? data.selectedDogBreed
        : data.selectedCatBreed;

    if (petType == 'dog') {
      switch (breed) {
        case 'shiba':
          return 'assets/images/dogs/shiba.png';
        case 'poodle':
          return 'assets/images/dogs/poodle.jpg';
        case 'pomeranian':
          return 'assets/images/dogs/pomeranian.png';
        case 'dachshund':
          return 'assets/images/dogs/dachshund.png';
        case 'chiwawa':
          return 'assets/images/dogs/chiwawa.png';
        case 'mixed':
          return 'assets/images/dogs/mixed.png';
        default:
          return 'assets/images/dogs/dogs.png';
      }
    } else if (petType == 'cat') {
      return 'assets/images/cats/cat.png';
    }

    return 'assets/images/pets/default.png';
  }

  /// 등록 데이터 유효성 검사
  static bool isValidForRegistration(PetRegistrationDataEntity data) {
    return data.petName?.isNotEmpty == true &&
        data.selectedPetType?.isNotEmpty == true;
  }

  /// 등록 완료 여부 확인
  static bool isRegistrationComplete(PetRegistrationDataEntity data) {
    return data.petName?.isNotEmpty == true &&
        data.selectedPetType?.isNotEmpty == true &&
        data.petBirthday != null;
  }

  /// 추가 정보 빌드
  static Map<String, dynamic> _buildAdditionalInfo(
    PetRegistrationDataEntity data,
  ) {
    final additionalInfo = <String, dynamic>{};

    if (data.petArrivalDate != null) {
      additionalInfo['arrivalDate'] = data.petArrivalDate!.toIso8601String();
    }

    if (data.petSize != null) {
      additionalInfo['size'] = data.petSize;
    }

    if (data.petWeight != null) {
      additionalInfo['weight'] = data.petWeight;
    }

    if (data.petGender != null) {
      additionalInfo['gender'] = data.petGender;
    }

    if (data.isNeutered != null) {
      additionalInfo['isNeutered'] = data.isNeutered;
    }

    if (data.microchipNumber != null) {
      additionalInfo['microchipNumber'] = data.microchipNumber;
    }

    return additionalInfo;
  }
}
