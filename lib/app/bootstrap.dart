import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/shared.dart';
import 'config/app_config.dart';
import 'providers/app_initialization_provider.dart';
import 'providers/router_provider.dart';

/// 앱의 메인 위젯을 생성합니다.
class AppBootstrap {
  /// 앱 초기화 및 설정
  static void initialize() {
    // 환경별 설정 초기화
    _initializeAppConfig();
  }

  /// 환경별 앱 설정 초기화
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

  /// 로딩 중 앱 UI
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
              // 로딩 애니메이션 (Lottie 사용 권장)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '앱을 초기화하고 있습니다...',
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 에러 상태 앱 UI
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
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 메인 앱 UI
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
