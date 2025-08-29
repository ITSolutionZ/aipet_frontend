import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Environment Config Classes Test', () {
    test('DevelopmentConfig should have correct environment settings', () {
      final config = DevelopmentConfig();
      
      expect(config.environment, equals('development'));
      expect(config.isDebugMode, isTrue);
      expect(config.enableLogging, isTrue);
      expect(config.enableAnalytics, isFalse);
      expect(config.apiBaseUrl, equals('https://dev-api.aipet.com'));
      expect(config.apiTimeoutMs, equals(10000));
    });

    test('StagingConfig should have correct environment settings', () {
      final config = StagingConfig();
      
      expect(config.environment, equals('staging'));
      expect(config.isDebugMode, isTrue);
      expect(config.enableLogging, isTrue);
      expect(config.enableAnalytics, isTrue);
      expect(config.apiBaseUrl, equals('https://staging-api.aipet.com'));
      expect(config.apiTimeoutMs, equals(15000));
    });

    test('ProductionConfig should have correct environment settings', () {
      final config = ProductionConfig();
      
      expect(config.environment, equals('production'));
      expect(config.isDebugMode, isFalse);
      expect(config.enableLogging, isFalse);
      expect(config.enableAnalytics, isTrue);
      expect(config.apiBaseUrl, equals('https://api.aipet.com'));
      expect(config.apiTimeoutMs, equals(20000));
    });

    test('AppConfig initialization should work correctly', () {
      // Test current default (DevelopmentConfig)
      expect(AppConfig.current, isA<DevelopmentConfig>());
      
      // Test initialization with StagingConfig
      AppConfig.initialize(StagingConfig());
      expect(AppConfig.current, isA<StagingConfig>());
      expect(AppConfig.current.environment, equals('staging'));
      
      // Test initialization with ProductionConfig
      AppConfig.initialize(ProductionConfig());
      expect(AppConfig.current, isA<ProductionConfig>());
      expect(AppConfig.current.environment, equals('production'));
      
      // Reset to DevelopmentConfig for other tests
      AppConfig.initialize(DevelopmentConfig());
    });
  });
}