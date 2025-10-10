import 'package:aipet_frontend/shared/core/domain/result.dart';

import '../entities/ai_analysis_entity.dart';
import '../entities/ai_chat_summary.dart';
import '../entities/ai_chat_summary_entity.dart';
import '../entities/ai_message_entity.dart';

/// AI 분석 관련 Repository
abstract class AiAnalysisRepository {
  /// 메시지 분석
  Future<Result<AiAnalysisEntity>> analyzeMessage({
    required String message,
    String? petId,
    Map<String, dynamic>? context,
  });

  /// 채팅 요약 생성
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  });

  /// AI 기반 채팅 요약 생성
  Future<AiChatSummary> generateChatSummary({
    required List<String> userMessages,
    required String petName,
    required String category,
  });

  /// 채팅 요약 목록 조회
  Future<List<AiChatSummaryEntity>> getChatSummaries({
    String? petId,
    String? category,
  });

  Future<void> deleteChatSummary(String summaryId);

  /// 대화 패턴 분석
  Future<ConversationPatternAnalysis> analyzeConversationPatterns({
    required List<AiMessageEntity> messages,
    String? petId,
  });

  /// 감정 분석
  Future<SentimentAnalysisResult> analyzeSentiment({
    required List<AiMessageEntity> messages,
    String? petId,
  });

  /// 주제 분석
  Future<TopicAnalysisResult> analyzeTopics({
    required List<AiMessageEntity> messages,
    String? petId,
  });

  /// 건강 관련 우려사항 분석
  Future<HealthConcernAnalysis> analyzeHealthConcerns({
    required List<AiMessageEntity> messages,
    required String petId,
  });

  /// 행동 패턴 분석
  Future<BehaviorPatternAnalysis> analyzeBehaviorPatterns({
    required List<AiMessageEntity> messages,
    required String petId,
  });

  /// 맞춤형 권장사항 생성
  Future<List<PersonalizedRecommendation>> generateRecommendations({
    required String petId,
    required List<AiMessageEntity> recentMessages,
    String? categoryId,
  });
}

/// 대화 패턴 분석 결과
class ConversationPatternAnalysis {
  final double averageMessageLength;
  final Map<String, int> timeDistribution;
  final List<String> frequentTopics;
  final int conversationDepth;

  const ConversationPatternAnalysis({
    required this.averageMessageLength,
    required this.timeDistribution,
    required this.frequentTopics,
    required this.conversationDepth,
  });
}

/// 감정 분석 결과
class SentimentAnalysisResult {
  final String overallSentiment;
  final double positiveScore;
  final double negativeScore;
  final double neutralScore;
  final List<EmotionDetection> emotionBreakdown;

  const SentimentAnalysisResult({
    required this.overallSentiment,
    required this.positiveScore,
    required this.negativeScore,
    required this.neutralScore,
    required this.emotionBreakdown,
  });
}

class EmotionDetection {
  final String emotion;
  final double confidence;
  final List<String> keywords;

  const EmotionDetection({
    required this.emotion,
    required this.confidence,
    required this.keywords,
  });
}

/// 주제 분석 결과
class TopicAnalysisResult {
  final String primaryTopic;
  final Map<String, double> topicDistribution;
  final List<String> emergingTopics;
  final int topicDiversity;

  const TopicAnalysisResult({
    required this.primaryTopic,
    required this.topicDistribution,
    required this.emergingTopics,
    required this.topicDiversity,
  });
}

/// 건강 우려사항 분석
class HealthConcernAnalysis {
  final List<HealthIssue> detectedIssues;
  final String riskLevel;
  final List<String> recommendations;
  final bool requiresVetConsultation;

  const HealthConcernAnalysis({
    required this.detectedIssues,
    required this.riskLevel,
    required this.recommendations,
    required this.requiresVetConsultation,
  });
}

class HealthIssue {
  final String symptom;
  final String severity;
  final double confidence;
  final List<String> relatedMessages;

  const HealthIssue({
    required this.symptom,
    required this.severity,
    required this.confidence,
    required this.relatedMessages,
  });
}

/// 행동 패턴 분석
class BehaviorPatternAnalysis {
  final List<BehaviorIssue> identifiedBehaviors;
  final String overallBehaviorTrend;
  final List<String> trainingRecommendations;
  final double improvementProbability;

  const BehaviorPatternAnalysis({
    required this.identifiedBehaviors,
    required this.overallBehaviorTrend,
    required this.trainingRecommendations,
    required this.improvementProbability,
  });
}

class BehaviorIssue {
  final String behavior;
  final String frequency;
  final String severity;
  final List<String> triggers;

  const BehaviorIssue({
    required this.behavior,
    required this.frequency,
    required this.severity,
    required this.triggers,
  });
}

/// 개인화된 권장사항
class PersonalizedRecommendation {
  final String title;
  final String description;
  final String category;
  final String priority;
  final List<String> actionItems;
  final String reasoning;

  const PersonalizedRecommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.actionItems,
    required this.reasoning,
  });
}
