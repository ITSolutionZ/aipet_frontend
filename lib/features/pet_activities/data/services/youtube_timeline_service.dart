import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import 'youtube_api_service.dart';

/// 유튜브 비디오 타임라인 서비스
///
/// 유튜브 비디오에서 타임라인 섹션을 추출하고 관리하는 서비스입니다.
class YouTubeTimelineService {
  /// 유튜브 비디오에서 타임라인 섹션 추출
  Future<Result<List<YouTubeTimelineEntity>>> extractTimelineSections({
    required String videoId,
  }) async {
    try {
      final apiKey = AppConfig.current.youtubeApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_YOUTUBE_API_KEY_HERE') {
        if (AppConfig.current.isMockMode) {
          return _getMockTimelineSections(videoId);
        }
        // API 키가 없어도 Mock 데이터 반환
        return _getMockTimelineSections(videoId);
      }

      // YouTube API를 통해 타임라인 섹션 추출
      final timelineSections =
          await YouTubeApiService.extractTimelineFromDescription(videoId);

      if (timelineSections.isEmpty) {
        // 타임라인이 없는 경우 Mock 데이터 반환
        return _getMockTimelineSections(videoId);
      }

      return Result.success('타임라인 섹션을 성공적으로 추출했습니다', timelineSections);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('YouTube 타임라인 추출 에러: $error');
        debugPrint('StackTrace: $stackTrace');
      }
      return Result.failure(
        '타임라인 섹션을 추출하는 중 오류가 발생했습니다',
        error is Exception ? error : Exception(error.toString()),
      );
    }
  }

  // 사용하지 않는 메서드 - YouTubeApiService로 대체됨
  // Future<Map<String, dynamic>?> _getVideoInfo(...) { ... }

  // 사용하지 않는 메서드들 - YouTubeApiService로 대체됨
  /*
  Future<List<YouTubeTimelineEntity>> _extractTimelineFromDescription(...) async {
    // ... 기존 구현
  }

  String _extractSectionTitle(...) {
    // ... 기존 구현
  }
  */

  /// 기본 섹션들 생성
  List<YouTubeTimelineEntity> _generateDefaultSections(String videoId) {
    final now = DateTime.now();
    return [
      YouTubeTimelineEntity(
        id: '${videoId}_intro',
        videoId: videoId,
        title: '소개',
        description: '비디오 소개 부분',
        startTimeSec: 0,
        endTimeSec: 30,
        createdAt: now,
        updatedAt: now,
      ),
      YouTubeTimelineEntity(
        id: '${videoId}_main',
        videoId: videoId,
        title: '메인 내용',
        description: '핵심 학습 내용',
        startTimeSec: 30,
        endTimeSec: 180,
        createdAt: now,
        updatedAt: now,
      ),
      YouTubeTimelineEntity(
        id: '${videoId}_summary',
        videoId: videoId,
        title: '요약',
        description: '학습 내용 요약',
        startTimeSec: 180,
        endTimeSec: 240,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Mock 타임라인 섹션 데이터
  Result<List<YouTubeTimelineEntity>> _getMockTimelineSections(String videoId) {
    final now = DateTime.now();
    final sections = [
      YouTubeTimelineEntity(
        id: '${videoId}_intro',
        videoId: videoId,
        title: '소개 및 준비',
        description: '펫 트릭 학습을 위한 준비 과정',
        startTimeSec: 0,
        endTimeSec: 45,
        createdAt: now,
        updatedAt: now,
      ),
      YouTubeTimelineEntity(
        id: '${videoId}_basic',
        videoId: videoId,
        title: '기본 트릭 - 앉기',
        description: '펫에게 앉기를 가르치는 방법',
        startTimeSec: 45,
        endTimeSec: 120,
        createdAt: now,
        updatedAt: now,
      ),
      YouTubeTimelineEntity(
        id: '${videoId}_advanced',
        videoId: videoId,
        title: '고급 트릭 - 손바닥',
        description: '펫에게 손바닥을 가르치는 방법',
        startTimeSec: 120,
        endTimeSec: 180,
        createdAt: now,
        updatedAt: now,
      ),
      YouTubeTimelineEntity(
        id: '${videoId}_tips',
        videoId: videoId,
        title: '팁과 주의사항',
        description: '성공적인 트릭 학습을 위한 팁',
        startTimeSec: 180,
        endTimeSec: 240,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    return Result.success('Mock 타임라인 섹션을 생성했습니다', sections);
  }
}
