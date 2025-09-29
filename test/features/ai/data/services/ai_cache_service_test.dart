import 'package:aipet_frontend/features/ai/data/services/ai_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiCacheService', () {
    late AiCacheService cacheService;

    setUp(() {
      cacheService = AiCacheService();
    });

    tearDown(() {
      cacheService.clearCache();
    });

    test('should store and retrieve data from cache', () {
      // Arrange
      const key = 'test_key';
      const data = 'test_data';

      // Act
      cacheService.setCache(key, data);
      final result = cacheService.getFromCache<String>(key);

      // Assert
      expect(result, data);
    });

    test('should return null for non-existent key', () {
      // Act
      final result = cacheService.getFromCache<String>('non_existent_key');

      // Assert
      expect(result, isNull);
    });

    test('should clear cache', () {
      // Arrange
      cacheService.setCache('key1', 'data1');
      cacheService.setCache('key2', 'data2');

      // Act
      cacheService.clearCache();
      final result1 = cacheService.getFromCache<String>('key1');
      final result2 = cacheService.getFromCache<String>('key2');

      // Assert
      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('should clear specific key', () {
      // Arrange
      cacheService.setCache('key1', 'data1');
      cacheService.setCache('key2', 'data2');

      // Act
      cacheService.clearCacheForKey('key1');
      final result1 = cacheService.getFromCache<String>('key1');
      final result2 = cacheService.getFromCache<String>('key2');

      // Assert
      expect(result1, isNull);
      expect(result2, 'data2');
    });

    test('should return cache status', () {
      // Arrange
      cacheService.setCache('key1', 'data1');
      cacheService.setCache('key2', 'data2');

      // Act
      final status = cacheService.getCacheStatus();

      // Assert
      expect(status['totalKeys'], 2);
      expect(status['keys'], contains('key1'));
      expect(status['keys'], contains('key2'));
    });

    test('should handle different data types', () {
      // Arrange
      const stringKey = 'string_key';
      const stringData = 'string_data';
      const intKey = 'int_key';
      const intData = 42;
      const boolKey = 'bool_key';
      const boolData = true;

      // Act
      cacheService.setCache(stringKey, stringData);
      cacheService.setCache(intKey, intData);
      cacheService.setCache(boolKey, boolData);

      final stringResult = cacheService.getFromCache<String>(stringKey);
      final intResult = cacheService.getFromCache<int>(intKey);
      final boolResult = cacheService.getFromCache<bool>(boolKey);

      // Assert
      expect(stringResult, stringData);
      expect(intResult, intData);
      expect(boolResult, boolData);
    });
  });
}
