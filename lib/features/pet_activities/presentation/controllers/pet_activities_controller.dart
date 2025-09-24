import 'package:aipet_frontend/features/onboarding/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/onboarding/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet_activities/pet_activities_mock_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 활동 컨트롤러
class PetActivitiesController extends StateNotifier<PetActivitiesState> {
  PetActivitiesController() : super(const PetActivitiesState());

  /// 트릭 목록 로드
  void loadTricks() {
    final mockTricks = PetActivitiesMockService.getMockTricks();
    final tricks = mockTricks
        .map(
          (trickData) => TrickEntity(
            id: trickData['id'] as String,
            name: trickData['name'] as String,
            petId: trickData['petId'] as String?,
            progress: trickData['progress'] as int?,
            imagePath: trickData['imagePath'] as String,
            isCompleted: trickData['isCompleted'] as bool,
            difficulty: trickData['difficulty'] as String?,
            youtubeUrl: trickData['videoUrl'] as String?,
            description: trickData['description'] as String?,
            createdAt: trickData['createdAt'] as DateTime,
            date: trickData['completedAt'] as DateTime?,
          ),
        )
        .toList();
    state = state.copyWith(tricks: tricks);
  }

  /// 비디오 북마크 로드
  void loadVideoBookmarks() {
    final mockBookmarks = PetActivitiesMockService.getMockVideoBookmarks();
    final bookmarks = mockBookmarks
        .map(
          (bookmarkData) => VideoBookmarkEntity(
            id: bookmarkData['id'] as String,
            videoId: bookmarkData['videoId'] as String,
            youtubeVideoId: bookmarkData['youtubeVideoId'] as String,
            positionSec: bookmarkData['positionSec'] as int,
            label: bookmarkData['label'] as String?,
            description: bookmarkData['description'] as String?,
            createdAt: bookmarkData['createdAt'] as DateTime,
          ),
        )
        .toList();
    state = state.copyWith(videoBookmarks: bookmarks);
  }

  /// 비디오 진행률 로드
  void loadVideoProgress() {
    final mockProgress = PetActivitiesMockService.getMockVideoProgress();
    final progress = mockProgress.map(
      (key, value) => MapEntry(
        key,
        VideoProgressEntity(
          videoId: value['videoId'] as String,
          lastPositionSec: value['lastPositionSec'] as int,
          updatedAt: value['updatedAt'] as DateTime,
        ),
      ),
    );
    state = state.copyWith(videoProgress: progress);
  }

  /// 트릭 추가
  void addTrick(TrickEntity trick) {
    final newTricks = List<TrickEntity>.from(state.tricks);
    newTricks.add(trick);
    state = state.copyWith(tricks: newTricks);
  }

  /// 트릭 삭제
  void deleteTrick(String trickId) {
    final newTricks = state.tricks
        .where((trick) => trick.id != trickId)
        .toList();
    state = state.copyWith(tricks: newTricks);
  }
}

/// 펫 활동 상태
class PetActivitiesState {
  final List<TrickEntity> tricks;
  final List<VideoBookmarkEntity> videoBookmarks;
  final Map<String, VideoProgressEntity> videoProgress;

  const PetActivitiesState({
    this.tricks = const [],
    this.videoBookmarks = const [],
    this.videoProgress = const {},
  });

  PetActivitiesState copyWith({
    List<TrickEntity>? tricks,
    List<VideoBookmarkEntity>? videoBookmarks,
    Map<String, VideoProgressEntity>? videoProgress,
  }) {
    return PetActivitiesState(
      tricks: tricks ?? this.tricks,
      videoBookmarks: videoBookmarks ?? this.videoBookmarks,
      videoProgress: videoProgress ?? this.videoProgress,
    );
  }
}

/// 컨트롤러 프로바이더
final petActivitiesControllerProvider =
    StateNotifierProvider<PetActivitiesController, PetActivitiesState>((ref) {
      return PetActivitiesController();
    });
