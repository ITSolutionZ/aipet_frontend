import 'package:aipet_frontend/shared/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repositories/splash_repository_impl.dart';

part 'splash_providers.g.dart';

@riverpod
SplashRepository splashRepository(Ref ref) {
  return SplashRepositoryImpl();
}

@riverpod
Future<SplashEntity> splashConfig(Ref ref) async {
  final repository = ref.watch(splashRepositoryProvider);
  final result = await repository.getSplashConfig();

  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw Exception(result.message);
  }
}

// 스플래시 시퀀스 상태 관리
@riverpod
class SplashSequenceNotifier extends _$SplashSequenceNotifier {
  @override
  SplashState build() => SplashState.initializing();

  void updateState(SplashState newState) {
    state = newState;
  }

  void reset() {
    state = SplashState.initializing();
  }
}
