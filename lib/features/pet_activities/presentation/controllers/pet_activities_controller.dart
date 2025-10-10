import 'package:aipet_frontend/features/pet_activities/data/services/pet_activities_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 펫 활동 컨트롤러
class PetActivitiesController extends StateNotifier<PetActivitiesState> {
  PetActivitiesController() : super(const PetActivitiesState());

  /// 트릭 목록 로드
  Future<void> loadTricks({String? petId}) async {
    final tricksData = await PetActivitiesLocalStorageService.getTricks(
      petId: petId,
    );

    final tricks = tricksData.map((trickData) {
      // 난이도 매핑
      DifficultyLevel difficulty;
      final difficultyStr = trickData['difficulty'] as String? ?? 'easy';
      switch (difficultyStr.toLowerCase()) {
        case 'hard':
          difficulty = DifficultyLevel.hard;
          break;
        case 'medium':
          difficulty = DifficultyLevel.medium;
          break;
        default:
          difficulty = DifficultyLevel.easy;
      }

      return TrickEntity(
        id: trickData['id'] as String,
        name: trickData['name'] as String,
        description: trickData['description'] as String? ?? '',
        category: trickData['category'] as String? ?? 'General',
        difficulty: difficulty,
        estimatedTime: trickData['estimatedTime'] as int? ?? 30,
        imageUrl: trickData['imagePath'] as String?,
        imagePath: trickData['imagePath'] as String?,
        videoUrl: trickData['videoUrl'] as String?,
        isLearned: trickData['isCompleted'] as bool? ?? false,
        learnedAt: trickData['completedAt'] != null
            ? DateTime.parse(trickData['completedAt'] as String)
            : null,
        practiceCount: trickData['progress'] as int? ?? 0,
        status: (trickData['isCompleted'] as bool?) == true
            ? TrickStatus.completed
            : TrickStatus.available,
        createdAt: trickData['createdAt'] != null
            ? DateTime.parse(trickData['createdAt'] as String)
            : DateTime.now(),
        updatedAt: DateTime.now(),
        petId: trickData['petId'] as String?,
        date: trickData['date'] != null
            ? DateTime.parse(trickData['date'] as String)
            : null,
      );
    }).toList();

    state = state.copyWith(tricks: tricks);
  }

  /// 비디오 북마크 로드
  Future<void> loadVideoBookmarks(String videoId) async {
    final bookmarksData =
        await PetActivitiesLocalStorageService.getVideoBookmarks(videoId);

    final bookmarks = bookmarksData.map((bookmarkData) {
      return VideoBookmarkEntity(
        id: bookmarkData['id'] as String,
        videoId: bookmarkData['videoId'] as String,
        title: bookmarkData['label'] as String? ?? 'Bookmark',
        positionSec: bookmarkData['positionSec'] as int,
        description: bookmarkData['description'] as String?,
        createdAt: bookmarkData['createdAt'] != null
            ? DateTime.parse(bookmarkData['createdAt'] as String)
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();

    state = state.copyWith(videoBookmarks: bookmarks);
  }

  /// 비디오 진행률 로드
  Future<void> loadVideoProgress(String videoId) async {
    final progressData =
        await PetActivitiesLocalStorageService.getVideoProgress(videoId);

    final progress = VideoProgressEntity(
      videoId: videoId,
      currentPositionSec: progressData['currentPosition'] ?? 0,
      totalDurationSec: progressData['totalDuration'] ?? 0,
      progress: (progressData['totalDuration'] ?? 0) > 0
          ? (progressData['currentPosition'] ?? 0) /
                (progressData['totalDuration'] ?? 1)
          : 0.0,
      isCompleted: false,
      lastWatchedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(videoProgress: {videoId: progress});
  }

  /// 트릭 추가
  Future<void> addTrick(TrickEntity trick) async {
    final trickData = {
      'id': trick.id,
      'petId': trick.petId,
      'name': trick.name,
      'description': trick.description,
      'category': trick.category,
      'difficulty': trick.difficulty.toString().split('.').last,
      'estimatedTime': trick.estimatedTime,
      'imagePath': trick.imagePath,
      'videoUrl': trick.videoUrl,
      'isCompleted': trick.isLearned,
      'completedAt': trick.learnedAt?.toIso8601String(),
      'progress': trick.practiceCount,
      'createdAt': trick.createdAt.toIso8601String(),
      'date': trick.date?.toIso8601String(),
    };

    await PetActivitiesLocalStorageService.addTrick(trickData);
    await loadTricks(petId: trick.petId);
  }

  /// 트릭 삭제
  Future<void> deleteTrick(String trickId) async {
    await PetActivitiesLocalStorageService.deleteTrick(trickId);

    final currentPetId = state.tricks.firstOrNull?.petId;
    await loadTricks(petId: currentPetId);
  }

  /// 트릭 진행률 업데이트
  Future<void> updateTrickProgress(String trickId, int progress) async {
    final trick = state.tricks.firstWhere((t) => t.id == trickId);
    final updatedTrick = trick.updateProgress(progress);

    final trickData = {
      'id': updatedTrick.id,
      'petId': updatedTrick.petId,
      'name': updatedTrick.name,
      'description': updatedTrick.description,
      'category': updatedTrick.category,
      'difficulty': updatedTrick.difficulty.toString().split('.').last,
      'estimatedTime': updatedTrick.estimatedTime,
      'imagePath': updatedTrick.imagePath,
      'videoUrl': updatedTrick.videoUrl,
      'isCompleted': updatedTrick.isLearned,
      'completedAt': updatedTrick.learnedAt?.toIso8601String(),
      'progress': updatedTrick.practiceCount,
      'createdAt': updatedTrick.createdAt.toIso8601String(),
      'date': updatedTrick.date?.toIso8601String(),
    };

    await PetActivitiesLocalStorageService.updateTrick(trickId, trickData);
    await loadTricks(petId: updatedTrick.petId);
  }

  /// 트릭 완료 처리
  Future<void> completeTrick(String trickId) async {
    final trick = state.tricks.firstWhere((t) => t.id == trickId);
    final updatedTrick = trick.markAsCompleted();

    final trickData = {
      'id': updatedTrick.id,
      'petId': updatedTrick.petId,
      'name': updatedTrick.name,
      'description': updatedTrick.description,
      'category': updatedTrick.category,
      'difficulty': updatedTrick.difficulty.toString().split('.').last,
      'estimatedTime': updatedTrick.estimatedTime,
      'imagePath': updatedTrick.imagePath,
      'videoUrl': updatedTrick.videoUrl,
      'isCompleted': updatedTrick.isLearned,
      'completedAt': updatedTrick.learnedAt?.toIso8601String(),
      'progress': updatedTrick.practiceCount,
      'createdAt': updatedTrick.createdAt.toIso8601String(),
      'date': updatedTrick.date?.toIso8601String(),
    };

    await PetActivitiesLocalStorageService.updateTrick(trickId, trickData);
    await loadTricks(petId: updatedTrick.petId);
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
