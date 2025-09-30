import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
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
            description: trickData['description'] as String? ?? '',
            category: trickData['category'] as String? ?? 'General',
            difficulty: DifficultyLevel.easy, // TODO: 실제 난이도 매핑 필요
            estimatedTime: trickData['estimatedTime'] as int? ?? 30,
            imageUrl: trickData['imagePath'] as String?,
            imagePath: trickData['imagePath'] as String?,
            videoUrl: trickData['videoUrl'] as String?,
            isLearned: trickData['isCompleted'] as bool? ?? false,
            learnedAt: trickData['completedAt'] as DateTime?,
            practiceCount: trickData['progress'] as int? ?? 0,
            status: (trickData['isCompleted'] as bool?) == true
                ? TrickStatus.completed
                : TrickStatus.available,
            createdAt: trickData['createdAt'] as DateTime? ?? DateTime.now(),
            updatedAt: DateTime.now(),
            petId: trickData['petId'] as String?,
            date: trickData['date'] as DateTime?,
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
            title: bookmarkData['label'] as String? ?? 'Bookmark',
            positionSec: bookmarkData['positionSec'] as int,
            description: bookmarkData['description'] as String?,
            createdAt: bookmarkData['createdAt'] as DateTime? ?? DateTime.now(),
            updatedAt: DateTime.now(),
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
          currentPositionSec: value['lastPositionSec'] as int? ?? 0,
          totalDurationSec: value['totalDurationSec'] as int? ?? 0,
          progress: value['progress'] as double? ?? 0.0,
          isCompleted: value['isCompleted'] as bool? ?? false,
          lastWatchedAt: value['lastWatchedAt'] as DateTime? ?? DateTime.now(),
          updatedAt: value['updatedAt'] as DateTime? ?? DateTime.now(),
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
    final newTricks = state.tricks.where((trick) => trick.id != trickId).toList();
    state = state.copyWith(tricks: newTricks);
  }

  /// 트릭 진행률 업데이트
  void updateTrickProgress(String trickId, int progress) {
    final updatedTricks = state.tricks.map((trick) {
      if (trick.id == trickId) {
        return trick.updateProgress(progress);
      }
      return trick;
    }).toList();
    state = state.copyWith(tricks: updatedTricks);
  }

  /// 트릭 완료 처리
  void completeTrick(String trickId) {
    final updatedTricks = state.tricks.map((trick) {
      if (trick.id == trickId) {
        return trick.markAsCompleted();
      }
      return trick;
    }).toList();
    state = state.copyWith(tricks: updatedTricks);
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
