import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_controller.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily Health Input 화면의 비즈니스 로직을 담당하는 클래스
class DailyHealthInputLogic {
  final Ref ref;
  final DailyHealthRecord? existingRecord;

  DailyHealthInputLogic({
    required this.ref,
    this.existingRecord,
  });

  /// 폼 초기화 데이터 생성
  DailyHealthFormData initializeFormData() {
    if (existingRecord != null) {
      return DailyHealthFormData.fromRecord(existingRecord!);
    }

    // 새 레코드의 경우 기본값으로 초기화
    final pets = ref.read(petProfilesNotifierProvider).value;
    final defaultPetId = pets != null && pets.isNotEmpty ? pets.first.id : null;

    return DailyHealthFormData.initial(defaultPetId: defaultPetId);
  }

  /// 헬스 레코드 저장/업데이트
  Future<void> saveHealthRecord(DailyHealthFormData formData) async {
    _validateFormData(formData);

    final record = _createHealthRecord(formData);
    final controller = ref.read(dailyHealthControllerProvider.notifier);

    if (existingRecord != null) {
      await controller.updateHealthRecord(record);
    } else {
      await controller.addHealthRecord(record);
    }
  }

  /// 폼 데이터 검증
  void _validateFormData(DailyHealthFormData formData) {
    if (formData.selectedPetId == null || formData.selectedPetId!.isEmpty) {
      throw Exception('ペットを選択してください');
    }
  }

  /// DailyHealthRecord 엔티티 생성
  DailyHealthRecord _createHealthRecord(DailyHealthFormData formData) {
    return DailyHealthRecord(
      id: existingRecord?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      petId: formData.selectedPetId!,
      date: existingRecord?.date ?? DateTime.now(),
      temperature: formData.temperature,
      overallHealth: formData.selectedHealthStatus,
      symptoms: formData.selectedSymptoms,
      notes: formData.notes?.isNotEmpty == true ? formData.notes : null,
      createdAt: existingRecord?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 성공 메시지 생성
  String getSuccessMessage() {
    return existingRecord != null ? '健康記録を更新しました' : '健康記録を追加しました';
  }

  /// 에러 메시지 생성
  String getErrorMessage(dynamic error) {
    return 'エラーが発生しました: $error';
  }

  /// 편집 모드 여부
  bool get isEditing => existingRecord != null;

  /// 앱바 타이틀 생성
  String get appBarTitle => isEditing ? '健康記録を編集' : '健康記録を追加';

  /// 저장 버튼 텍스트 생성
  String get saveButtonText => isEditing ? '記録を更新' : '記録を保存';
}

/// 폼 데이터를 관리하는 클래스
class DailyHealthFormData {
  final String? selectedPetId;
  final double? temperature;
  final HealthStatus selectedHealthStatus;
  final List<String> selectedSymptoms;
  final String? notes;

  const DailyHealthFormData({
    this.selectedPetId,
    this.temperature,
    required this.selectedHealthStatus,
    required this.selectedSymptoms,
    this.notes,
  });

  /// 기존 레코드로부터 폼 데이터 생성
  factory DailyHealthFormData.fromRecord(DailyHealthRecord record) {
    return DailyHealthFormData(
      selectedPetId: record.petId,
      temperature: record.temperature,
      selectedHealthStatus: record.overallHealth,
      selectedSymptoms: List.from(record.symptoms),
      notes: record.notes,
    );
  }

  /// 초기 폼 데이터 생성
  factory DailyHealthFormData.initial({String? defaultPetId}) {
    return DailyHealthFormData(
      selectedPetId: defaultPetId,
      selectedHealthStatus: HealthStatus.good,
      selectedSymptoms: [],
    );
  }

  /// 특정 필드를 업데이트한 새 인스턴스 생성
  DailyHealthFormData copyWith({
    String? selectedPetId,
    double? temperature,
    HealthStatus? selectedHealthStatus,
    List<String>? selectedSymptoms,
    String? notes,
  }) {
    return DailyHealthFormData(
      selectedPetId: selectedPetId ?? this.selectedPetId,
      temperature: temperature ?? this.temperature,
      selectedHealthStatus: selectedHealthStatus ?? this.selectedHealthStatus,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      notes: notes ?? this.notes,
    );
  }
}