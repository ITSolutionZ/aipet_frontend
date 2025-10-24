import 'package:aipet_frontend/features/notification/data/services/notification_service.dart';
import 'package:aipet_frontend/features/onboarding/data/data.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/core/services/performance_monitor_service.dart';
import 'package:aipet_frontend/shared/core/services/user_experience_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_initialization_provider.g.dart';

/// 앱 초기화 상태를 관리하는 Provider
///
/// 앱 시작 시 필요한 모든 초기화 작업을 관리하고 상태를 추적합니다.
@riverpod
class AppInitialization extends _$AppInitialization {
  @override
  AppInitializationState build() {
    return const AppInitializationState(
      isInitialized: false,
      isLoading: true,
      error: null,
    );
  }

  /// 앱 초기화를 수행합니다.
  ///
  /// 최적화된 병렬 초기화 프로세스:
  /// 1. 기본 서비스 초기화 (먼저 실행)
  /// 2. 병렬 작업: 앱 설정, 인증, 네트워크, 버전 확인
  /// 3. 의존성 작업: 온보딩 상태 확인 (앱 버전 후)
  /// 4. 병렬 작업: 필수 데이터, 리소스 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 기본 서비스 초기화 (다른 작업의 의존성이므로 먼저 실행)
      await _initializeServices();

      // 2. 병렬 실행 가능한 독립적인 작업들
      final independentFutures = <Future>[
        _loadAppConfig(),
        _checkAuthStatus(),
        _checkNetworkConnection(),
        _getAppVersion(),
      ];

      // 병렬 실행
      await Future.wait(independentFutures, eagerError: false);

      // 앱 버전이 필요한 온보딩 상태 확인
      await _checkOnboardingStatus();

      // 3. 마지막 단계 병렬 실행
      final finalFutures = <Future>[
        _loadEssentialData(),
        _initializeResources(),
      ];

      await Future.wait(finalFutures, eagerError: false);

      state = state.copyWith(isInitialized: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 기본 서비스들을 초기화합니다.
  ///
  /// 에러 핸들러, 성능 모니터링, 사용자 경험, 알림 서비스를 초기화합니다.
  Future<void> _initializeServices() async {
    try {
      // 에러 핸들러 서비스는 정적 메서드이므로 별도 초기화 불필요
      if (kDebugMode) {
        debugPrint('✅ ErrorHandlingService 사용 가능');
      }

      // 성능 모니터링 서비스 초기화
      PerformanceMonitorService().startMonitoring();
      if (kDebugMode) {
        debugPrint('✅ PerformanceMonitorService 초기화 완료');
      }

      // 사용자 경험 서비스 초기화
      await UserExperienceService().initialize();
      if (kDebugMode) {
        debugPrint('✅ UserExperienceService 초기화 완료');
      }

      // 알림 서비스 초기화
      await NotificationService().initialize();
      if (kDebugMode) {
        debugPrint('✅ NotificationService 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 서비스 초기화 실패: $e');
      }
      rethrow;
    }
  }

  /// 앱 설정을 로드합니다.
  ///
  /// 테마, 언어, 알림 설정 등 사용자 기본 설정을 로드합니다.
  Future<void> _loadAppConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 기본 설정값들 로드
      final theme = prefs.getString('app_theme') ?? 'light';
      final language = prefs.getString('app_language') ?? 'ko';
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;

      if (kDebugMode) {
        debugPrint(
          '✅ 앱 설정 로드 완료: theme=$theme, lang=$language, notifications=$notificationsEnabled',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 앱 설정 로드 실패: $e');
      }
      rethrow;
    }
  }

  /// 사용자 인증 상태를 확인합니다.
  ///
  /// 저장된 토큰의 유효성을 검사하고 인증 상태를 업데이트합니다.
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 저장된 토큰 확인
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');
      final isAuthenticated = accessToken != null && refreshToken != null;

      // 토큰 만료 시간 확인 (실제 구현 시 JWT 디코딩 필요)
      if (isAuthenticated) {
        final tokenExpiryTime = prefs.getInt('token_expiry_time');
        if (tokenExpiryTime != null) {
          final expiryDateTime = DateTime.fromMillisecondsSinceEpoch(
            tokenExpiryTime,
          );
          final isExpired = DateTime.now().isAfter(expiryDateTime);
          if (isExpired) {
            // 토큰이 만료된 경우 클리어
            await prefs.remove('access_token');
            await prefs.remove('refresh_token');
            await prefs.remove('token_expiry_time');
            state = state.copyWith(isAuthenticated: false);
            if (kDebugMode) {
              debugPrint('✅ 만료된 토큰 클리어됨');
            }
            return;
          }
        }
      }

      // 상태 업데이트
      state = state.copyWith(isAuthenticated: isAuthenticated);

      if (kDebugMode) {
        debugPrint('✅ 인증 상태 확인 완료: $isAuthenticated');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 인증 상태 확인 실패: $e');
      }
      // 인증 실패 시 기본값으로 설정
      state = state.copyWith(isAuthenticated: false);
    }
  }

  /// 온보딩 완료 상태를 확인합니다.
  ///
  /// 온보딩 완료 플래그와 버전을 확인하여 온보딩 상태를 결정합니다.
  Future<void> _checkOnboardingStatus() async {
    try {
      // 온보딩 리포지토리를 통해 상태 확인
      final onboardingRepository = ref.read(onboardingRepositoryProvider);
      final onboardingCompletedResult = await onboardingRepository
          .isOnboardingCompleted();

      final isOnboardingCompleted = onboardingCompletedResult.isSuccess
          ? (onboardingCompletedResult.dataOrNull ?? false)
          : false;

      // 온보딩 완료 버전 확인 (앱 업데이트 시 온보딩 재표시 여부 결정)
      final prefs = await SharedPreferences.getInstance();
      final onboardingVersion = prefs.getString('onboarding_version');
      final packageInfo = await PackageInfo.fromPlatform();
      final currentAppVersion = packageInfo.version;

      // 온보딩 버전이 다르면 온보딩 미완료로 처리
      final isVersionMatched = onboardingVersion == currentAppVersion;
      final finalOnboardingStatus = isOnboardingCompleted && isVersionMatched;

      // 온보딩 상태 로드 및 초기화
      final onboardingStateNotifier = ref.read(onboardingProvider.notifier);
      final savedStateResult = await onboardingRepository.loadOnboardingState();
      if (savedStateResult.isSuccess) {
        onboardingStateNotifier.state = savedStateResult.dataOrNull!;
      }

      // 상태 업데이트
      state = state.copyWith(isOnboardingCompleted: finalOnboardingStatus);

      if (kDebugMode) {
        debugPrint('✅ 온보딩 상태 확인 완료: $finalOnboardingStatus');
        debugPrint('   - 완료 플래그: $isOnboardingCompleted');
        debugPrint(
          '   - 버전 일치: $isVersionMatched ($onboardingVersion vs $currentAppVersion)',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 온보딩 상태 확인 실패: $e');
      }
      // 실패 시 온보딩 미완료로 설정
      state = state.copyWith(isOnboardingCompleted: false);
    }
  }

  /// 네트워크 연결을 확인합니다.
  ///
  /// 인터넷 연결 상태와 오프라인 모드 설정을 확인합니다.
  Future<void> _checkNetworkConnection() async {
    try {
      bool isNetworkConnected = false;

      // 네트워크 연결 상태 확인
      try {
        final connectivityResult = await Connectivity().checkConnectivity();
        isNetworkConnected =
            connectivityResult.isNotEmpty &&
            !connectivityResult.contains(ConnectivityResult.none);
      } catch (e) {
        isNetworkConnected = false;
      }

      // 오프라인 모드 설정 확인
      final prefs = await SharedPreferences.getInstance();
      final offlineModeEnabled = prefs.getBool('offline_mode_enabled') ?? false;

      if (offlineModeEnabled) {
        if (kDebugMode) {
          debugPrint('📶 오프라인 모드가 활성화되어 있습니다');
        }
      }

      // 상태 업데이트
      state = state.copyWith(isNetworkConnected: isNetworkConnected);

      if (kDebugMode) {
        debugPrint('✅ 네트워크 연결 확인 완료: $isNetworkConnected');
        if (offlineModeEnabled) {
          debugPrint('   - 오프라인 모드: 활성화');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 네트워크 연결 확인 실패: $e');
      }
      // 실패 시 연결 안됨으로 설정
      state = state.copyWith(isNetworkConnected: false);
    }
  }

  /// 앱 버전을 확인합니다.
  ///
  /// 현재 앱 버전을 가져와서 상태에 저장합니다.
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // 상태 업데이트
      state = state.copyWith(appVersion: appVersion);

      if (kDebugMode) {
        debugPrint('✅ 앱 버전 확인 완료: $appVersion');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 앱 버전 확인 실패: $e');
      }
      // 실패 시 기본 버전으로 설정
      state = state.copyWith(appVersion: '1.0.0');
    }
  }

  /// 필수 데이터를 로드합니다.
  ///
  /// 앱 실행에 필요한 기본 데이터와 캐시된 데이터를 로드합니다.
  Future<void> _loadEssentialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 캐시된 데이터 확인
      final lastDataSync = prefs.getString('last_data_sync');

      // Mock 데이터 서비스 초기화 확인
      // 실제 API 연동 시에는 여기서 필수 마스터 데이터를 로드

      if (kDebugMode) {
        debugPrint('✅ 필수 데이터 로드 완료 (lastSync: $lastDataSync)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 필수 데이터 로드 실패: $e');
      }
      rethrow;
    }
  }

  /// 리소스(폰트, 이미지 등)를 초기화합니다.
  ///
  /// 폰트, 이미지, 애니메이션 등 앱 리소스를 사전 로드합니다.
  Future<void> _initializeResources() async {
    try {
      // 폰트 사전 로딩
      // Flutter에서는 폰트가 자동으로 로드되므로 별도 처리 불필요

      // 중요한 이미지들 캐시 준비
      await _precacheImportantImages();

      // 애니메이션 리소스 준비
      // Lottie 애니메이션 등의 사전 로딩 (필요시에만 로드)

      if (kDebugMode) {
        debugPrint('✅ 리소스 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 리소스 초기화 실패: $e');
      }
      rethrow;
    }
  }

  /// 중요한 이미지들을 사전 로드합니다.
  ///
  /// 앱에서 자주 사용되는 이미지들을 미리 캐시하여 성능을 향상시킵니다.
  /// BuildContext가 필요한 precacheImage는 위젯 트리에서 처리합니다.
  Future<void> _precacheImportantImages() async {
    try {
      // 이미지 캐시 준비 (실제 precacheImage는 위젯에서 처리)
      const importantImages = [
        'assets/icons/aipet_logo.png',
        'assets/icons/logo_notinclude_text.png',
        'assets/images/placeholder.png',
        'assets/images/empty_image.png',
      ];

      if (kDebugMode) {
        debugPrint('✅ 이미지 사전 로드 준비 완료: ${importantImages.length}개 이미지');
        for (final imagePath in importantImages) {
          debugPrint('   - $imagePath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 이미지 사전 로드 준비 중 오류: $e');
      }
    }
  }

  /// 앱 상태를 초기화합니다 (로그아웃 시 사용)
  ///
  /// 인증 상태와 온보딩 상태를 제외한 모든 상태를 초기화합니다.
  Future<void> reset() async {
    try {
      LoggerService.debug('🔄 앱 상태 리셋 시작');

      // SharedPreferences 데이터 클리어 (온보딩 제외)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('token_expiry_time');
      await prefs.remove('last_data_sync');

      // 상태를 미인증 상태로 리셋
      state = state.copyWith(isAuthenticated: false, error: null);

      LoggerService.debug('✅ 앱 상태 리셋 완료');
    } catch (e) {
      LoggerService.debug('❌ 앱 상태 리셋 실패: $e');
      rethrow;
    }
  }
}

/// 앱 초기화 상태 데이터 클래스
class AppInitializationState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isOnboardingCompleted;
  final String appVersion;
  final bool isNetworkConnected;

  const AppInitializationState({
    required this.isInitialized,
    required this.isLoading,
    this.error,
    this.isAuthenticated = false,
    this.isOnboardingCompleted = false,
    this.appVersion = '1.0.0',
    this.isNetworkConnected = true,
  });

  AppInitializationState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isOnboardingCompleted,
    String? appVersion,
    bool? isNetworkConnected,
  }) {
    return AppInitializationState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      appVersion: appVersion ?? this.appVersion,
      isNetworkConnected: isNetworkConnected ?? this.isNetworkConnected,
    );
  }
}
