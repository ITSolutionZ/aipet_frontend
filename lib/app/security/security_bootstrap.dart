import 'package:aipet_frontend/shared/performance/performance_monitor.dart';
import 'package:aipet_frontend/shared/security/environment_config.dart';
import 'package:aipet_frontend/shared/security/production_security_validator.dart';
import 'package:flutter/foundation.dart';

/// 🛡️ 보안 부트스트랩 시스템
///
/// 앱 시작 시 보안 검증과 성능 모니터링을 초기화합니다.
class SecurityBootstrap {
  static bool _isInitialized = false;

  /// 보안 시스템 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. 환경 설정 검증
      await _validateEnvironmentConfiguration();

      // 2. 보안 검증 실행
      await _runSecurityValidations();

      // 3. 성능 모니터링 시작
      await _initializePerformanceMonitoring();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('🛡️ Security system initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Security system initialization failed: $e');
      }

      // 프로덕션 환경에서는 보안 검증 실패 시 앱 종료
      if (kReleaseMode) {
        throw SecurityBootstrapException('Security system initialization failed: ${e.toString()}');
      }
    }
  }

  /// 환경 설정 검증
  static Future<void> _validateEnvironmentConfiguration() async {
    try {
      EnvironmentConfig.validateConfiguration();

      if (kDebugMode) {
        final envInfo = EnvironmentConfig.getEnvironmentInfo();
        debugPrint('🔧 Environment Configuration:');
        envInfo.forEach((key, value) {
          debugPrint('  $key: $value');
        });
      }
    } catch (e) {
      throw SecurityBootstrapException(
        'Environment configuration validation failed: ${e.toString()}',
      );
    }
  }

  /// 보안 검증 실행
  static Future<void> _runSecurityValidations() async {
    try {
      // 프로덕션 환경에서만 보안 검증 실행
      if (EnvironmentConfig.isSecurityValidationEnabled) {
        ProductionSecurityValidator.runAllSecurityValidations();

        if (kDebugMode) {
          debugPrint('✅ Security validations passed');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Security validations skipped (development mode)');
        }
      }
    } catch (e) {
      throw SecurityBootstrapException('Security validation failed: ${e.toString()}');
    }
  }

  /// 성능 모니터링 초기화
  static Future<void> _initializePerformanceMonitoring() async {
    try {
      if (EnvironmentConfig.isPerformanceMonitoringEnabled) {
        PerformanceMonitor.instance.startMonitoring();

        if (kDebugMode) {
          debugPrint('📊 Performance monitoring started');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ Performance monitoring disabled');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Performance monitoring initialization failed: $e');
      }
      // 성능 모니터링 실패는 앱 종료하지 않음
    }
  }

  /// 보안 시스템 종료
  static Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      // 성능 모니터링 중지
      PerformanceMonitor.instance.stopMonitoring();

      _isInitialized = false;

      if (kDebugMode) {
        debugPrint('🛡️ Security system disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Security system disposal failed: $e');
      }
    }
  }

  /// 보안 상태 확인
  static bool get isInitialized => _isInitialized;

  /// 보안 리포트 생성
  static Map<String, dynamic> generateSecurityReport() {
    return {
      'isInitialized': _isInitialized,
      'environment': EnvironmentConfig.currentEnvironment.name,
      'isSecurityValidationEnabled': EnvironmentConfig.isSecurityValidationEnabled,
      'isPerformanceMonitoringEnabled': EnvironmentConfig.isPerformanceMonitoringEnabled,
      'isMockModeAllowed': EnvironmentConfig.isMockModeAllowed,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// 보안 부트스트랩 예외 클래스
class SecurityBootstrapException implements Exception {
  final String message;

  const SecurityBootstrapException(this.message);

  @override
  String toString() => 'SecurityBootstrapException: $message';
}
