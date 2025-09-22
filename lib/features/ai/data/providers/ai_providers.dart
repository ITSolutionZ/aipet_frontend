import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/testing/mock_config.dart';
import '../../domain/domain.dart';
import '../repositories/ai_repository_impl.dart';
import '../repositories/ai_repository_mockito_impl.dart';
import '../services/ai_mock_data_service_impl.dart';
import '../services/openai_service.dart';

part 'ai_providers.g.dart';

/// AI Repository Provider
///
/// 환경에 따라 Mock/Real Repository를 자동으로 전환합니다.
/// MockConfig.shouldUseMock 값에 따라 결정됩니다.
@riverpod
AiRepository aiRepository(Ref ref) {
  if (MockConfig.shouldUseMock) {
    // Mockito Mock 구현체 사용 (개발/테스트 환경)
    return AiRepositoryMockitoImpl(
      openAIService: OpenAIService(),
      ref: ref,
    );
  } else {
    // Real 구현체 사용 (프로덕션 환경)
    return AiRepositoryImpl(
      openAIService: OpenAIService(),
      aiMockDataService: AiMockDataServiceImpl(),
      ref: ref,
    );
  }
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
