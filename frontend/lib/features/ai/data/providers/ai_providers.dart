import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import '../repositories/ai_chat_repository_impl.dart';
import '../repositories/ai_repository_impl.dart';
import '../services/ai_chat_openai_service.dart';


part 'ai_providers.g.dart';

/// AI Repository Provider
///
/// AI 관련 추천, 즐겨찾기, 분석 기능을 담당합니다.
@riverpod
AiRepository aiRepository(Ref ref) {
  return AiRepositoryImpl(ref: ref);
}

/// AI Chat Repository Provider
///
/// AI 채팅 관련 기능을 담당합니다 (메시지, 세션, 히스토리, 요약).
@riverpod
AiChatRepository aiChatRepository(Ref ref) {
  return AiChatRepositoryImpl(openAIService: AiChatOpenAIService());
}

/// Legacy AI Repository Provider (기존 구현체)
///
/// 필요시 기존 구현체로 되돌릴 수 있도록 유지
@riverpod
AiRepository legacyAiRepository(Ref ref) {
  return AiRepositoryImpl(ref: ref);
}
