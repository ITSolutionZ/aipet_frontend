import '../entities/trick_entity.dart';
import '../entities/video_bookmark_entity.dart';
import '../entities/video_progress_entity.dart';
import '../entities/youtube_video_entity.dart';

abstract class PetActivitiesRepository {
  // Trick 관련
  Future<List<TrickEntity>> getAllTricks();
  Future<List<TrickEntity>> getTricksByPetId(String petId);
  Future<TrickEntity> addTrick(TrickEntity trick);
  Future<TrickEntity> updateTrick(TrickEntity trick);
  Future<void> deleteTrick(String trickId);
  Future<void> resetAllTrickProgress();

  // Video Bookmark 관련
  Future<VideoBookmarkEntity> addVideoBookmark(VideoBookmarkEntity bookmark);
  Future<List<VideoBookmarkEntity>> getVideoBookmarks(String videoId);
  Future<void> removeVideoBookmark(String bookmarkId);

  // Video Progress 관련
  Future<VideoProgressEntity> saveVideoProgress(VideoProgressEntity progress);
  Future<VideoProgressEntity?> getVideoProgress(String videoId);

  // YouTube Video 관련
  Future<YouTubeVideoEntity> registerYouTubeVideo(YouTubeVideoEntity video);
  Future<List<YouTubeVideoEntity>> getYouTubeVideosByPetId(String petId);
  Future<YouTubeVideoEntity> updateYouTubeVideo(YouTubeVideoEntity video);
  Future<void> deleteYouTubeVideo(String videoId);
}
