import 'package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/get_splash_config_usecase.dart';
import 'package:aipet_frontend/features/splash/domain/usecases/manage_splash_sequence_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
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
    throw Exception(result.error ?? 'Unknown error');
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
class SplashControllerNotifier extends _$SplashControllerNotifier {
  @override
  void build() {
    // 초기화 로직이 필요한 경우 여기에 추가
  }

  /// 스플래시 시퀀스 시작
  Stream<Result<SplashState>> startSplashSequence() async* {
    try {
      final manageSplashSequenceUseCase = ref.read(manageSplashSequenceUseCaseProvider);

      // UseCase에서 스트림을 가져와서 yield
      await for (final result in manageSplashSequenceUseCase.execute()) {
        yield result;
      }
    } catch (error) {
      debugPrint('❌ 스플래시 시퀀스 에러: $error');
      // 에러 발생 시 기본 시퀀스 제공
      await for (final result in _getDefaultSplashSequence()) {
        yield result;
      }
    }
  }

  /// 기본 스플래시 시퀀스 (에러 발생 시 사용)
  Stream<Result<SplashState>> _getDefaultSplashSequence() async* {
    debugPrint('🔄 기본 스플래시 시퀀스 시작');

    // 1. 초기화 상태
    yield Result.success('스플래시 초기화', SplashState.initializing());
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. 로딩 상태
    yield Result.success('스플래시 로딩', SplashState.loading());
    await Future.delayed(const Duration(seconds: 1));

    // 3. 앱 로고 표시
    yield Result.success('앱 로고 표시', SplashState.appLogo(AppConstants.splashAppLogoPath));
    await Future.delayed(const Duration(seconds: 1));

    // 4. 완료
    debugPrint('✅ 스플래시 시퀀스 완료');
    yield Result.success('스플래시 완료', SplashState.completed());
  }
}
