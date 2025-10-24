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

  const PetBasicInfoState({
    this.editingName = '',
    this.editingAppearance = '',
    this.editingWeightText = '',
    this.editingMicrochip = '',
    this.editingGender,
    this.editingWeight,
    this.selectedImagePath,
    this.editingHealthConditions = const [],
  });

  PetBasicInfoState copyWith({
    String? editingName,
    String? editingAppearance,
    String? editingWeightText,
    String? editingMicrochip,
    String? editingGender,
    double? editingWeight,
    String? selectedImagePath,
    List<String>? editingHealthConditions,
  }) {
    return PetBasicInfoState(
      editingName: editingName ?? this.editingName,
      editingAppearance: editingAppearance ?? this.editingAppearance,
      editingWeightText: editingWeightText ?? this.editingWeightText,
      editingMicrochip: editingMicrochip ?? this.editingMicrochip,
      editingGender: editingGender ?? this.editingGender,
      editingWeight: editingWeight ?? this.editingWeight,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      editingHealthConditions: editingHealthConditions ?? this.editingHealthConditions,
    );
  }
}
