import 'package:aipet_frontend/features/pet_activities/data/repositories/helpers/bookmark_repository_helper.dart';
import 'package:aipet_frontend/features/pet_activities/data/repositories/helpers/trick_repository_helper.dart';
import 'package:aipet_frontend/features/pet_activities/data/repositories/helpers/video_repository_helper.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart';

/// 펫 활동 리포지토리 구현 (리팩토링됨)
class PetActivitiesRepositoryImpl implements PetActivitiesRepository {
  PetActivitiesRepositoryImpl();

  // ========== 트릭 관련 메서드 (헬퍼 위임) ==========

  @override
  Future<List<TrickEntity>> getAllTricks() async {
    return TrickRepositoryHelper.getAllTricks();
  }

  @override
  Future<List<TrickEntity>> getTricksByPetId(String petId) async {
    return TrickRepositoryHelper.getTricksByPetId(petId);
  }

  @override
  Future<TrickEntity> addTrick(TrickEntity trick) async {
    await TrickRepositoryHelper.addTrick(trick);
    return trick;
  }

  @override
  Future<TrickEntity> updateTrick(TrickEntity trick) async {
    await TrickRepositoryHelper.updateTrick(trick.id, trick);
    return trick;
  }

  @override
  Future<void> deleteTrick(String trickId) async {
    return TrickRepositoryHelper.deleteTrick(trickId);
  }

  @override
  Future<void> resetAllTrickProgress() async {
    // TODO: 구현 필요
    throw UnimplementedError('resetAllTrickProgress not implemented yet');
  }

  Future<List<TrickEntity>> searchTricks(String query) async {
    return TrickRepositoryHelper.searchTricks(query);
  }

  Future<Map<String, int>> getTrickStats({String? petId}) async {
    return TrickRepositoryHelper.getTrickStats(petId: petId);
  }

  // ========== YouTube 비디오 관련 메서드 (헬퍼 위임) ==========

  Future<List<YouTubeVideoEntity>> getAllYouTubeVideos() async {
    return VideoRepositoryHelper.getAllYouTubeVideos();
  }

  @override
  Future<List<YouTubeVideoEntity>> getYouTubeVideosByPetId(String petId) async {
    return VideoRepositoryHelper.getYouTubeVideosByPetId(petId);
  }

  @override
  Future<YouTubeVideoEntity> registerYouTubeVideo(
    YouTubeVideoEntity video,
  ) async {
    await VideoRepositoryHelper.addYouTubeVideo(video);
    return video;
  }

  @override
  Future<YouTubeVideoEntity> updateYouTubeVideo(
    YouTubeVideoEntity video,
  ) async {
    await VideoRepositoryHelper.updateYouTubeVideo(video.id, video);
    return video;
  }

  @override
  Future<void> deleteYouTubeVideo(String videoId) async {
    return VideoRepositoryHelper.deleteYouTubeVideo(videoId);
  }

  Future<List<YouTubeVideoEntity>> searchVideos(String query) async {
    return VideoRepositoryHelper.searchVideos(query);
  }

  Future<Map<String, int>> getVideoStats({String? petId}) async {
    return VideoRepositoryHelper.getVideoStats(petId: petId);
  }

  // ========== 비디오 진행률 관련 메서드 (헬퍼 위임) ==========

  @override
  Future<VideoProgressEntity?> getVideoProgress(String videoId) async {
    return VideoRepositoryHelper.getVideoProgress(videoId);
  }

  @override
  Future<VideoProgressEntity> saveVideoProgress(
    VideoProgressEntity progress,
  ) async {
    await VideoRepositoryHelper.saveVideoProgress(progress);
    return progress;
  }

  // ========== 비디오 북마크 관련 메서드 (헬퍼 위임) ==========

  @override
  Future<List<VideoBookmarkEntity>> getVideoBookmarks(String videoId) async {
    return BookmarkRepositoryHelper.getVideoBookmarks(videoId);
  }

  @override
  Future<VideoBookmarkEntity> addVideoBookmark(
    VideoBookmarkEntity bookmark,
  ) async {
    await BookmarkRepositoryHelper.addVideoBookmark(bookmark);
    return bookmark;
  }

  Future<void> updateVideoBookmark(
    String bookmarkId,
    VideoBookmarkEntity updates,
  ) async {
    return BookmarkRepositoryHelper.updateVideoBookmark(bookmarkId, updates);
  }

  @override
  Future<void> removeVideoBookmark(String bookmarkId) async {
    return BookmarkRepositoryHelper.removeVideoBookmark(bookmarkId);
  }

  Future<List<VideoBookmarkEntity>> getAllVideoBookmarks() async {
    return BookmarkRepositoryHelper.getAllVideoBookmarks();
  }

  Future<List<VideoBookmarkEntity>> searchVideoBookmarks(String query) async {
    return BookmarkRepositoryHelper.searchVideoBookmarks(query);
  }

  Future<Map<String, int>> getBookmarkStats(String videoId) async {
    return BookmarkRepositoryHelper.getBookmarkStats(videoId);
  }

  Future<Map<String, int>> getBookmarkCountsByVideo() async {
    return BookmarkRepositoryHelper.getBookmarkCountsByVideo();
  }

  Future<List<VideoBookmarkEntity>> getSortedBookmarks(
    String videoId, {
    bool ascending = true,
  }) async {
    return BookmarkRepositoryHelper.getSortedBookmarks(
      videoId,
      ascending: ascending,
    );
  }
}
