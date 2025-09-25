import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';

/// 산책에서 사용되는 펫 정보 엔티티
class PetInfo {
  final String id;
  final String name;
  final String type;
  final String? imageUrl;
  final DateTime? lastWalkTime;
  final bool isSelected;

  const PetInfo({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
    this.lastWalkTime,
    this.isSelected = false,
  });

  /// PetProfileEntity에서 PetInfo로 변환
  factory PetInfo.fromPetProfile(PetProfileEntity pet) {
    return PetInfo(
      id: pet.id,
      name: pet.name,
      type: pet.type.name,
      imageUrl: pet.imageUrl,
      lastWalkTime: null,
      isSelected: false,
    );
  }

  /// 선택 상태 변경
  PetInfo copyWith({
    String? id,
    String? name,
    String? type,
    String? imageUrl,
    DateTime? lastWalkTime,
    bool? isSelected,
  }) {
    return PetInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      lastWalkTime: lastWalkTime ?? this.lastWalkTime,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PetInfo(id: $id, name: $name, type: $type, isSelected: $isSelected)';
  }
}
