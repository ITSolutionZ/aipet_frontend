import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily Health Screen의 상태 데이터
class DailyHealthScreenData {
  final String? selectedPetId;

  const DailyHealthScreenData({
    this.selectedPetId,
  });

  DailyHealthScreenData copyWith({
    String? selectedPetId,
  }) {
    return DailyHealthScreenData(
      selectedPetId: selectedPetId ?? this.selectedPetId,
    );
  }
}

/// Daily Health Screen의 상태 관리 컨트롤러
class DailyHealthScreenController extends StateNotifier<DailyHealthScreenData> {
  final Ref ref;
  late final DailyHealthLogic _logic;

  DailyHealthScreenController(this.ref) : super(const DailyHealthScreenData()) {
    _logic = DailyHealthLogic();
    _initializePetSelection();
  }

  /// 로직 인스턴스 접근
  DailyHealthLogic get logic => _logic;

  /// 펫 선택 초기화
  void _initializePetSelection() {
    final pets = ref.read(petProfilesNotifierProvider).value;
    final selectedPetId = _logic.initializePetSelection(pets);
    if (selectedPetId != null) {
      state = state.copyWith(selectedPetId: selectedPetId);
    }
  }

  /// 선택된 펫 업데이트
  void updateSelectedPet(String? petId) {
    state = state.copyWith(selectedPetId: petId);
  }

  /// 펫 목록 새로고침
  void refreshPetSelection() {
    _initializePetSelection();
  }
}

/// Daily Health Screen Controller Provider
final dailyHealthScreenControllerProvider =
    StateNotifierProvider<DailyHealthScreenController, DailyHealthScreenData>(
  (ref) => DailyHealthScreenController(ref),
);