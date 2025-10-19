import 'dart:async';

import 'package:aipet_frontend/features/auth/data/services/firebase_token_service.dart';
import 'package:aipet_frontend/features/auth/data/services/token_storage_auth_token_repository.dart';
import 'package:aipet_frontend/features/pet_profile/data/data.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/utils/utils.dart';
import 'package:aipet_frontend/firebase_options.dart';
import 'package:aipet_frontend/shared/core/services/http_client_service.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';
import 'package:aipet_frontend/shared/services/local_storage_service.dart';
import 'package:aipet_frontend/shared/services/preload_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'config/config.dart';
import 'providers/providers.dart';

/// Firebase 초기화 상태를 전역으로 관리
class FirebaseManager {
  static bool _isInitialized = false;
  static String? _initializationError;

  static bool get isInitialized => _isInitialized;
  static String? get initializationError => _initializationError;

  static Future<bool> initialize() async {
    if (_isInitialized) {
      return true; // 이미 초기화됨
    }

    try {
      debugPrint('🚀 Attempting Firebase initialization with options...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      _initializationError = null;
      debugPrint('✅ Firebase initialized successfully with options');
      return true;
    } catch (e, stackTrace) {
      _isInitialized = false;
      _initializationError = e.toString();
      debugPrint('🔥 Firebase initialization failed: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      debugPrint('ℹ️  Firebase 기능이 비활성화됩니다. 앱은 계속 실행됩니다.');
      return false;
    }
  }

  /// Firebase 서비스 사용 전 안전성 검사
  static void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'Firebase is not initialized. '
        'Error: ${_initializationError ?? "Unknown error"}. '
        'Call FirebaseManager.initialize() first.',
      );
    }
  }
}

/// 앱의 메인 위젯을 생성하는 클래스
///
/// 앱 초기화 및 부트스트랩 로직을 담당합니다.
class AppBootstrap {
  /// 앱 초기화 및 설정을 수행합니다.
  ///
  /// 환경별 설정을 초기화하고 앱 실행에 필요한 기본 설정을 로드합니다.
  static Future<void> initialize() async {
    debugPrint('🚀 App initialization started');

    // 동기 초기화 작업들 (빠른 작업들)
    _initializeAppConfig();
    _initializeImageCache();

    // 공통 HTTP 클라이언트에 토큰 저장소 연결
    HttpClientService.tokenRepository = const TokenStorageAuthTokenRepository();

    // 비동기 작업들을 병렬로 실행
    final futures = <Future>[
      AppConfig.current.loadEnv(),
      FirebaseManager.initialize(),
      _initializeSentry(),
      _initializeLocalDataManager(),
      _initializeLocalStorage(),
      _clearPetCache(),
    ];

    // 모든 비동기 초기화 작업을 병렬로 실행
    final results = await Future.wait(futures, eagerError: false);

    // Firebase 초기화 결과 확인 (두 번째 결과)
    final isFirebaseInitialized = results[1] as bool;

    // 설정 완료 후 로그 출력 (개발 모드에서만)
    if (AppConfig.current.isDebugMode) {
      _logInitializationStatus(isFirebaseInitialized);
    }

    // Firebase가 성공적으로 초기화된 경우에만 인증 상태 리스너 설정
    if (isFirebaseInitialized) {
      try {
        FirebaseTokenService.setupAuthStateListener();
        debugPrint('✅ Firebase Auth State Listener setup');
      } catch (e) {
        debugPrint('⚠️ Firebase Auth State Listener setup failed: $e');
      }
    }

    // 홈 데이터 프리로딩 시작 (백그라운드)
    unawaited(PreloadService().startPreloading());

    // NOTE:
    // 웹/멀티플랫폼에서 옵션이 필요하다면 아래 주석을 해제하고
    // `flutterfire configure`로 생성된 firebase_options.dart를 사용하세요.
    /*
    import 'package:aipet_frontend/firebase_options.dart' as fbopts; // 파일 경로는 프로젝트에 맞게 조정
    Firebase.initializeApp(
      options: fbopts.DefaultFirebaseOptions.currentPlatform,
    )
    .then((_) => debugPrint('✅ Firebase initialized with options'))
    .catchError((e) => debugPrint('🔥 Firebase init(with options) failed: $e'));
    */
  }

  /// Sentry 초기화
  ///
  /// 에러 추적 및 성능 모니터링을 위한 Sentry를 초기화합니다.
  static Future<void> _initializeSentry() async {
    try {
      // Sentry Flutter 9.x에서는 SentryFlutter.init() 사용
      await SentryFlutter.init(
        (options) {
          // DSN은 환경 변수에서 가져오거나 기본값 사용
          final dsn =
              dotenv.env['SENTRY_DSN'] ??
              'https://your-sentry-dsn@sentry.io/project-id';
          options.dsn = dsn;

          // 환경별 설정
          options.environment = AppConfig.current.environment;

          // 디버그 모드 설정
          options.debug = AppConfig.current.isDebugMode;

          // 릴리즈 추적 설정
          options.release = 'aipet_frontend@1.0.0+1';

          // 샘플링 설정 (성능 모니터링) - 프로파일링 충돌 방지를 위해 낮게 설정
          options.tracesSampleRate = AppConfig.current.isDebugMode ? 0.1 : 0.05;

          // Flutter 특화 설정
          options.attachStacktrace = true;

          // 프로파일링 비활성화 (크래시 방지)
          options.profilesSampleRate = 0.0;

          // ANR (Application Not Responding) 감지 비활성화
          options.enableAutoNativeBreadcrumbs = false;

          // 네이티브 크래시 모니터링만 활성화
          options.enableAutoSessionTracking = false;
        },
        appRunner: () {}, // 빈 함수 (이미 앱이 실행 중이므로)
      );
      debugPrint('✅ Sentry initialized successfully (profiling disabled)');
    } catch (e) {
      debugPrint('⚠️ Sentry initialization failed: $e');
      // Sentry 초기화 실패해도 앱은 계속 실행
    }
  }

  /// 환경별 앱 설정을 초기화합니다.
  ///
  /// 환경 변수에 따라 개발/스테이징/프로덕션 설정을 선택합니다.
  static void _initializeAppConfig() {
    // 환경 변수에 따른 설정 선택
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );

    switch (environment) {
      case 'production':
        AppConfig.initialize(ProductionConfig());
        break;
      case 'staging':
        AppConfig.initialize(StagingConfig());
        break;
      default:
        AppConfig.initialize(DevelopmentConfig());
        break;
    }
  }

  /// 이미지 캐시 최적화 설정을 초기화합니다.
  ///
  /// ImageReader 버퍼 문제를 해결하기 위한 캐시 설정을 적용합니다.
  static void _initializeImageCache() {
    try {
      // 이미지 캐시 크기를 더 적극적으로 제한
      PaintingBinding.instance.imageCache.maximumSize =
          50; // 기본값 1000에서 50으로 축소
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          50 << 20; // 50MB (기본값 100MB에서 축소)

      debugPrint('✅ Image cache optimized: maxSize=50, maxSizeBytes=50MB');
    } catch (e) {
      debugPrint('⚠️ Image cache initialization failed: $e');
      // 캐시 설정 실패해도 앱은 계속 실행
    }
  }

  /// 로컬 데이터 매니저를 초기화합니다.
  ///
  /// SharedPreferences와 FlutterSecureStorage를 초기화합니다.
  static Future<void> _initializeLocalDataManager() async {
    try {
      await LocalDataManager.instance.initialize();
      debugPrint('✅ LocalDataManager initialized successfully');
    } catch (e) {
      debugPrint('⚠️ LocalDataManager initialization failed: $e');
      // LocalDataManager 초기화 실패해도 앱은 계속 실행
    }
  }

  /// 로컬 스토리지 서비스를 초기화합니다.
  ///
  /// SQLite 데이터베이스와 로컬 서비스들을 초기화합니다.
  static Future<void> _initializeLocalStorage() async {
    try {
      await LocalStorageService.instance.initialize();
      debugPrint('✅ LocalStorageService initialized successfully');
    } catch (e) {
      debugPrint('⚠️ LocalStorageService initialization failed: $e');
      // LocalStorageService 초기화 실패해도 앱은 계속 실행
    }
  }

  /// 펫 관련 캐시를 클리어합니다.
  ///
  /// 앱 시작 시 목업 데이터가 남아있지 않도록 캐시를 초기화합니다.
  static Future<void> _clearPetCache() async {
    try {
      // 강제 리셋으로 모든 펫 데이터 완전 제거
      final resetResult = await PetDataResetUtil.forceResetAllPetData();
      if (resetResult) {
        debugPrint('✅ Pet data force reset completed successfully');
      } else {
        debugPrint('⚠️ Pet data force reset failed, trying cache clear');
        await PetCacheClearService.clearAllPetCache();
      }

      // 디버그 정보 출력
      await PetDataResetUtil.printDebugInfo();
    } catch (e) {
      debugPrint('⚠️ Pet cache clear failed: $e');
      // 캐시 클리어 실패해도 앱은 계속 실행
    }
  }

  static Widget createApp() {
    return const AIPetApp();
  }

  /// 초기화 상태를 로그에 출력합니다.
  ///
  /// 개발 모드에서만 호출되며, 각 초기화 단계의 성공/실패 상태를 확인할 수 있습니다.
  static void _logInitializationStatus(bool isFirebaseInitialized) {
    debugPrint('📋 === App Initialization Status ===');
    debugPrint('🔧 Environment: ${AppConfig.current.environment}');
    debugPrint(
      '🔥 Firebase: ${isFirebaseInitialized ? '✅ Initialized' : '❌ Failed'}',
    );
    debugPrint(
      '📱 Sentry: ${dotenv.env['SENTRY_DSN'] != null ? '✅ Configured' : '⚠️ Not configured'}',
    );
    debugPrint('🖼️ Image Cache: ✅ Optimized (50 items, 50MB)');
    debugPrint('🌐 HTTP Client: ✅ Token repository connected');
    debugPrint('🧹 Pet Cache: ✅ Cleared (mock data removed)');
    debugPrint('📋 === Initialization Complete ===');
  }
}

/// 메인 앱 위젯
///
/// 앱의 최상위 위젯으로, 초기화 상태에 따라 적절한 UI를 표시합니다.
class AIPetApp extends ConsumerStatefulWidget {
  const AIPetApp({super.key});

  @override
  ConsumerState<AIPetApp> createState() => _AIPetAppState();
}

class _AIPetAppState extends ConsumerState<AIPetApp> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // 앱이 처음 시작될 때만 초기화 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        _hasInitialized = true;
        ref.read(appInitializationProvider.notifier).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final initializationState = ref.watch(appInitializationProvider);

    // 단일 MaterialApp.router로 모든 상태 처리
    return _buildMainApp(router, initializationState);
  }

  /// 메인 앱 UI를 구성합니다.
  ///
  /// 앱 초기화 상태에 따라 적절한 UI를 표시하는 단일 MaterialApp.router를 반환합니다.
  Widget _buildMainApp(
    GoRouter router,
    AppInitializationState initializationState,
  ) {
    return MaterialApp.router(
      title: 'AI Pet',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: const Locale('ja', 'JP'),
      theme: AppTheme.light.copyWith(
        primaryColor: AppColors.pointBrown,
        scaffoldBackgroundColor: AppColors.pointOffWhite,
        colorScheme: const ColorScheme.light(
          primary: AppColors.pointBrown,
          surface: AppColors.pointOffWhite,
          onPrimary: AppColors.pointOffWhite,
          onSurface: AppColors.pointDark,
        ),
        // 앱바 테마
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.pointBrown,
          foregroundColor: AppColors.pointOffWhite,
          elevation: 0,
          centerTitle: true,
        ),
        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.pointBrown,
            foregroundColor: AppColors.pointOffWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        // 초기화 상태에 따른 UI 처리
        if (initializationState.isLoading) {
          return _buildLoadingContent();
        }

        if (initializationState.error != null) {
          return _buildErrorContent(initializationState.error!, ref);
        }

        // 정상 상태에서는 child (라우터 콘텐츠) 표시
        return child ?? const SizedBox.shrink();
      },
    );
  }

  /// 로딩 콘텐츠를 구성합니다.
  Widget _buildLoadingContent() {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie 로딩 애니메이션
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/lottie/loading.json',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 에러 콘텐츠를 구성합니다.
  Widget _buildErrorContent(String error, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.pointBrown,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '앱 초기화 중 오류가 발생했습니다',
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                error,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  // 앱 재시작 또는 초기화 재시도
                  ref.read(appInitializationProvider.notifier).initialize();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBrown,
                  foregroundColor: AppColors.pointOffWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: const Text('リフレッシュ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
