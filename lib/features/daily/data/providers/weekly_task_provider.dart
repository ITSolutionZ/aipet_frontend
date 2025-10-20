import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/weekly_task_openai_service.dart';

part 'weekly_task_provider.g.dart';

/// WeeklyTaskOpenAIService 프로바이더
@riverpod
WeeklyTaskOpenAIService weeklyTaskOpenAIService(Ref ref) {
  return WeeklyTaskOpenAIService();
}

/// 주차별 펫 케어 할 일 프로바이더
///
/// 1주일 동안 캐싱하여 불필요한 API 호출 방지
@Riverpod(keepAlive: true)
Future<String> weeklyTasks(
  Ref ref, {
  required String petType,
  required int weekOfYear,
}) async {
  // 캐시 만료 타이머 설정 (1주일 후 자동 갱신)
  final timer = Timer(const Duration(days: 7), () => ref.invalidateSelf());

  // Provider가 dispose될 때 타이머 취소
  ref.onDispose(timer.cancel);

  final service = ref.watch(weeklyTaskOpenAIServiceProvider);

  final result = await service.generateWeeklyTask(
    petType: petType,
    weekOfYear: weekOfYear,
  );

  if (result.isSuccess) {
    return result.dataOrNull ?? '$weekOfYear週目';
  } else {
    // 에러 발생 시 기본 텍스트 반환
    return '$weekOfYear週目';
  }
}
