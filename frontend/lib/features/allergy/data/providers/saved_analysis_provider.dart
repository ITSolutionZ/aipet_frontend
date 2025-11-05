import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import '../repositories/saved_analysis_repository.dart';


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
    final result = await repository.loadAll();

    // Result 패턴 처리
    return result.dataOr([]);
  }

  /// 분석 결과 저장
  Future<void> saveAnalysis(SavedAnalysisEntity analysis) async {
    final repository = ref.read(savedAnalysisRepositoryProvider);
    final result = await repository.save(analysis);

    if (result.isSuccess) {
      // 상태 새로고침
      ref.invalidateSelf();
    } else {
      throw Exception(result.message);
    }
  }

  /// 분석 결과 삭제
  Future<void> deleteAnalysis(String id) async {
    final repository = ref.read(savedAnalysisRepositoryProvider);
    final result = await repository.delete(id);

    if (result.isSuccess) {
      // 상태 새로고침
      ref.invalidateSelf();
    } else {
      throw Exception(result.message);
    }
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
    final result = await repository.deleteAll();

    if (result.isSuccess) {
      // 상태 새로고침
      ref.invalidateSelf();
    } else {
      throw Exception(result.message);
    }
  }
}
