/// 🔍 AI 분석 결과 엔티티
class AiAnalysisEntity {
  final String id;
  final String originalMessage;
  final String analysis;
  final List<String> topics;
  final double confidenceScore;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const AiAnalysisEntity({
    required this.id,
    required this.originalMessage,
    required this.analysis,
    required this.topics,
    required this.confidenceScore,
    this.metadata,
    required this.timestamp,
  });

  factory AiAnalysisEntity.fromMessage({
    required String message,
    required String analysis,
    List<String>? topics,
    double? confidenceScore,
  }) {
    return AiAnalysisEntity(
      id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      originalMessage: message,
      analysis: analysis,
      topics: topics ?? ['일반'],
      confidenceScore: confidenceScore ?? 0.8,
      timestamp: DateTime.now(),
    );
  }

  /// 높은 신뢰도인지 확인
  bool get isHighConfidence => confidenceScore > 0.8;

  /// 주요 주제들을 문자열로 변환
  String get topicsAsString => topics.join(', ');
}