import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import '../repositories/ai_repository_impl.dart';
import '../repositories/ai_repository_mockito_impl.dart';
import '../services/ai_mock_data_service_impl.dart';
import '../services/openai_service.dart';

part 'ai_providers.g.dart';

/// AI Repository Provider
///
/// 실제 API 연계 시점에는 AiRepositoryImpl을 실제 API 구현체로 교체하면 됩니다.
/// Mockito 버전을 사용하여 테스트 가능성을 높입니다.
@riverpod
AiRepository aiRepository(Ref ref) {
  // 실제 OpenAI API는 사용하되, 나머지 로직은 Mockito를 통해 테스트 가능
  return AiRepositoryMockitoImpl(
    openAIService: OpenAIService(), // 실제 OpenAI API 사용
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
