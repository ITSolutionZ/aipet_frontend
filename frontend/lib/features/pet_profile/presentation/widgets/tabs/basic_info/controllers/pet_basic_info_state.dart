/// Pet Basic Info Tab 상태 클래스
///
/// TextEditingController를 State에서 제거하고 순수 데이터만 관리
class PetBasicInfoState {
  final String editingName;
  final String editingAppearance;
  final String editingWeightText;
  final String editingMicrochip;
  final String? editingGender;
  final double? editingWeight;
  final String? selectedImagePath;
  final List<String> editingHealthConditions;
  // 이미지 변경 추적을 위한 타임스탬프
  final int imageUpdateTimestamp;

  const PetBasicInfoState({
    this.editingName = '',
    this.editingAppearance = '',
    this.editingWeightText = '',
    this.editingMicrochip = '',
    this.editingGender,
    this.editingWeight,
    this.selectedImagePath,
    this.editingHealthConditions = const [],
    this.imageUpdateTimestamp = 0,
  });

  /// copyWith with explicit null handling for selectedImagePath
  PetBasicInfoState copyWith({
    String? editingName,
    String? editingAppearance,
    String? editingWeightText,
    String? editingMicrochip,
    String? editingGender,
    double? editingWeight,
    Object? selectedImagePath = _sentinel,
    List<String>? editingHealthConditions,
    int? imageUpdateTimestamp,
  }) {
    return PetBasicInfoState(
      editingName: editingName ?? this.editingName,
      editingAppearance: editingAppearance ?? this.editingAppearance,
      editingWeightText: editingWeightText ?? this.editingWeightText,
      editingMicrochip: editingMicrochip ?? this.editingMicrochip,
      editingGender: editingGender ?? this.editingGender,
      editingWeight: editingWeight ?? this.editingWeight,
      selectedImagePath: selectedImagePath == _sentinel
          ? this.selectedImagePath
          : selectedImagePath as String?,
      editingHealthConditions:
          editingHealthConditions ?? this.editingHealthConditions,
      imageUpdateTimestamp: imageUpdateTimestamp ?? this.imageUpdateTimestamp,
    );
  }
}

// Sentinel object for null handling in copyWith
const _sentinel = Object();
