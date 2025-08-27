import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/services/error_handler_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/performance_monitor_service.dart';
import '../../shared/services/user_experience_service.dart';

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
  /// 8단계의 체계적인 초기화 프로세스를 진행합니다:
  /// 1. 기본 서비스 초기화
  /// 2. 앱 설정 로드
  /// 3. 사용자 인증 상태 확인
  /// 4. 온보딩 완료 상태 확인
  /// 5. 네트워크 연결 확인
  /// 6. 앱 버전 확인
  /// 7. 필수 데이터 로드
  /// 8. 리소스 초기화
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. 기본 서비스 초기화
      await _initializeServices();

      // 2. 앱 설정 로드
      await _loadAppConfig();

      // 3. 사용자 인증 상태 확인
      await _checkAuthStatus();

      // 4. 온보딩 완료 상태 확인
      await _checkOnboardingStatus();

      // 5. 네트워크 연결 확인
      await _checkNetworkConnection();

      // 6. 앱 버전 확인
      await _getAppVersion();

      // 7. 필수 데이터 로드
      await _loadEssentialData();

      // 8. 리소스 초기화
      await _initializeResources();

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
      // 에러 핸들러 서비스 초기화
      await ErrorHandlerService().initialize();
      if (kDebugMode) {
        debugPrint('✅ ErrorHandlerService 초기화 완료');
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
      final prefs = await SharedPreferences.getInstance();

      // 온보딩 완료 플래그 확인
      final isOnboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;

      // 온보딩 완료 버전 확인 (앱 업데이트 시 온보딩 재표시 여부 결정)
      final onboardingVersion = prefs.getString('onboarding_version');
      const currentAppVersion = '1.0.0'; // TODO: PackageInfo에서 가져오도록 수정

      // 온보딩 버전이 다르면 온보딩 미완료로 처리
      final isVersionMatched = onboardingVersion == currentAppVersion;
      final finalOnboardingStatus = isOnboardingCompleted && isVersionMatched;

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
      // 실제 구현에서는 connectivity_plus 패키지 사용
      // TODO: connectivity_plus 패키지를 사용하여 실제 네트워크 연결 상태 확인
      try {
        // HTTP 요청 시뮬레이션 (실제로는 google.com 등에 ping)
        await Future.delayed(const Duration(milliseconds: 100));
        isNetworkConnected = true;
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
      // TODO: package_info_plus를 사용하여 실제 앱 버전 가져오기
      const appVersion = '1.0.0';

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
      // TODO: precacheImage나 ImageCacheService를 사용하여 이미지 사전 로딩

      // 애니메이션 리소스 준비
      // Lottie 애니메이션 등의 사전 로딩

      await Future.delayed(const Duration(milliseconds: 100));

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
