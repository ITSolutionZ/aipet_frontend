import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/get_splash_config_usecase.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/manage_splash_sequence_usecase.dart';
import 'package:aipet_frontend/features/splash/presentation/controllers/splash_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repositories/splash_repository_impl.dart';

part 'splash_providers.g.dart';

/// 스플래시 Repository Provider
@riverpod
SplashRepository splashRepository(Ref ref) {
  return SplashRepositoryImpl();
}

/// 스플래시 UseCase Provider들
@riverpod
ManageSplashSequenceUseCase manageSplashSequenceUseCase(Ref ref) {
  final repository = ref.watch(splashRepositoryProvider);
  return ManageSplashSequenceUseCase(repository);
}

@riverpod
GetSplashConfigUseCase getSplashConfigUseCase(Ref ref) {
  final repository = ref.watch(splashRepositoryProvider);
  return GetSplashConfigUseCase(repository);
}

/// 스플래시 설정 Provider
@riverpod
Future<SplashEntity> splashConfig(Ref ref) async {
  final repository = ref.watch(splashRepositoryProvider);
  final result = await repository.getSplashConfig();

  if (result.isSuccess && result.dataOrNull != null) {
    return result.dataOrNull!;
  } else {
    throw Exception(result.errorOrNull ?? 'Unknown error');
  }
}

/// 스플래시 상태 관리 Notifier
@riverpod
class SplashStateNotifier extends _$SplashStateNotifier {
  @override
  SplashState build() => SplashState.initializing();

  /// 상태 업데이트
  void updateState(SplashState newState) {
    state = newState;
  }

  /// 상태 초기화
  void reset() {
    state = SplashState.initializing();
  }

  /// 로딩 상태로 변경
  void setLoading() {
    state = SplashState.loading();
  }

  /// 앱 로고 상태로 변경
  void setAppLogo() {
    state = SplashState.appLogo(AppConstants.splashAppLogoPath);
  }

  /// 완료 상태로 변경
  void setCompleted() {
    state = SplashState.completed();
  }
}

/// 스플래시 Controller Provider
@riverpod
SplashController splashController(Ref ref) {
  return SplashController(ref as WidgetRef);
}
