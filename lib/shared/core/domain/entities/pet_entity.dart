/// 공유 Pet 엔티티
///
/// 모든 기능에서 공통으로 사용하는 Pet 정보를 정의합니다.
/// pet_registor 기능에 대한 의존성을 제거하고 순환 참조를 방지합니다.
class PetEntity {
  final String id;
  final String name;
  final String type; // 'dog' | 'cat'
  final String? breed;
  final String? gender; // 'male' | 'female'
  final String? size; // 'small' | 'medium' | 'large'
  final double? weight;
  final DateTime? birthDate;
  final String? imagePath;
  final String? microchipId;
  final DateTime? adoptionDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetEntity({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    this.gender,
    this.size,
    this.weight,
    this.birthDate,
    this.imagePath,
    this.microchipId,
    this.adoptionDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 나이 계산 (개월 수)
  int? get ageInMonths {
    if (birthDate == null) return null;
    final now = DateTime.now();
    final difference = now.difference(birthDate!);
    return (difference.inDays / 30.44).round(); // 평균 월일 수
  }

  /// 나이 계산 (년 수)
  int? get ageInYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  /// 나이 표시 문자열
  String get ageDisplay {
    if (birthDate == null) return '알 수 없음';

    final years = ageInYears!;
    final months = ageInMonths! % 12;

    if (years == 0) {
      return '$months개월';
    } else if (months == 0) {
      return '$years세';
    } else {
      return '$years세 $months개월';
    }
  }

  /// 성별 표시 문자열
  String get genderDisplay {
    switch (gender) {
      case 'male':
        return '수컷';
      case 'female':
        return '암컷';
      default:
        return '알 수 없음';
    }
  }

  /// 크기 표시 문자열
  String get sizeDisplay {
    switch (size) {
      case 'small':
        return '소형';
      case 'medium':
        return '중형';
      case 'large':
        return '대형';
      default:
        return '알 수 없음';
    }
  }

  /// 타입 표시 문자열
  String get typeDisplay {
    switch (type) {
      case 'dog':
        return '강아지';
      case 'cat':
        return '고양이';
      default:
        return type;
    }
  }

  /// 복사본 생성
  PetEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    String? gender,
    String? size,
    double? weight,
    DateTime? birthDate,
    String? imagePath,
    String? microchipId,
    DateTime? adoptionDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      imagePath: imagePath ?? this.imagePath,
      microchipId: microchipId ?? this.microchipId,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'gender': gender,
      'size': size,
      'weight': weight,
      'birthDate': birthDate?.toIso8601String(),
      'imagePath': imagePath,
      'microchipId': microchipId,
      'adoptionDate': adoptionDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory PetEntity.fromJson(Map<String, dynamic> json) {
    return PetEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String?,
      gender: json['gender'] as String?,
      size: json['size'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
      microchipId: json['microchipId'] as String?,
      adoptionDate: json['adoptionDate'] != null
          ? DateTime.parse(json['adoptionDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PetEntity(id: $id, name: $name, type: $type)';
  }
}

/// Pet 타입 enum
enum PetType {
  dog('dog', '강아지'),
  cat('cat', '고양이');

  const PetType(this.value, this.displayName);

  final String value;
  final String displayName;

  static PetType? fromString(String value) {
    return PetType.values.where((type) => type.value == value).firstOrNull;
  }
}

/// Pet 성별 enum
enum PetGender {
  male('male', '수컷'),
  female('female', '암컷');

  const PetGender(this.value, this.displayName);

  final String value;
  final String displayName;

  static PetGender? fromString(String value) {
    return PetGender.values.where((gender) => gender.value == value).firstOrNull;
  }
}

/// Pet 크기 enum
enum PetSize {
  small('small', '소형'),
  medium('medium', '중형'),
  large('large', '대형');

  const PetSize(this.value, this.displayName);

  final String value;
  final String displayName;

  static PetSize? fromString(String value) {
    return PetSize.values.where((size) => size.value == value).firstOrNull;
  }
}