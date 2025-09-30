import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 🧠 메모리 최적화 시스템
///
/// 메모리 사용량을 실시간으로 모니터링하고 자동으로 최적화합니다.
class MemoryOptimizer {
  static MemoryOptimizer? _instance;
  static MemoryOptimizer get instance => _instance ??= MemoryOptimizer._();

  MemoryOptimizer._();

  Timer? _optimizationTimer;
  final List<MemorySnapshot> _memoryHistory = [];

  // 메모리 임계치 설정
  static const double _warningThreshold = 0.7; // 70%
  static const double _criticalThreshold = 0.85; // 85%
  static const double _emergencyThreshold = 0.95; // 95%

  // 최적화 설정
  static const int _maxHistorySize = 100;
  static const Duration _optimizationInterval = Duration(seconds: 30);

  /// 메모리 최적화 시작
  void startOptimization() {
    if (_optimizationTimer != null) return;

    _optimizationTimer = Timer.periodic(_optimizationInterval, (_) {
      _performMemoryOptimization();
    });

    if (kDebugMode) {
      debugPrint('🧠 Memory optimization started');
    }
  }

  /// 메모리 최적화 중지
  void stopOptimization() {
    _optimizationTimer?.cancel();
    _optimizationTimer = null;

    if (kDebugMode) {
      debugPrint('🧠 Memory optimization stopped');
    }
  }

  /// 현재 메모리 사용량 측정
  Future<MemoryInfo> getCurrentMemoryInfo() async {
    try {
      final processInfo = ProcessInfo.currentRss;
      final systemMemory = await _getSystemMemoryInfo();

      final memoryInfo = MemoryInfo(
        processMemory: processInfo,
        systemMemory: systemMemory,
        timestamp: DateTime.now(),
      );

      _recordMemorySnapshot(memoryInfo);
      return memoryInfo;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get memory info: $e');
      }
      return MemoryInfo.unknown();
    }
  }

  /// 시스템 메모리 정보 가져오기
  Future<SystemMemoryInfo?> _getSystemMemoryInfo() async {
    try {
      // 플랫폼별 메모리 정보 수집
      if (Platform.isAndroid) {
        return await _getAndroidMemoryInfo();
      } else if (Platform.isIOS) {
        return await _getIOSMemoryInfo();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get system memory info: $e');
      }
      return null;
    }
  }

  /// Android 메모리 정보
  Future<SystemMemoryInfo?> _getAndroidMemoryInfo() async {
    try {
      // Android의 경우 /proc/meminfo에서 정보 수집
      final result = await Process.run('cat', ['/proc/meminfo']);
      if (result.exitCode == 0) {
        return _parseMemInfo(result.stdout);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get Android memory info: $e');
      }
    }
    return null;
  }

  /// iOS 메모리 정보
  Future<SystemMemoryInfo?> _getIOSMemoryInfo() async {
    try {
      // iOS의 경우 vm_stat 명령어 사용
      final result = await Process.run('vm_stat', []);
      if (result.exitCode == 0) {
        return _parseVmStat(result.stdout);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to get iOS memory info: $e');
      }
    }
    return null;
  }

  /// /proc/meminfo 파싱
  SystemMemoryInfo? _parseMemInfo(String output) {
    try {
      final lines = output.split('\n');
      int totalMem = 0;
      int availableMem = 0;

      for (final line in lines) {
        if (line.startsWith('MemTotal:')) {
          totalMem = int.tryParse(line.split(RegExp(r'\s+'))[1]) ?? 0;
        } else if (line.startsWith('MemAvailable:')) {
          availableMem = int.tryParse(line.split(RegExp(r'\s+'))[1]) ?? 0;
        }
      }

      if (totalMem > 0) {
        return SystemMemoryInfo(
          totalMemory: totalMem * 1024, // KB to bytes
          availableMemory: availableMem * 1024,
          usedMemory: (totalMem - availableMem) * 1024,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to parse meminfo: $e');
      }
    }
    return null;
  }

  /// vm_stat 파싱
  SystemMemoryInfo? _parseVmStat(String output) {
    try {
      final lines = output.split('\n');
      int pageSize = 4096; // 기본 페이지 크기
      int freePages = 0;
      int activePages = 0;
      int inactivePages = 0;
      int wiredPages = 0;

      for (final line in lines) {
        if (line.startsWith('Mach Virtual Memory Statistics')) {
          // 페이지 크기 추출
          final pageSizeMatch = RegExp(r'page size of (\d+) bytes').firstMatch(line);
          if (pageSizeMatch != null) {
            pageSize = int.tryParse(pageSizeMatch.group(1)!) ?? 4096;
          }
        } else if (line.startsWith('Pages free:')) {
          freePages = int.tryParse(line.split(':')[1].trim().split(' ')[0]) ?? 0;
        } else if (line.startsWith('Pages active:')) {
          activePages = int.tryParse(line.split(':')[1].trim().split(' ')[0]) ?? 0;
        } else if (line.startsWith('Pages inactive:')) {
          inactivePages = int.tryParse(line.split(':')[1].trim().split(' ')[0]) ?? 0;
        } else if (line.startsWith('Pages wired down:')) {
          wiredPages = int.tryParse(line.split(':')[1].trim().split(' ')[0]) ?? 0;
        }
      }

      final totalPages = freePages + activePages + inactivePages + wiredPages;
      final totalMemory = totalPages * pageSize;
      final usedMemory = (activePages + inactivePages + wiredPages) * pageSize;
      final availableMemory = freePages * pageSize;

      return SystemMemoryInfo(
        totalMemory: totalMemory,
        availableMemory: availableMemory,
        usedMemory: usedMemory,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to parse vm_stat: $e');
      }
    }
    return null;
  }

  /// 메모리 스냅샷 기록
  void _recordMemorySnapshot(MemoryInfo memoryInfo) {
    _memoryHistory.add(MemorySnapshot(memoryInfo: memoryInfo, timestamp: DateTime.now()));

    // 오래된 기록 정리
    if (_memoryHistory.length > _maxHistorySize) {
      _memoryHistory.removeAt(0);
    }
  }

  /// 메모리 최적화 수행
  Future<void> _performMemoryOptimization() async {
    try {
      final memoryInfo = await getCurrentMemoryInfo();
      final usageRatio = _calculateMemoryUsageRatio(memoryInfo);

      if (usageRatio >= _emergencyThreshold) {
        await _performEmergencyOptimization();
      } else if (usageRatio >= _criticalThreshold) {
        await _performCriticalOptimization();
      } else if (usageRatio >= _warningThreshold) {
        await _performWarningOptimization();
      }

      if (kDebugMode && usageRatio >= _warningThreshold) {
        debugPrint('🧠 Memory usage: ${(usageRatio * 100).toStringAsFixed(1)}%');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Memory optimization failed: $e');
      }
    }
  }

  /// 메모리 사용률 계산
  double _calculateMemoryUsageRatio(MemoryInfo memoryInfo) {
    if (memoryInfo.systemMemory == null) {
      // 시스템 메모리 정보가 없으면 프로세스 메모리만으로 추정
      return memoryInfo.processMemory / (1024 * 1024 * 1024); // 1GB 기준
    }

    final systemMem = memoryInfo.systemMemory!;
    return systemMem.usedMemory / systemMem.totalMemory;
  }

  /// 경고 수준 최적화
  Future<void> _performWarningOptimization() async {
    if (kDebugMode) {
      debugPrint('🧠 Performing warning-level memory optimization');
    }

    // 1. 오래된 메모리 스냅샷 정리
    _cleanupOldSnapshots();

    // 2. 가비지 컬렉션 힌트
    await _triggerGarbageCollection();
  }

  /// 위험 수준 최적화
  Future<void> _performCriticalOptimization() async {
    if (kDebugMode) {
      debugPrint('🧠 Performing critical-level memory optimization');
    }

    // 1. 경고 수준 최적화 실행
    await _performWarningOptimization();

    // 2. 이미지 캐시 정리
    await _clearImageCache();

    // 3. 불필요한 데이터 정리
    await _cleanupUnnecessaryData();
  }

  /// 비상 수준 최적화
  Future<void> _performEmergencyOptimization() async {
    if (kDebugMode) {
      debugPrint('🚨 Performing emergency-level memory optimization');
    }

    // 1. 위험 수준 최적화 실행
    await _performCriticalOptimization();

    // 2. 모든 캐시 정리
    await _clearAllCaches();

    // 3. 강제 가비지 컬렉션
    await _forceGarbageCollection();
  }

  /// 오래된 스냅샷 정리
  void _cleanupOldSnapshots() {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 1));
    _memoryHistory.removeWhere((snapshot) => snapshot.timestamp.isBefore(cutoffTime));
  }

  /// 가비지 컬렉션 트리거
  Future<void> _triggerGarbageCollection() async {
    try {
      // Flutter의 가비지 컬렉션 힌트
      await SystemChannels.platform.invokeMethod('System.gc');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to trigger garbage collection: $e');
      }
    }
  }

  /// 이미지 캐시 정리
  Future<void> _clearImageCache() async {
    try {
      // Flutter의 이미지 캐시 정리
      await SystemChannels.platform.invokeMethod('System.clearImageCache');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear image cache: $e');
      }
    }
  }

  /// 불필요한 데이터 정리
  Future<void> _cleanupUnnecessaryData() async {
    // 앱별 데이터 정리 로직
    // 예: 임시 파일, 로그 파일, 오래된 캐시 등
  }

  /// 모든 캐시 정리
  Future<void> _clearAllCaches() async {
    try {
      await _clearImageCache();
      // 추가 캐시 정리 로직
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear all caches: $e');
      }
    }
  }

  /// 강제 가비지 컬렉션
  Future<void> _forceGarbageCollection() async {
    try {
      // 여러 번 가비지 컬렉션 실행
      for (int i = 0; i < 3; i++) {
        await _triggerGarbageCollection();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to force garbage collection: $e');
      }
    }
  }

  /// 메모리 통계 생성
  MemoryStats generateStats() {
    if (_memoryHistory.isEmpty) {
      return MemoryStats.empty();
    }

    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));

    // 최근 1시간 데이터 필터링
    final recentSnapshots = _memoryHistory
        .where((snapshot) => snapshot.timestamp.isAfter(lastHour))
        .toList();

    if (recentSnapshots.isEmpty) {
      return MemoryStats.empty();
    }

    // 통계 계산
    final memoryValues = recentSnapshots
        .map((snapshot) => snapshot.memoryInfo.processMemory)
        .toList();

    final averageMemory = memoryValues.reduce((a, b) => a + b) / memoryValues.length;
    final maxMemory = memoryValues.reduce((a, b) => a > b ? a : b);
    final minMemory = memoryValues.reduce((a, b) => a < b ? a : b);

    return MemoryStats(
      averageMemory: averageMemory,
      maxMemory: maxMemory,
      minMemory: minMemory,
      totalSnapshots: recentSnapshots.length,
      memoryTrend: _calculateMemoryTrend(recentSnapshots),
    );
  }

  /// 메모리 트렌드 계산
  MemoryTrend _calculateMemoryTrend(List<MemorySnapshot> snapshots) {
    if (snapshots.length < 2) return MemoryTrend.stable;

    final firstMemory = snapshots.first.memoryInfo.processMemory;
    final lastMemory = snapshots.last.memoryInfo.processMemory;
    final difference = lastMemory - firstMemory;
    final percentageChange = (difference / firstMemory) * 100;

    if (percentageChange > 10) return MemoryTrend.increasing;
    if (percentageChange < -10) return MemoryTrend.decreasing;
    return MemoryTrend.stable;
  }

  /// 메모리 리포트 출력
  void printMemoryReport() {
    if (!kDebugMode) return;

    final stats = generateStats();
    debugPrint('=== Memory Report ===');
    debugPrint('Average Memory: ${(stats.averageMemory / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint('Max Memory: ${(stats.maxMemory / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint('Min Memory: ${(stats.minMemory / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint('Total Snapshots: ${stats.totalSnapshots}');
    debugPrint('Memory Trend: ${stats.memoryTrend.name}');
  }
}

/// 메모리 정보
class MemoryInfo {
  final int processMemory;
  final SystemMemoryInfo? systemMemory;
  final DateTime timestamp;

  const MemoryInfo({required this.processMemory, this.systemMemory, required this.timestamp});

  factory MemoryInfo.unknown() => MemoryInfo(processMemory: 0, timestamp: DateTime.now());
}

/// 시스템 메모리 정보
class SystemMemoryInfo {
  final int totalMemory;
  final int availableMemory;
  final int usedMemory;

  const SystemMemoryInfo({
    required this.totalMemory,
    required this.availableMemory,
    required this.usedMemory,
  });
}

/// 메모리 스냅샷
class MemorySnapshot {
  final MemoryInfo memoryInfo;
  final DateTime timestamp;

  const MemorySnapshot({required this.memoryInfo, required this.timestamp});
}

/// 메모리 통계
class MemoryStats {
  final double averageMemory;
  final int maxMemory;
  final int minMemory;
  final int totalSnapshots;
  final MemoryTrend memoryTrend;

  const MemoryStats({
    required this.averageMemory,
    required this.maxMemory,
    required this.minMemory,
    required this.totalSnapshots,
    required this.memoryTrend,
  });

  factory MemoryStats.empty() => const MemoryStats(
    averageMemory: 0,
    maxMemory: 0,
    minMemory: 0,
    totalSnapshots: 0,
    memoryTrend: MemoryTrend.stable,
  );
}

/// 메모리 트렌드
enum MemoryTrend { increasing, decreasing, stable }
