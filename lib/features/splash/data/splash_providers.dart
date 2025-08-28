import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/domain.dart';
import 'repositories/splash_repository_impl.dart';

part 'splash_providers.g.dart';

@riverpod
SplashRepository splashRepository(Ref ref) {
  return SplashRepositoryImpl();
}

@riverpod
Future<SplashEntity> splashConfig(Ref ref) async {
  final repository = ref.watch(splashRepositoryProvider);
  return repository.getSplashConfig();
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
