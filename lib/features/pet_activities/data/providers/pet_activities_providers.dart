import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/trick_entity.dart';
import '../../domain/entities/youtube_video_entity.dart';
import '../../domain/repositories/pet_activities_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../repositories/pet_activities_repository_impl.dart';

part 'pet_activities_providers.g.dart';

/// 펫 액티비티 리포지토리 프로바이더
@riverpod
PetActivitiesRepository petActivitiesRepository(Ref ref) {
  return PetActivitiesRepositoryImpl();
}

/// 모든 트릭을 가져오는 프로바이더
@riverpod
Future<List<TrickEntity>> allTricks(Ref ref) async {
  final repository = ref.read(petActivitiesRepositoryProvider);
  return repository.getAllTricks();
}

/// 특정 펫의 트릭을 가져오는 프로바이더
@riverpod
Future<List<TrickEntity>> tricksByPetId(
  Ref ref,
  String petId,
) async {
  final repository = ref.read(petActivitiesRepositoryProvider);
  return repository.getTricksByPetId(petId);
}

/// YouTube 비디오 유스케이스 프로바이더들
@riverpod
RegisterYouTubeVideoUseCase registerYouTubeVideoUseCase(Ref ref) {
  final repository = ref.read(petActivitiesRepositoryProvider);
  return RegisterYouTubeVideoUseCase(repository);
}

@riverpod
GetYouTubeVideosUseCase getYouTubeVideosUseCase(Ref ref) {
  final repository = ref.read(petActivitiesRepositoryProvider);
  return GetYouTubeVideosUseCase(repository);
}

/// YouTube 비디오 목록 프로바이더
final youTubeVideosProvider = FutureProvider.family<List<YouTubeVideoEntity>, String>((ref, petId) async {
  final repository = ref.read(petActivitiesRepositoryProvider);
  final useCase = GetYouTubeVideosUseCase(repository);
  return useCase.call(petId);
});
