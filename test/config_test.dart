import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig API Keys Test', () {
    test('DevelopmentConfig should return empty strings for API keys', () {
      final config = DevelopmentConfig();
      
      expect(config.openaiApiKey, equals(''));
      expect(config.weatherApiKey, equals(''));
      expect(config.googleMapsApiKey, equals(''));
      expect(config.lineChannelId, equals(''));
    });

    test('StagingConfig should return empty strings for API keys', () {
      final config = StagingConfig();
      
      expect(config.openaiApiKey, equals(''));
      expect(config.weatherApiKey, equals(''));
      expect(config.googleMapsApiKey, equals(''));
      expect(config.lineChannelId, equals(''));
    });

    test('ProductionConfig should return empty strings for API keys', () {
      final config = ProductionConfig();
      
      expect(config.openaiApiKey, equals(''));
      expect(config.weatherApiKey, equals(''));
      expect(config.googleMapsApiKey, equals(''));
      expect(config.lineChannelId, equals(''));
    });

    test('AppConfig.current should return empty strings for API keys', () {
      expect(AppConfig.current.openaiApiKey, equals(''));
      expect(AppConfig.current.weatherApiKey, equals(''));
      expect(AppConfig.current.googleMapsApiKey, equals(''));
      expect(AppConfig.current.lineChannelId, equals(''));
    });
  });
}