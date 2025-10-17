import 'package:aipet_frontend/features/scheduling/data/repositories/feeding_repository_impl.dart';
import 'package:aipet_frontend/features/scheduling/domain/repositories/feeding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feeding_providers.g.dart';

/// 급여 관리 Repository Provider
@riverpod
FeedingRepository feedingRepository(Ref ref) {
  return FeedingRepositoryImpl();
}

/// 펫 사이즈 급여량 정보 Provider
@riverpod
Future<Map<String, dynamic>> petSizeFeedingInfo(Ref ref) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetSizeFeedingInfo();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.error);
  }
}

/// 펫 사이즈 급여량 가이드 Provider
@riverpod
Future<Map<String, dynamic>> petSizeFeedingGuide(Ref ref) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetSizeFeedingGuide();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.error);
  }
}

/// 펫 상태 옵션 Provider
@riverpod
Future<List<String>> petStatusOptions(Ref ref) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetStatusOptions();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.error);
  }
}

/// 펫 정보 Provider (petId를 파라미터로 받음)
@riverpod
Future<Map<String, dynamic>?> petInfo(Ref ref, String petId) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetInfo(petId);

  if (result.isSuccess) {
    return result.dataOrNull;
  } else {
    throw Exception(result.error);
  }
}

/// 급여 기록 Provider
@riverpod
Future<List<Map<String, dynamic>>> feedingRecords(Ref ref) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getFeedingRecords();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.error);
  }
}

/// 급여 분석 데이터 Provider
@riverpod
Future<Map<String, dynamic>> feedingAnalysisData(Ref ref) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getFeedingAnalysisData();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.error);
  }
}
