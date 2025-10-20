import 'package:aipet_frontend/shared/domain/entities/entities.dart';

/// 산책에서 사용되는 펫 정보 엔티티
class WalkPetInfo {
  final String id;
  final String name;
  final String type;
  final String? imageUrl;
  final DateTime? lastWalkTime;
  final bool isSelected;

  const WalkPetInfo({
    required this.id,
    required this.name,
    required this.type,
    this.imageUrl,
    this.lastWalkTime,
    this.isSelected = false,
  });

  /// PetProfileEntity에서 WalkPetInfo로 변환
  factory WalkPetInfo.fromPetProfile(PetProfileEntity pet) {
    return WalkPetInfo(
      id: pet.id,
      name: pet.name,
      type: pet.type, // type은 이미 String입니다
      imageUrl: pet.imagePath, // imagePath -> imageUrl
      lastWalkTime: null,
      isSelected: false,
    );
  }

  /// 선택 상태 변경
  WalkPetInfo copyWith({
    String? id,
    String? name,
    String? type,
    String? imageUrl,
    DateTime? lastWalkTime,
    bool? isSelected,
  }) {
    return WalkPetInfo(
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
    return other is WalkPetInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WalkPetInfo(id: $id, name: $name, type: $type, isSelected: $isSelected)';
  }
}
