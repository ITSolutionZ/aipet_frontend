import 'package:aipet_frontend/features/walk/data/repositories/hybrid_walk_repository.dart';
import 'package:aipet_frontend/features/walk/data/services/walk_api_service.dart';
import 'package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart';
import 'package:aipet_frontend/shared/core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WalkApiService Provider
final walkApiServiceProvider = Provider<WalkApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalkApiService(apiClient);
});

/// HybridWalkRepository Provider
/// 기본값: API 비활성화 (추후 활성화)
final hybridWalkRepositoryProvider = Provider<WalkRepository>((ref) {
  final apiService = ref.watch(walkApiServiceProvider);
  return HybridWalkRepository(
    apiService: apiService,
    useApi: false, // TODO: 추후 true로 변경하여 API 활성화
  );
});
