import 'package:aipet_frontend/features/scheduling/data/repositories/feeding_repository_impl.dart';
import 'package:aipet_frontend/features/scheduling/domain/repositories/feeding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 급여 관리 Repository Provider
final feedingRepositoryProvider = Provider<FeedingRepository>((ref) {
  return FeedingRepositoryImpl();
});

/// 펫 사이즈 급여량 정보 Provider
final petSizeFeedingInfoProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetSizeFeedingInfo();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull);
  }
});

/// 펫 사이즈 급여량 가이드 Provider
final petSizeFeedingGuideProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetSizeFeedingGuide();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull);
  }
});

/// 펫 상태 옵션 Provider
final petStatusOptionsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetStatusOptions();

  if (result.isSuccess) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull);
  }
});

/// 펫 정보 Provider (petId를 파라미터로 받음)
final petInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((
  ref,
  petId,
) async {
  final repository = ref.read(feedingRepositoryProvider);
  final result = await repository.getPetInfo(petId);

  if (result.isSuccess) {
    return result.dataOrNull;
  } else {
    throw Exception(result.errorOrNull);
  }
});

/// 급여 기록 Provider
final feedingRecordsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.read(feedingRepositoryProvider);
      final result = await repository.getFeedingRecords();

      if (result.isSuccess) {
        return result.dataOrNull!;
      } else {
        throw Exception(result.errorOrNull);
      }
    });

/// 급여 분석 데이터 Provider
final feedingAnalysisDataProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final repository = ref.read(feedingRepositoryProvider);
      final result = await repository.getFeedingAnalysisData();

      if (result.isSuccess) {
        return result.dataOrNull!;
      } else {
        throw Exception(result.errorOrNull);
      }
    });
