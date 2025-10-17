import 'package:aipet_frontend/features/allergy/data/repositories/saved_analysis_repository.dart';
import 'package:aipet_frontend/features/allergy/domain/entities/saved_analysis_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_analysis_provider.g.dart';

/// 저장된 알레르기 분석 Repository Provider
@riverpod
SavedAnalysisRepository savedAnalysisRepository(Ref ref) {
  return SavedAnalysisRepository();
}

/// 저장된 알레르기 분석 결과를 관리하는 Provider
@riverpod
class SavedAnalysisNotifier extends _$SavedAnalysisNotifier {
  @override
  Future<List<SavedAnalysisEntity>> build() async {
    // 앱 시작 시 로컬에서 로드
    final repository = ref.read(savedAnalysisRepositoryProvider);
    final localData = await repository.loadAll();

    // 로컬 데이터 반환 (빈 리스트도 그대로 반환)
    return localData;
  }

  /// 분석 결과 저장
  Future<void> saveAnalysis(SavedAnalysisEntity analysis) async {
    final repository = ref.read(savedAnalysisRepositoryProvider);
    await repository.save(analysis);

    // 상태 새로고침
    ref.invalidateSelf();
  }

  /// 분석 결과 삭제
  Future<void> deleteAnalysis(String id) async {
    final repository = ref.read(savedAnalysisRepositoryProvider);
    await repository.delete(id);

    // 상태 새로고침
    ref.invalidateSelf();
  }

  /// 특정 펫의 분석 결과만 가져오기
  List<SavedAnalysisEntity> getByPetId(String petId) {
    return state.when(
      data: (analyses) =>
          analyses.where((analysis) => analysis.petId == petId).toList(),
      loading: () => [],
      error: (error, stackTrace) => [],
    );
  }

  /// 모든 분석 결과 삭제
  Future<void> clearAll() async {
    final repository = ref.read(savedAnalysisRepositoryProvider);
    await repository.deleteAll();

    // 상태 새로고침
    ref.invalidateSelf();
  }
}
