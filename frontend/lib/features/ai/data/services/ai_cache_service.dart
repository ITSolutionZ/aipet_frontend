import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:flutter/foundation.dart';

import 'ai_cache_strategy.dart';

/// 🎯 AI 캐시 서비스 (最適化版)
///
/// AI 관련 데이터의 캐싱을 담당
/// - カテゴリ別タイムアウト設定
/// - メモリ使用量の監視
/// - 優先度ベースの自動削除
class AiCacheService extends BaseLoggingService {
  // 캐시 저장소
  final Map<String, dynamic> _cache = {};
  final Map<String, CacheMetadata> _cacheMetadata = {};

  // メモリ制限: 50MB
  static const int maxMemoryBytes = 50 * 1024 * 1024;

  AiCacheService() : super('ai_cache');

  /// 캐시에서 데이터 가져오기 (最適化版)
  T? getFromCache<T>(String key) {
    if (!_cache.containsKey(key) || !_cacheMetadata.containsKey(key)) {
      logDebug('Cache miss for key: $key');
      return null;
    }

    final metadata = _cacheMetadata[key]!;

    // 有効期限チェック
    if (metadata.isExpired) {
      logDebug(
        'Cache expired for key: $key (expired ${metadata.remainingTime.abs()} ago)',
      );
      _removeFromCache(key);
      return null;
    }

    logDebug(
      'Cache hit for key: $key (${metadata.remainingTime.inMinutes}min remaining)',
    );
    return _cache[key] as T?;
  }

  /// 캐시에 데이터 저장하기 (最適化版)
  void setCache<T>(String key, T data) {
    // メモリチェック & 自動クリーンアップ
    _checkAndCleanupMemory();

    // メタデータ作成
    final metadata = CacheMetadata(
      key: key,
      timestamp: DateTime.now(),
      timeout: AiCacheStrategy.getTimeoutForKey(key),
      priority: AiCacheStrategy.getPriorityForKey(key),
      sizeBytes: AiCacheStrategy.estimateSizeInBytes(key, data),
    );

    _cache[key] = data;
    _cacheMetadata[key] = metadata;

    logDebug(
      'Data cached for key: $key '
      '(timeout: ${metadata.timeout.inMinutes}min, '
      'priority: ${metadata.priority}, '
      'size: ${metadata.sizeBytes} bytes)',
    );
  }

  /// キャッシュから削除 (内部用)
  void _removeFromCache(String key) {
    _cache.remove(key);
    _cacheMetadata.remove(key);
  }

  /// メモリチェック & 自動クリーンアップ
  void _checkAndCleanupMemory() {
    final currentMemory = _calculateTotalMemory();

    if (currentMemory > maxMemoryBytes) {
      logWarning(
        'Memory limit exceeded: ${currentMemory ~/ (1024 * 1024)}MB / ${maxMemoryBytes ~/ (1024 * 1024)}MB',
      );
      _cleanupByPriority();
    }
  }

  /// 総メモリ使用量を計算
  int _calculateTotalMemory() {
    return _cacheMetadata.values.fold<int>(
      0,
      (sum, metadata) => sum + metadata.sizeBytes,
    );
  }

  /// 優先度ベースでクリーンアップ
  void _cleanupByPriority() {
    // 優先度の低い順にソート
    final sortedEntries = _cacheMetadata.entries.toList()
      ..sort((a, b) {
        // 優先度が低い && 有効期限に近い ものから削除
        final priorityCompare = a.value.priority.compareTo(b.value.priority);
        if (priorityCompare != 0) return priorityCompare;
        return b.value.expirationProgress.compareTo(a.value.expirationProgress);
      });

    // 下位20%を削除
    final deleteCount = (sortedEntries.length * 0.2).ceil();
    final toDelete = sortedEntries.take(deleteCount);

    for (final entry in toDelete) {
      _removeFromCache(entry.key);
      logInfo('Cleaned up low-priority cache: ${entry.key}');
    }

    final afterMemory = _calculateTotalMemory();
    logInfo(
      'Cleanup completed: freed ${(_calculateTotalMemory() - afterMemory) ~/ (1024 * 1024)}MB',
    );
  }

  /// 캐시 초기화
  void clearCache() {
    final count = _cache.length;
    _cache.clear();
    _cacheMetadata.clear();
    logInfo('Cache cleared ($count entries removed)');
  }

  /// 특정 키의 캐시 제거
  void clearCacheForKey(String key) {
    _removeFromCache(key);
    logInfo('Cache cleared for key: $key');
  }

  /// プレフィックスに一致するキャッシュを削除
  void clearCacheByPrefix(String prefix) {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _removeFromCache(key);
    }
    logInfo(
      'Cache cleared for prefix: $prefix (${keysToRemove.length} entries)',
    );
  }

  /// 캐시 상태 정보 가져오기 (詳細版)
  Map<String, dynamic> getCacheStatus() {
    final status = <String, dynamic>{
      'totalKeys': _cache.length,
      'totalMemoryMB': (_calculateTotalMemory() / (1024 * 1024))
          .toStringAsFixed(2),
      'maxMemoryMB': (maxMemoryBytes / (1024 * 1024)).toStringAsFixed(0),
      'memoryUsagePercent': ((_calculateTotalMemory() / maxMemoryBytes) * 100)
          .toStringAsFixed(1),
      'keys': <String>[],
      'expiredKeys': <String>[],
      'metadata': <Map<String, dynamic>>[],
    };

    for (final entry in _cacheMetadata.entries) {
      status['keys'].add(entry.key);

      if (entry.value.isExpired) {
        status['expiredKeys'].add(entry.key);
      }

      status['metadata'].add({
        'key': entry.key,
        'priority': entry.value.priority,
        'sizeKB': (entry.value.sizeBytes / 1024).toStringAsFixed(2),
        'remainingMin': entry.value.remainingTime.inMinutes,
        'expirationProgress': (entry.value.expirationProgress * 100)
            .toStringAsFixed(1),
      });
    }

    return status;
  }

  /// 캐시 만료된 항목들 자동 정리
  void cleanupExpiredCache() {
    final expiredKeys = _cacheMetadata.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _removeFromCache(key);
    }

    if (expiredKeys.isNotEmpty) {
      logInfo('Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }

  /// キャッシュ統計情報 (デバッグ用)
  void printCacheStatistics() {
    if (!kDebugMode) return;

    final status = getCacheStatus();
    LoggerService.debug('=== AI Cache Statistics ===');
    LoggerService.debug('Total Keys: ${status['totalKeys']}');
    LoggerService.debug(
      'Memory Usage: ${status['totalMemoryMB']}MB / ${status['maxMemoryMB']}MB (${status['memoryUsagePercent']}%)',
    );
    LoggerService.debug('Expired Keys: ${(status['expiredKeys'] as List).length}');

    // 優先度別の集計
    final metadataList = status['metadata'] as List<Map<String, dynamic>>;
    final byPriority = <int, int>{};
    for (final meta in metadataList) {
      final priority = meta['priority'] as int;
      byPriority[priority] = (byPriority[priority] ?? 0) + 1;
    }

    LoggerService.debug('By Priority:');
    for (final entry
        in byPriority.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key))) {
      LoggerService.debug('  Priority ${entry.key}: ${entry.value} entries');
    }
    LoggerService.debug('===========================');
  }
}
