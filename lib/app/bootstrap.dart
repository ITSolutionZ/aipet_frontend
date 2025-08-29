import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/services/firebase_token_service.dart';
import '../firebase_options.dart';
import '../shared/shared.dart';
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
        'Call FirebaseManager.initialize() first.'
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
    // .env 파일 로드
    await dotenv.load(fileName: '.env');
    
    // 환경별 설정 초기화
    _initializeAppConfig();

    // Firebase 초기화 (옵션, 설정 파일이 있는 경우에만)
    final isFirebaseInitialized = await FirebaseManager.initialize();

    // Firebase가 성공적으로 초기화된 경우에만 인증 상태 리스너 설정
    if (isFirebaseInitialized) {
      try {
        FirebaseTokenService.setupAuthStateListener();
        debugPrint('✅ Firebase Auth State Listener setup');
      } catch (e) {
        debugPrint('⚠️ Firebase Auth State Listener setup failed: $e');
      }
    }

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

  static Widget createApp() {
    return const AIPetApp();
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
  @override
  void initState() {
    super.initState();
    // 앱 초기화 수행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appInitializationProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final initializationState = ref.watch(appInitializationProvider);

    // 초기화 상태에 따른 처리
    if (initializationState.isLoading) {
      return _buildLoadingApp();
    }

    if (initializationState.error != null) {
      return _buildErrorApp(initializationState.error!);
    }

    return _buildMainApp(router);
  }

  /// 로딩 중 앱 UI를 구성합니다.
  ///
  /// 앱 초기화가 진행 중일 때 표시되는 로딩 화면을 반환합니다.
  Widget _buildLoadingApp() {
    return MaterialApp(
      title: 'AI Pet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 브랜드 로딩 애니메이션
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'アプリを初期化しています...',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 에러 상태 앱 UI를 구성합니다.
  ///
  /// 앱 초기화 중 오류가 발생했을 때 표시되는 에러 화면을 반환합니다.
  Widget _buildErrorApp(String error) {
    return MaterialApp(
      title: 'AI Pet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
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
                  'アプリ初期化中にエラーが発生しました',
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
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 메인 앱 UI를 구성합니다.
  ///
  /// 앱 초기화가 완료된 후 표시되는 메인 앱 화면을 반환합니다.
  Widget _buildMainApp(GoRouter router) {
    return MaterialApp.router(
      title: 'AI Pet',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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
    );
  }
}
