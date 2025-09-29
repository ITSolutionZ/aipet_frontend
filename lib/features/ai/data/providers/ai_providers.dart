import 'package:aipet_frontend/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:aipet_frontend/features/ai/data/services/ai_mock_data_service_impl.dart';
import 'package:aipet_frontend/features/ai/data/services/openai_service.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_providers.g.dart';

/// AI Repository Provider
///
/// 환경에 따라 Mock/Real Repository를 자동으로 전환합니다.
/// MockConfig.shouldUseMock 값에 따라 결정됩니다.
@riverpod
AiRepository aiRepository(Ref ref) {
  // 항상 동일한 Repository 구현체 사용
  // 내부적으로 Mock 데이터 서비스로 Mock/Real API 전환
  return AiRepositoryImpl(
    openAIService: OpenAIService(),
    aiMockDataService: AiMockDataServiceImpl(),
    ref: ref,
  );
}

/// Legacy AI Repository Provider (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
@riverpod
AiRepository legacyAiRepository(Ref ref) {
  return AiRepositoryImpl(
    openAIService: OpenAIService(),
    aiMockDataService: AiMockDataServiceImpl(),
    ref: ref,
  );
}
