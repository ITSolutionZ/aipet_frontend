import '../../../../shared/shared.dart';

import '../../../../../features/walk/domain/entities/walk_recommendation_entity.dart';
import '../../../../../features/walk/domain/usecases/compute_walk_recommendation_usecase.dart';

/// 산책 추천 서비스
class WalkRecommendationService {
  final ComputeWalkRecommendationUseCase _computeUseCase =
      ComputeWalkRecommendationUseCase();

  /// 펫과 날씨 정보를 바탕으로 산책 추천 계산
  Future<WalkRecommendationEntity> getRecommendation({
    required PetProfileEntity pet,
    required double wbgt,
    double? temperature,
  }) async {
    return _computeUseCase.call(pet: pet, wbgt: wbgt, temperature: temperature);
  }

  /// AI 컨텍스트용 산책 가이드 텍스트 생성
  String generateAiContext({
    required WalkRecommendationEntity recommendation,
    required String weatherAdvice,
    String? petName,
  }) {
    final buffer = StringBuffer();

    // 펫 이름
    if (petName != null) {
      buffer.writeln('【$petNameの散歩ガイド】');
    } else {
      buffer.writeln('【散歩ガイド】');
    }

    // 권장 시간
    buffer.writeln('推奨時間: ${recommendation.timeRangeText}');

    // 위험 레벨
    buffer.writeln(
      'リスクレベル: ${recommendation.riskLevelText} ${recommendation.recommendationEmoji}',
    );

    // 메시지
    buffer.writeln('アドバイス: ${recommendation.message}');

    // 경고사항
    if (recommendation.warnings.isNotEmpty) {
      buffer.writeln('\n注意事項:');
      for (final warning in recommendation.warnings) {
        buffer.writeln('• $warning');
      }
    }

    // 날씨 어드바이스 추가
    buffer.writeln('\n【天気情報】');
    buffer.writeln(weatherAdvice);

    return buffer.toString();
  }

  /// 간단한 산책 가이드 텍스트 (한 줄)
  String generateShortGuide(WalkRecommendationEntity recommendation) {
    return '${recommendation.recommendationEmoji} ${recommendation.timeRangeText} - ${recommendation.message}';
  }

  /// 위험도가 높을 때 경고 메시지
  String? getWarningMessage(WalkRecommendationEntity recommendation) {
    if (recommendation.isDangerous) {
      return '${recommendation.recommendationEmoji} ${recommendation.message}';
    }
    return null;
  }
}
