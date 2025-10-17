import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_analysis_entity.freezed.dart';

/// 저장된 알레르기 분석 결과 엔티티
@freezed
class SavedAnalysisEntity with _$SavedAnalysisEntity {
  const factory SavedAnalysisEntity({
    /// ID
    required String id,

    /// 펫 ID
    required String petId,

    /// 펫 이름
    required String petName,

    /// 분석 결과
    required Map<String, dynamic> analysisResult,

    /// 저장 일시
    required DateTime savedAt,
  }) = _SavedAnalysisEntity;

  const SavedAnalysisEntity._();
}
