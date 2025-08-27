import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';

/// 급여 분석 컨트롤러
class FeedingAnalysisController extends StateNotifier<FeedingAnalysisState> {
  FeedingAnalysisController({required String petId})
    : super(FeedingAnalysisState(petId: petId)) {
    _loadAnalysisData();
  }

  /// 분석 데이터 로드
  void _loadAnalysisData() {
    final analysisData = MockDataService.getMockFeedingAnalysisData();
    state = state.copyWith(analysisData: analysisData);
  }

  /// 차트 데이터 가져오기
  Map<String, dynamic> getChartData() {
    return state.analysisData;
  }

  /// 현재 급여량 요약 데이터 가져오기
  Map<String, dynamic> getCurrentFeedingSummary() {
    final data = state.analysisData;
    return {
      'currentAmount': data['currentAmount'],
      'changeAmount': data['changeAmount'],
      'targetAmount': data['targetAmount'],
    };
  }

  /// 주간 급여 기록 가져오기
  List<Map<String, dynamic>> getWeeklyFeedingRecords() {
    final data = state.analysisData;
    return List<Map<String, dynamic>>.from(data['weeklyRecords'] ?? []);
  }

  /// 월간 급여 기록 가져오기
  List<Map<String, dynamic>> getMonthlyFeedingRecords() {
    final data = state.analysisData;
    return List<Map<String, dynamic>>.from(data['monthlyRecords'] ?? []);
  }

  /// 급여 패턴 분석 가져오기
  Map<String, dynamic> getFeedingPatternAnalysis() {
    final data = state.analysisData;
    return Map<String, dynamic>.from(data['patternAnalysis'] ?? {});
  }
}

/// 급여 분석 상태
class FeedingAnalysisState {
  final String petId;
  final Map<String, dynamic> analysisData;

  const FeedingAnalysisState({
    required this.petId,
    this.analysisData = const {},
  });

  FeedingAnalysisState copyWith({
    String? petId,
    Map<String, dynamic>? analysisData,
  }) {
    return FeedingAnalysisState(
      petId: petId ?? this.petId,
      analysisData: analysisData ?? this.analysisData,
    );
  }
}

/// 컨트롤러 프로바이더
final feedingAnalysisControllerProvider =
    StateNotifierProvider.family<
      FeedingAnalysisController,
      FeedingAnalysisState,
      String
    >((ref, petId) {
      return FeedingAnalysisController(petId: petId);
    });
