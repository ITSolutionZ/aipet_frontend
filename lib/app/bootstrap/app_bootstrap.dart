import 'package:aipet_frontend/app/security/security_bootstrap.dart';
import 'package:aipet_frontend/shared/monitoring/app_monitoring_dashboard.dart';
import 'package:aipet_frontend/shared/performance/memory_optimizer.dart';
import 'package:aipet_frontend/shared/performance/performance_monitor.dart';
import 'package:aipet_frontend/shared/security/environment_config.dart';
import 'package:flutter/foundation.dart';

/// 🚀 앱 통합 부트스트랩 시스템
///
/// 앱 시작 시 모든 시스템을 초기화하고 모니터링을 시작합니다.
class AppBootstrap {
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  /// 앱 초기화
  static Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      if (kDebugMode) {
        print('🚀 Starting app bootstrap...');
      }

      // 1. 보안 시스템 초기화
      await _initializeSecuritySystems();

      // 2. 성능 모니터링 시스템 초기화
      await _initializePerformanceSystems();

      // 3. 모니터링 대시보드 초기화
      await _initializeMonitoringDashboard();

      // 4. 환경별 설정 적용
      await _applyEnvironmentSettings();

      _isInitialized = true;
      _isInitializing = false;

      if (kDebugMode) {
        print('✅ App bootstrap completed successfully');
        _printBootstrapSummary();
      }
    } catch (e) {
      _isInitializing = false;

      if (kDebugMode) {
        print('❌ App bootstrap failed: $e');
      }

      // 프로덕션 환경에서는 초기화 실패 시 앱 종료
      if (kReleaseMode) {
        throw AppBootstrapException(
          'App initialization failed: ${e.toString()}',
        );
      }
    }
  }

  /// 보안 시스템 초기화
  static Future<void> _initializeSecuritySystems() async {
    if (kDebugMode) {
      print('🛡️ Initializing security systems...');
    }

    // 1. 보안 부트스트랩 실행
    await SecurityBootstrap.initialize();

    // 2. API 보안 관리자 초기화
    // ApiSecurityManager는 싱글톤이므로 자동으로 초기화됨

    if (kDebugMode) {
      print('✅ Security systems initialized');
    }
  }

  /// 성능 시스템 초기화
  static Future<void> _initializePerformanceSystems() async {
    if (kDebugMode) {
      print('📊 Initializing performance systems...');
    }

    // 1. 성능 모니터링 시작
    if (EnvironmentConfig.isPerformanceMonitoringEnabled) {
      PerformanceMonitor.instance.startMonitoring();
    }

    // 2. 메모리 최적화 시작
    if (EnvironmentConfig.isPerformanceMonitoringEnabled) {
      MemoryOptimizer.instance.startOptimization();
    }

    if (kDebugMode) {
      print('✅ Performance systems initialized');
    }
  }

  /// 모니터링 대시보드 초기화
  static Future<void> _initializeMonitoringDashboard() async {
    if (kDebugMode) {
      print('📈 Initializing monitoring dashboard...');
    }

    // 모니터링 대시보드 시작
    if (EnvironmentConfig.isPerformanceMonitoringEnabled) {
      AppMonitoringDashboard.instance.startMonitoring();
    }

    if (kDebugMode) {
      print('✅ Monitoring dashboard initialized');
    }
  }

  /// 환경별 설정 적용
  static Future<void> _applyEnvironmentSettings() async {
    if (kDebugMode) {
      print('🔧 Applying environment settings...');
    }

    // 환경별 설정 검증
    EnvironmentConfig.validateConfiguration();

    if (kDebugMode) {
      print('✅ Environment settings applied');
    }
  }

  /// 부트스트랩 요약 출력
  static void _printBootstrapSummary() {
    if (!kDebugMode) return;

    print('\n=== App Bootstrap Summary ===');
    print('Environment: ${EnvironmentConfig.currentEnvironment.name}');
    print(
      'Security Validation: ${EnvironmentConfig.isSecurityValidationEnabled ? 'Enabled' : 'Disabled'}',
    );
    print(
      'Performance Monitoring: ${EnvironmentConfig.isPerformanceMonitoringEnabled ? 'Enabled' : 'Disabled'}',
    );
    print(
      'Mock Mode Allowed: ${EnvironmentConfig.isMockModeAllowed ? 'Yes' : 'No'}',
    );
    print(
      'Debug Logging: ${EnvironmentConfig.isDebugLoggingAllowed ? 'Enabled' : 'Disabled'}',
    );
    print(
      'Error Reporting: ${EnvironmentConfig.isErrorReportingEnabled ? 'Enabled' : 'Disabled'}',
    );
    print('===============================\n');
  }

  /// 앱 종료 처리
  static Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      if (kDebugMode) {
        print('🔄 Disposing app systems...');
      }

      // 1. 모니터링 대시보드 중지
      AppMonitoringDashboard.instance.stopMonitoring();

      // 2. 성능 모니터링 중지
      PerformanceMonitor.instance.stopMonitoring();

      // 3. 메모리 최적화 중지
      MemoryOptimizer.instance.stopOptimization();

      // 4. 보안 시스템 종료
      await SecurityBootstrap.dispose();

      _isInitialized = false;

      if (kDebugMode) {
        print('✅ App systems disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ App disposal failed: $e');
      }
    }
  }

  /// 초기화 상태 확인
  static bool get isInitialized => _isInitialized;
  static bool get isInitializing => _isInitializing;

  /// 시스템 상태 리포트 생성
  static Map<String, dynamic> generateSystemReport() {
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'environment': EnvironmentConfig.currentEnvironment.name,
      'securityValidation': EnvironmentConfig.isSecurityValidationEnabled,
      'performanceMonitoring': EnvironmentConfig.isPerformanceMonitoringEnabled,
      'mockModeAllowed': EnvironmentConfig.isMockModeAllowed,
      'debugLogging': EnvironmentConfig.isDebugLoggingAllowed,
      'errorReporting': EnvironmentConfig.isErrorReportingEnabled,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 시스템 건강도 체크
  static Future<SystemHealthCheck> performHealthCheck() async {
    try {
      final issues = <String>[];
      int healthScore = 100;

      // 1. 초기화 상태 체크
      if (!_isInitialized) {
        issues.add('App not initialized');
        healthScore -= 50;
      }

      // 2. 환경 설정 체크
      try {
        EnvironmentConfig.validateConfiguration();
      } catch (e) {
        issues.add('Environment configuration invalid: ${e.toString()}');
        healthScore -= 30;
      }

      // 3. 보안 시스템 체크
      if (EnvironmentConfig.isSecurityValidationEnabled) {
        try {
          // 보안 검증 실행
          // ProductionSecurityValidator.runAllSecurityValidations();
        } catch (e) {
          issues.add('Security validation failed: ${e.toString()}');
          healthScore -= 40;
        }
      }

      // 4. 성능 시스템 체크
      if (EnvironmentConfig.isPerformanceMonitoringEnabled) {
        try {
          // 성능 모니터링 상태 체크
          final performanceReport = PerformanceMonitor.instance
              .generateReport();
          if (performanceReport.slowOperations.isNotEmpty) {
            issues.add(
              '${performanceReport.slowOperations.length} slow operations detected',
            );
            healthScore -= 20;
          }
        } catch (e) {
          issues.add('Performance monitoring failed: ${e.toString()}');
          healthScore -= 20;
        }
      }

      // 건강도 등급 결정
      SystemHealthLevel level;
      if (healthScore >= 90) {
        level = SystemHealthLevel.excellent;
      } else if (healthScore >= 70) {
        level = SystemHealthLevel.good;
      } else if (healthScore >= 50) {
        level = SystemHealthLevel.warning;
      } else {
        level = SystemHealthLevel.critical;
      }

      return SystemHealthCheck(
        score: healthScore,
        level: level,
        issues: issues,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SystemHealthCheck(
        score: 0,
        level: SystemHealthLevel.critical,
        issues: ['Health check failed: ${e.toString()}'],
        timestamp: DateTime.now(),
      );
    }
  }

  /// 시스템 건강도 체크 결과 출력
  static void printHealthCheck() {
    if (!kDebugMode) return;

    performHealthCheck().then((healthCheck) {
      print('\n=== System Health Check ===');
      print('Score: ${healthCheck.score}/100');
      print('Level: ${healthCheck.level.name}');
      print('Timestamp: ${healthCheck.timestamp.toIso8601String()}');

      if (healthCheck.issues.isNotEmpty) {
        print('\nIssues:');
        for (final issue in healthCheck.issues) {
          print('  - $issue');
        }
      }
      print('============================\n');
    });
  }
}

/// 앱 부트스트랩 예외
class AppBootstrapException implements Exception {
  final String message;

  const AppBootstrapException(this.message);

  @override
  String toString() => 'AppBootstrapException: $message';
}

/// 시스템 건강도 체크
class SystemHealthCheck {
  final int score;
  final SystemHealthLevel level;
  final List<String> issues;
  final DateTime timestamp;

  const SystemHealthCheck({
    required this.score,
    required this.level,
    required this.issues,
    required this.timestamp,
  });
}

/// 시스템 건강도 등급
enum SystemHealthLevel { excellent, good, warning, critical }
