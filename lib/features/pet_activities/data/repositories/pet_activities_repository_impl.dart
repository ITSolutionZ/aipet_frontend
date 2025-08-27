import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/trick_entity.dart';
import '../../domain/entities/video_bookmark_entity.dart';
import '../../domain/entities/video_progress_entity.dart';
import '../../domain/entities/youtube_video_entity.dart';
import '../../domain/repositories/pet_activities_repository.dart';

class PetActivitiesRepositoryImpl implements PetActivitiesRepository {
  // 메모리 기반 저장소 (MockDataService의 데이터로 초기화)
  late final List<VideoBookmarkEntity> _bookmarks;
  late final Map<String, VideoProgressEntity> _progress;
  late final List<TrickEntity> _tricks;
  late final List<YouTubeVideoEntity> _youtubeVideos;

  PetActivitiesRepositoryImpl() {
    // MockDataService에서 초기 데이터 로드
    _bookmarks = List.from(MockDataService.getMockVideoBookmarks());
    _progress = Map.from(MockDataService.getMockVideoProgress());
    _tricks = List.from(MockDataService.getMockTricks());
    _youtubeVideos = [];
  }

  @override
  Future<List<TrickEntity>> getAllTricks() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _tricks;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<TrickEntity>> getTricksByPetId(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _tricks.where((trick) => trick.petId == petId).toList();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<TrickEntity> addTrick(TrickEntity trick) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      _tricks.add(trick);
      return trick;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<TrickEntity> updateTrick(TrickEntity trick) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      final index = _tricks.indexWhere((t) => t.id == trick.id);
      if (index != -1) {
        _tricks[index] = trick;
        return trick;
      }
      throw Exception('トリックが見つかりません');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteTrick(String trickId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      _tricks.removeWhere((trick) => trick.id == trickId);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> resetAllTrickProgress() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      for (int i = 0; i < _tricks.length; i++) {
        _tricks[i] = _tricks[i].copyWith(progress: null);
      }
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  // Video Bookmark 관련 구현
  @override
  Future<VideoBookmarkEntity> addVideoBookmark(
    VideoBookmarkEntity bookmark,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      _bookmarks.add(bookmark);
      return bookmark;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<VideoBookmarkEntity>> getVideoBookmarks(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      return _bookmarks
          .where((bookmark) => bookmark.videoId == videoId)
          .toList()
        ..sort((a, b) => a.positionSec.compareTo(b.positionSec));
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> removeVideoBookmark(String bookmarkId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  // Video Progress 관련 구현
  @override
  Future<VideoProgressEntity> saveVideoProgress(
    VideoProgressEntity progress,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (MockDataService.isEnabled) {
      _progress[progress.videoId] = progress;
      return progress;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<VideoProgressEntity?> getVideoProgress(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (MockDataService.isEnabled) {
      return _progress[videoId];
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  // YouTube Video 관련 구현
  @override
  Future<YouTubeVideoEntity> registerYouTubeVideo(
    YouTubeVideoEntity video,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      _youtubeVideos.add(video);
      return video;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<List<YouTubeVideoEntity>> getYouTubeVideosByPetId(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return _youtubeVideos.where((video) => video.petId == petId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<YouTubeVideoEntity> updateYouTubeVideo(
    YouTubeVideoEntity video,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      final index = _youtubeVideos.indexWhere((v) => v.id == video.id);
      if (index != -1) {
        _youtubeVideos[index] = video;
        return video;
      }
      throw Exception('YouTube 비디오를 찾을 수 없습니다');
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteYouTubeVideo(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (MockDataService.isEnabled) {
      _youtubeVideos.removeWhere((video) => video.id == videoId);
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }
}
