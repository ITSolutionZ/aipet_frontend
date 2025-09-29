import 'dart:async';

import 'package:aipet_frontend/shared/performance/memory_optimizer.dart';
import 'package:aipet_frontend/shared/performance/performance_monitor.dart';
import 'package:aipet_frontend/shared/security/api_security_manager.dart';
import 'package:aipet_frontend/shared/security/environment_config.dart';
import 'package:flutter/foundation.dart';

/// 📊 앱 모니터링 대시보드
///
/// 실시간 앱 상태, 성능, 보안 정보를 종합적으로 모니터링합니다.
class AppMonitoringDashboard {
  static AppMonitoringDashboard? _instance;
  static AppMonitoringDashboard get instance =>
      _instance ??= AppMonitoringDashboard._();

  AppMonitoringDashboard._();

  Timer? _dashboardTimer;
  final List<DashboardSnapshot> _snapshots = [];

  // 모니터링 설정
  static const Duration _updateInterval = const Duration(seconds: 10);
  static const int _maxSnapshots = 100;

  /// 대시보드 시작
  void startMonitoring() {
    if (_dashboardTimer != null) return;

    _dashboardTimer = Timer.periodic(_updateInterval, (_) {
      _updateDashboard();
    });

    if (kDebugMode) {
      debugPrint('📊 App monitoring dashboard started');
    }
  }

  /// 대시보드 중지
  void stopMonitoring() {
    _dashboardTimer?.cancel();
    _dashboardTimer = null;

    if (kDebugMode) {
      debugPrint('📊 App monitoring dashboard stopped');
    }
  }

  /// 대시보드 업데이트
  Future<void> _updateDashboard() async {
    try {
      final snapshot = await _createDashboardSnapshot();
      _snapshots.add(snapshot);

      // 오래된 스냅샷 정리
      if (_snapshots.length > _maxSnapshots) {
        _snapshots.removeAt(0);
      }

      // 실시간 알림 체크
      await _checkAlerts(snapshot);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Dashboard update failed: $e');
      }
    }
  }

  /// 대시보드 스냅샷 생성
  Future<DashboardSnapshot> _createDashboardSnapshot() async {
    final timestamp = DateTime.now();

    // 성능 메트릭 수집
    final performanceReport = PerformanceMonitor.instance.generateReport();

    // 메모리 정보 수집
    final memoryInfo = await MemoryOptimizer.instance.getCurrentMemoryInfo();
    final memoryStats = MemoryOptimizer.instance.generateStats();

    // 보안 통계 수집
    final securityStats = ApiSecurityManager.instance.generateStats();
    final suspiciousActivities = ApiSecurityManager.instance
        .detectSuspiciousActivity();

    // 환경 정보 수집
    final environmentInfo = EnvironmentConfig.getEnvironmentInfo();

    return DashboardSnapshot(
      timestamp: timestamp,
      performance: performanceReport,
      memory: memoryInfo,
      memoryStats: memoryStats,
      security: securityStats,
      suspiciousActivities: suspiciousActivities,
      environment: environmentInfo,
      systemHealth: _calculateSystemHealth(
        performanceReport,
        memoryInfo,
        securityStats,
        suspiciousActivities,
      ),
    );
  }

  /// 시스템 건강도 계산
  SystemHealth _calculateSystemHealth(
    PerformanceReport performance,
    MemoryInfo memory,
    ApiSecurityStats security,
    List<SuspiciousActivity> suspiciousActivities,
  ) {
    int healthScore = 100;
    final issues = <String>[];

    // 성능 이슈 체크
    if (performance.avgApiResponseTime > 2000) {
      healthScore -= 20;
      issues.add(
        'Slow API response time: ${performance.avgApiResponseTime.toStringAsFixed(0)}ms',
      );
    }

    if (performance.avgWidgetBuildTime > 100) {
      healthScore -= 15;
      issues.add(
        'Slow widget build time: ${performance.avgWidgetBuildTime.toStringAsFixed(0)}ms',
      );
    }

    if (performance.slowOperations.isNotEmpty) {
      healthScore -= 10;
      issues.add(
        '${performance.slowOperations.length} slow operations detected',
      );
    }

    // 메모리 이슈 체크
    if (memory.systemMemory != null) {
      final memoryUsage =
          memory.systemMemory!.usedMemory / memory.systemMemory!.totalMemory;
      if (memoryUsage > 0.8) {
        healthScore -= 25;
        issues.add(
          'High memory usage: ${(memoryUsage * 100).toStringAsFixed(1)}%',
        );
      }
    }

    if (performance.memoryAlerts.isNotEmpty) {
      healthScore -= 15;
      issues.add('${performance.memoryAlerts.length} memory alerts');
    }

    // 보안 이슈 체크
    if (suspiciousActivities.isNotEmpty) {
      healthScore -= 20;
      issues.add(
        '${suspiciousActivities.length} suspicious activities detected',
      );
    }

    if (security.activeRequests > 50) {
      healthScore -= 10;
      issues.add('High concurrent requests: ${security.activeRequests}');
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

    return SystemHealth(score: healthScore, level: level, issues: issues);
  }

  /// 알림 체크
  Future<void> _checkAlerts(DashboardSnapshot snapshot) async {
    // 시스템 건강도 알림
    if (snapshot.systemHealth.level == SystemHealthLevel.critical) {
      await _sendAlert('🚨 Critical system health detected', snapshot);
    } else if (snapshot.systemHealth.level == SystemHealthLevel.warning) {
      await _sendAlert('⚠️ System health warning', snapshot);
    }

    // 메모리 알림
    if (snapshot.performance.memoryAlerts.isNotEmpty) {
      await _sendAlert('🧠 Memory alerts detected', snapshot);
    }

    // 보안 알림
    if (snapshot.suspiciousActivities.isNotEmpty) {
      await _sendAlert('🛡️ Suspicious activities detected', snapshot);
    }

    // 성능 알림
    if (snapshot.performance.slowOperations.isNotEmpty) {
      await _sendAlert('🐌 Slow operations detected', snapshot);
    }
  }

  /// 알림 전송
  Future<void> _sendAlert(String message, DashboardSnapshot snapshot) async {
    if (kDebugMode) {
      debugPrint('🚨 ALERT: $message');
      debugPrint(
        'System Health: ${snapshot.systemHealth.score}/100 (${snapshot.systemHealth.level.name})',
      );
      if (snapshot.systemHealth.issues.isNotEmpty) {
        debugPrint('Issues: ${snapshot.systemHealth.issues.join(', ')}');
      }
    }

    // 실제 환경에서는 Slack, Discord, 이메일 등으로 알림 전송
    // await _sendSlackNotification(message, snapshot);
    // await _sendEmailNotification(message, snapshot);
  }

  /// 현재 대시보드 상태 가져오기
  DashboardSnapshot? get currentSnapshot {
    if (_snapshots.isEmpty) return null;
    return _snapshots.last;
  }

  /// 대시보드 통계 생성
  DashboardStats generateStats() {
    if (_snapshots.isEmpty) {
      return DashboardStats.empty();
    }

    final now = DateTime.now();
    final lastHour = now.subtract(Duration(hours: 1));

    // 최근 1시간 데이터 필터링
    final recentSnapshots = _snapshots
        .where((snapshot) => snapshot.timestamp.isAfter(lastHour))
        .toList();

    if (recentSnapshots.isEmpty) {
      return DashboardStats.empty();
    }

    // 통계 계산
    final healthScores = recentSnapshots
        .map((snapshot) => snapshot.systemHealth.score)
        .toList();

    final avgHealthScore =
        healthScores.reduce((a, b) => a + b) / healthScores.length;
    final minHealthScore = healthScores.reduce((a, b) => a < b ? a : b);
    final maxHealthScore = healthScores.reduce((a, b) => a > b ? a : b);

    final totalAlerts = recentSnapshots
        .map((snapshot) => snapshot.systemHealth.issues.length)
        .reduce((a, b) => a + b);

    final totalSuspiciousActivities = recentSnapshots
        .map((snapshot) => snapshot.suspiciousActivities.length)
        .reduce((a, b) => a + b);

    return DashboardStats(
      totalSnapshots: recentSnapshots.length,
      avgHealthScore: avgHealthScore,
      minHealthScore: minHealthScore,
      maxHealthScore: maxHealthScore,
      totalAlerts: totalAlerts,
      totalSuspiciousActivities: totalSuspiciousActivities,
      uptime: _calculateUptime(recentSnapshots),
    );
  }

  /// 업타임 계산
  Duration _calculateUptime(List<DashboardSnapshot> snapshots) {
    if (snapshots.length < 2) return Duration.zero;

    final firstSnapshot = snapshots.first;
    final lastSnapshot = snapshots.last;

    return lastSnapshot.timestamp.difference(firstSnapshot.timestamp);
  }

  /// 대시보드 리포트 출력
  void printDashboardReport() {
    if (!kDebugMode) return;

    final current = currentSnapshot;
    if (current == null) {
      debugPrint('📊 No dashboard data available');
      return;
    }

    final stats = generateStats();

    debugPrint('=== App Monitoring Dashboard ===');
    debugPrint('Timestamp: ${current.timestamp.toIso8601String()}');
    debugPrint(
      'System Health: ${current.systemHealth.score}/100 (${current.systemHealth.level.name})',
    );
    debugPrint('Environment: ${current.environment['environment']}');
    debugPrint('Active Requests: ${current.security.activeRequests}');
    debugPrint(
      'Memory Usage: ${(current.memory.processMemory / 1024 / 1024).toStringAsFixed(2)} MB',
    );
    debugPrint('Suspicious Activities: ${current.suspiciousActivities.length}');
    debugPrint('Slow Operations: ${current.performance.slowOperations.length}');
    debugPrint('Memory Alerts: ${current.performance.memoryAlerts.length}');

    if (current.systemHealth.issues.isNotEmpty) {
      debugPrint('\nIssues:');
      for (final issue in current.systemHealth.issues) {
        debugPrint('  - $issue');
      }
    }

    debugPrint('\n=== Statistics (Last Hour) ===');
    debugPrint('Total Snapshots: ${stats.totalSnapshots}');
    debugPrint('Avg Health Score: ${stats.avgHealthScore.toStringAsFixed(1)}');
    debugPrint('Min Health Score: ${stats.minHealthScore}');
    debugPrint('Max Health Score: ${stats.maxHealthScore}');
    debugPrint('Total Alerts: ${stats.totalAlerts}');
    debugPrint('Total Suspicious Activities: ${stats.totalSuspiciousActivities}');
    debugPrint('Uptime: ${stats.uptime.inMinutes} minutes');
  }

  /// JSON 형태로 대시보드 데이터 내보내기
  Map<String, dynamic> exportDashboardData() {
    final current = currentSnapshot;
    if (current == null) return {};

    return {
      'timestamp': current.timestamp.toIso8601String(),
      'systemHealth': {
        'score': current.systemHealth.score,
        'level': current.systemHealth.level.name,
        'issues': current.systemHealth.issues,
      },
      'performance': {
        'avgApiResponseTime': current.performance.avgApiResponseTime,
        'avgMemoryUsage': current.performance.avgMemoryUsage,
        'avgWidgetBuildTime': current.performance.avgWidgetBuildTime,
        'slowOperations': current.performance.slowOperations.length,
        'memoryAlerts': current.performance.memoryAlerts.length,
      },
      'security': {
        'totalRequests': current.security.totalRequests,
        'uniqueClients': current.security.uniqueClients,
        'activeRequests': current.security.activeRequests,
        'suspiciousActivities': current.suspiciousActivities.length,
      },
      'environment': current.environment,
    };
  }
}

/// 대시보드 스냅샷
class DashboardSnapshot {
  final DateTime timestamp;
  final PerformanceReport performance;
  final MemoryInfo memory;
  final MemoryStats memoryStats;
  final ApiSecurityStats security;
  final List<SuspiciousActivity> suspiciousActivities;
  final Map<String, dynamic> environment;
  final SystemHealth systemHealth;

  const DashboardSnapshot({
    required this.timestamp,
    required this.performance,
    required this.memory,
    required this.memoryStats,
    required this.security,
    required this.suspiciousActivities,
    required this.environment,
    required this.systemHealth,
  });
}

/// 시스템 건강도
class SystemHealth {
  final int score;
  final SystemHealthLevel level;
  final List<String> issues;

  const SystemHealth({
    required this.score,
    required this.level,
    required this.issues,
  });
}

/// 시스템 건강도 등급
enum SystemHealthLevel { excellent, good, warning, critical }

/// 대시보드 통계
class DashboardStats {
  final int totalSnapshots;
  final double avgHealthScore;
  final int minHealthScore;
  final int maxHealthScore;
  final int totalAlerts;
  final int totalSuspiciousActivities;
  final Duration uptime;

  const DashboardStats({
    required this.totalSnapshots,
    required this.avgHealthScore,
    required this.minHealthScore,
    required this.maxHealthScore,
    required this.totalAlerts,
    required this.totalSuspiciousActivities,
    required this.uptime,
  });

  factory DashboardStats.empty() => const DashboardStats(
    totalSnapshots: 0,
    avgHealthScore: 0,
    minHealthScore: 0,
    maxHealthScore: 0,
    totalAlerts: 0,
    totalSuspiciousActivities: 0,
    uptime: Duration.zero,
  );
}
