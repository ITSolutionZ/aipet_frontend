import 'package:aipet_frontend/features/pet_activities/data/services/pet_activities_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';

/// 비디오 리포지토리 헬퍼
class VideoRepositoryHelper {
  /// 모든 YouTube 비디오 가져오기
  static Future<List<YouTubeVideoEntity>> getAllYouTubeVideos() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final videosData =
        await PetActivitiesLocalStorageService.getYouTubeVideos();

    return videosData
        .map((videoData) => _mapVideoDataToEntity(videoData))
        .toList();
  }

  /// 특정 펫의 YouTube 비디오 가져오기
  static Future<List<YouTubeVideoEntity>> getYouTubeVideosByPetId(
    String petId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final videosData = await PetActivitiesLocalStorageService.getYouTubeVideos(
      petId: petId,
    );

    return videosData
        .map((videoData) => _mapVideoDataToEntity(videoData))
        .toList();
  }

  /// YouTube 비디오 추가
  static Future<void> addYouTubeVideo(YouTubeVideoEntity video) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final videoData = {
      'id': video.id,
      'title': video.title,
      'description': video.description,
      'url': video.youtubeUrl,
      'thumbnail': video.thumbnailUrl,
      'duration': video.durationSeconds,
      'tags': video.tags,
      'petId': video.petId,
      'createdAt': video.createdAt.toIso8601String(),
      'updatedAt': video.updatedAt.toIso8601String(),
    };

    await PetActivitiesLocalStorageService.addYouTubeVideo(videoData);
  }

  /// YouTube 비디오 업데이트
  static Future<void> updateYouTubeVideo(
    String videoId,
    YouTubeVideoEntity updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final updateData = {
      'id': videoId,
      'title': updates.title,
      'description': updates.description,
      'url': updates.youtubeUrl,
      'thumbnail': updates.thumbnailUrl,
      'duration': updates.durationSeconds,
      'tags': updates.tags,
      'petId': updates.petId,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await PetActivitiesLocalStorageService.updateYouTubeVideo(
      videoId,
      updateData,
    );
  }

  /// YouTube 비디오 삭제
  static Future<void> deleteYouTubeVideo(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await PetActivitiesLocalStorageService.deleteYouTubeVideo(videoId);
  }

  /// 비디오 검색
  static Future<List<YouTubeVideoEntity>> searchVideos(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final videosData = await PetActivitiesLocalStorageService.searchVideos(
      query,
    );
    return videosData
        .map((videoData) => _mapVideoDataToEntity(videoData))
        .toList();
  }

  /// 비디오 통계
  static Future<Map<String, int>> getVideoStats({String? petId}) async {
    return PetActivitiesLocalStorageService.getVideoStats(petId: petId);
  }

  /// 비디오 진행률 가져오기
  static Future<VideoProgressEntity?> getVideoProgress(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final progressData =
        await PetActivitiesLocalStorageService.getVideoProgress(videoId);

    if (progressData['currentPosition'] == 0 &&
        progressData['totalDuration'] == 0) {
      return null;
    }

    final currentPos = progressData['currentPosition'] ?? 0;
    final totalDur = progressData['totalDuration'] ?? 0;

    return VideoProgressEntity(
      videoId: videoId,
      currentPositionSec: currentPos,
      totalDurationSec: totalDur,
      progress: totalDur > 0 ? currentPos / totalDur : 0.0,
      lastWatchedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 비디오 진행률 저장
  static Future<void> saveVideoProgress(VideoProgressEntity progress) async {
    await Future.delayed(const Duration(milliseconds: 100));

    await PetActivitiesLocalStorageService.saveVideoProgress(
      progress.videoId,
      progress.currentPositionSec,
      progress.totalDurationSec,
    );
  }

  /// 비디오 데이터를 엔티티로 매핑
  static YouTubeVideoEntity _mapVideoDataToEntity(
    Map<String, dynamic> videoData,
  ) {
    final url = videoData['url'] as String;
    final videoId = YouTubeVideoEntity.extractVideoId(url) ?? '';

    return YouTubeVideoEntity(
      id: videoData['id'] as String,
      youtubeUrl: url,
      youtubeVideoId: videoId,
      title: videoData['title'] as String,
      description: videoData['description'] as String?,
      thumbnailUrl: videoData['thumbnail'] as String?,
      durationSeconds: videoData['duration'] as int? ?? 0,
      petId: videoData['petId'] as String? ?? 'default',
      tags: (videoData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(videoData['createdAt'] as String),
      updatedAt: videoData['updatedAt'] != null
          ? DateTime.parse(videoData['updatedAt'] as String)
          : DateTime.parse(videoData['createdAt'] as String),
    );
  }
}
