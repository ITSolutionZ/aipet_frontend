import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/domain.dart';
import '../repositories/ai_repository_impl.dart';

part 'ai_providers.g.dart';

/// AI Repository Provider
/// 
/// 실제 API 연계 시점에는 AiRepositoryImpl을 실제 API 구현체로 교체하면 됩니다.
@riverpod
AiRepository aiRepository(Ref ref) {
  return AiRepositoryImpl();
}