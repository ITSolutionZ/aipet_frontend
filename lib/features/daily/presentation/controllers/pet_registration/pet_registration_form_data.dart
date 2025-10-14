/// 펫 등록 폼 데이터 모델
class PetRegistrationFormData {
  /// 기본 초기 폼 데이터
  static const PetRegistrationFormData initialFormData =
      PetRegistrationFormData(
        petName: '',
        petType: 'dog',
        breed: 'ゴールデンレトリバー',
        gender: 'オス',
        isNeutered: false,
        guardianName: '',
        institutionName: '',
        registrationNumber: '',
        registrationImagePath: null,
        isProcessingOCR: false,
      );

  final String petName;
  final DateTime? birthDate;
  final DateTime? adoptionDate;
  final double? weight;
  final String petType;
  final String breed;
  final String gender;
  final bool isNeutered;
  final String guardianName;
  final String institutionName;
  final String registrationNumber;
  final String? petImagePath;
  final String? registrationImagePath;
  final bool isProcessingOCR;
  final bool isImageLoading;
  final List<String> forbiddenIngredients;
  final String bodyPartsToManage;
  final String food;
  final String supplement;
  final String treat;

  const PetRegistrationFormData({
    required this.petName,
    this.birthDate,
    this.adoptionDate,
    this.weight,
    required this.petType,
    required this.breed,
    required this.gender,
    required this.isNeutered,
    required this.guardianName,
    required this.institutionName,
    required this.registrationNumber,
    this.petImagePath,
    this.registrationImagePath,
    this.isProcessingOCR = false,
    this.isImageLoading = false,
    this.forbiddenIngredients = const [],
    this.bodyPartsToManage = '',
    this.food = '',
    this.supplement = '',
    this.treat = '',
  });

  PetRegistrationFormData copyWith({
    String? petName,
    DateTime? birthDate,
    DateTime? adoptionDate,
    double? weight,
    String? petType,
    String? breed,
    String? gender,
    bool? isNeutered,
    String? guardianName,
    String? institutionName,
    String? registrationNumber,
    String? petImagePath,
    String? registrationImagePath,
    bool? isProcessingOCR,
    bool? isImageLoading,
    List<String>? forbiddenIngredients,
    String? bodyPartsToManage,
    String? food,
    String? supplement,
    String? treat,
    bool clearPetImage = false,
    bool clearRegistrationImage = false,
  }) {
    return PetRegistrationFormData(
      petName: petName ?? this.petName,
      birthDate: birthDate ?? this.birthDate,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      weight: weight ?? this.weight,
      petType: petType ?? this.petType,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      isNeutered: isNeutered ?? this.isNeutered,
      guardianName: guardianName ?? this.guardianName,
      institutionName: institutionName ?? this.institutionName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      petImagePath: clearPetImage ? null : (petImagePath ?? this.petImagePath),
      registrationImagePath: clearRegistrationImage
          ? null
          : (registrationImagePath ?? this.registrationImagePath),
      isProcessingOCR: isProcessingOCR ?? this.isProcessingOCR,
      isImageLoading: isImageLoading ?? this.isImageLoading,
      forbiddenIngredients: forbiddenIngredients ?? this.forbiddenIngredients,
      bodyPartsToManage: bodyPartsToManage ?? this.bodyPartsToManage,
      food: food ?? this.food,
      supplement: supplement ?? this.supplement,
      treat: treat ?? this.treat,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'petName': petName,
      'birthDate': birthDate?.toIso8601String(),
      'adoptionDate': adoptionDate?.toIso8601String(),
      'weight': weight,
      'petType': petType,
      'breed': breed,
      'gender': gender,
      'isNeutered': isNeutered,
      'guardianName': guardianName,
      'institutionName': institutionName,
      'registrationNumber': registrationNumber,
      'petImagePath': petImagePath,
      'registrationImagePath': registrationImagePath,
      'forbiddenIngredients': forbiddenIngredients,
      'bodyPartsToManage': bodyPartsToManage,
      'food': food,
      'supplement': supplement,
      'treat': treat,
    };
  }

  /// JSON 역직렬화
  factory PetRegistrationFormData.fromJson(Map<String, dynamic> json) {
    return PetRegistrationFormData(
      petName: json['petName'] ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      adoptionDate: json['adoptionDate'] != null
          ? DateTime.parse(json['adoptionDate'])
          : null,
      weight: json['weight']?.toDouble(),
      petType: json['petType'] ?? 'dog',
      breed: json['breed'] ?? '',
      gender: json['gender'] ?? '',
      isNeutered: json['isNeutered'] ?? false,
      guardianName: json['guardianName'] ?? '',
      institutionName: json['institutionName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      petImagePath: json['petImagePath'],
      registrationImagePath: json['registrationImagePath'],
      forbiddenIngredients: List<String>.from(
        json['forbiddenIngredients'] ?? [],
      ),
      bodyPartsToManage: json['bodyPartsToManage'] ?? '',
      food: json['food'] ?? '',
      supplement: json['supplement'] ?? '',
      treat: json['treat'] ?? '',
    );
  }
}
