import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/trick_entity.dart';
import '../../domain/entities/video_bookmark_entity.dart';
import '../../domain/entities/video_progress_entity.dart';

/// 펫 활동 컨트롤러
class PetActivitiesController extends StateNotifier<PetActivitiesState> {
  PetActivitiesController() : super(const PetActivitiesState());

  /// 트릭 목록 로드
  void loadTricks() {
    final tricks = MockDataService.getMockTricks();
    state = state.copyWith(tricks: tricks);
  }

  /// 비디오 북마크 로드
  void loadVideoBookmarks() {
    final bookmarks = MockDataService.getMockVideoBookmarks();
    state = state.copyWith(videoBookmarks: bookmarks);
  }

  /// 비디오 진행률 로드
  void loadVideoProgress() {
    final progress = MockDataService.getMockVideoProgress();
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
