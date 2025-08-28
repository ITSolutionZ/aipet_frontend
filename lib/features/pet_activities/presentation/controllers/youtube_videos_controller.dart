import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/youtube_video_entity.dart';
import '../../domain/usecases/usecases.dart';

/// YouTube 비디오 컨트롤러
class YouTubeVideosController {
  final WidgetRef ref;
  final BuildContext context;

  YouTubeVideosController(this.ref, this.context);

  /// YouTube 비디오 목록을 로드합니다.
  void loadYouTubeVideos(String petId) {
    // FutureProvider는 자동으로 로딩 상태를 관리하므로
    // refresh만 호출하면 됩니다.
    // ignore: unused_result
    ref.refresh(youTubeVideosProvider(petId));
  }

  /// YouTube 비디오를 등록합니다.
  Future<void> registerVideo({
    required String youtubeUrl,
    required String title,
    required String petId,
    String? description,
    List<String> tags = const [],
  }) async {
    try {
      final repository = ref.read(petActivitiesRepositoryProvider);
      final useCase = RegisterYouTubeVideoUseCase(repository);
      await useCase.call(
        youtubeUrl: youtubeUrl,
        title: title,
        petId: petId,
        description: description,
        tags: tags,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('YouTube 비디오가 등록되었습니다.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('비디오 등록 실패: $error')));
      }
    }
  }

  /// YouTube 비디오를 삭제합니다.
  Future<void> deleteVideo(String videoId) async {
    try {
      await ref
          .read(petActivitiesRepositoryProvider)
          .deleteYouTubeVideo(videoId);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('비디오가 삭제되었습니다.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('비디오 삭제 실패: $error')));
      }
    }
  }

  /// 태그로 필터링된 비디오를 검색합니다.
  Future<List<YouTubeVideoEntity>> searchByTags(
    String petId,
    List<String> tags,
  ) async {
    final repository = ref.read(petActivitiesRepositoryProvider);
    final useCase = GetYouTubeVideosUseCase(repository);
    return useCase.getByTags(petId, tags);
  }

  /// 검색어로 비디오를 검색합니다.
  Future<List<YouTubeVideoEntity>> searchVideos(
    String petId,
    String query,
  ) async {
    final repository = ref.read(petActivitiesRepositoryProvider);
    final useCase = GetYouTubeVideosUseCase(repository);
    return useCase.search(petId, query);
  }
}
