import 'dart:async';

import 'package:flutter/foundation.dart';

/// 사용자 경험 개선 서비스
class UserExperienceService {
  static final UserExperienceService _instance =
      UserExperienceService._internal();
  factory UserExperienceService() => _instance;
  UserExperienceService._internal();

  // 로딩 상태 관리
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  Stream<bool> get loadingStream => _loadingController.stream;

  // 사용자 피드백 관리
  final StreamController<String> _feedbackController =
      StreamController<String>.broadcast();

  Stream<String> get feedbackStream => _feedbackController.stream;

  // 앱 사용 통계
  final Map<String, int> _screenVisitCount = {};
  final Map<String, Duration> _screenTimeSpent = {};
  final List<String> _userActions = [];
  static const int _maxActionsHistory = 1000;

  // 성능 메트릭
  final List<double> _pageLoadTimes = [];
  final List<double> _interactionResponseTimes = [];

  // 사용자 설정
  // Analytics enabled flag - reserved for future analytics functionality
  // ignore: unused_field
  bool _isAnalyticsEnabled = true;
  bool _isPerformanceTrackingEnabled = true;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (kDebugMode) {
      print('사용자 경험 서비스 초기화 시작');
    }

    try {
      // 기본 설정 로드
      await _loadUserPreferences();

      // 성능 모니터링 시작
      if (_isPerformanceTrackingEnabled) {
        _startPerformanceMonitoring();
      }

      if (kDebugMode) {
        print('사용자 경험 서비스 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('사용자 경험 서비스 초기화 실패: $e');
      }
    }
  }

  /// 사용자 설정 로드
  Future<void> _loadUserPreferences() async {
    // SharedPreferences에서 사용자 설정 로드
    // 실제 구현에서는 SecureStorageService 사용
  }

  /// 성능 모니터링 시작
  void _startPerformanceMonitoring() {
    // 페이지 로드 시간, 인터랙션 응답 시간 모니터링
    if (kDebugMode) {
      print('성능 모니터링 시작');
    }
  }

  /// 로딩 상태 표시
  void showLoading() {
    _loadingController.add(true);
  }

  /// 로딩 상태 숨기기
  void hideLoading() {
    _loadingController.add(false);
  }

  /// 사용자 피드백 표시
  void showFeedback(String message, {Duration? duration}) {
    _feedbackController.add(message);

    // 자동 숨김
    if (duration != null) {
      Timer(duration, () {
        _feedbackController.add('');
      });
    }
  }

  /// 성공 메시지 표시
  void showSuccess(String message) {
    showFeedback('✅ $message', duration: const Duration(seconds: 3));
  }

  /// 경고 메시지 표시
  void showWarning(String message) {
    showFeedback('⚠️ $message', duration: const Duration(seconds: 4));
  }

  /// 에러 메시지 표시
  void showError(String message) {
    showFeedback('❌ $message', duration: const Duration(seconds: 5));
  }

  /// 정보 메시지 표시
  void showInfo(String message) {
    showFeedback('ℹ️ $message', duration: const Duration(seconds: 3));
  }

  /// 화면 방문 기록
  void recordScreenVisit(String screenName) {
    _screenVisitCount[screenName] = (_screenVisitCount[screenName] ?? 0) + 1;

    if (kDebugMode) {
      print('화면 방문: $screenName (총 ${_screenVisitCount[screenName]}회)');
    }
  }

  /// 화면 체류 시간 기록
  void recordScreenTime(String screenName, Duration timeSpent) {
    _screenTimeSpent[screenName] =
        (_screenTimeSpent[screenName] ?? Duration.zero) + timeSpent;

    if (kDebugMode) {
      print('화면 체류 시간: $screenName (${timeSpent.inSeconds}초)');
    }
  }

  /// 사용자 액션 기록
  void recordUserAction(String action, {Map<String, dynamic>? context}) {
    final actionData = {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
    };

    _userActions.add(actionData.toString());

    // 액션 히스토리 크기 제한
    if (_userActions.length > _maxActionsHistory) {
      _userActions.removeAt(0);
    }

    if (kDebugMode) {
      print('사용자 액션: $action');
    }
  }

  /// 페이지 로드 시간 기록
  void recordPageLoadTime(String pageName, double loadTime) {
    _pageLoadTimes.add(loadTime);

    // 로드 시간 히스토리 크기 제한
    if (_pageLoadTimes.length > 100) {
      _pageLoadTimes.removeAt(0);
    }

    if (kDebugMode) {
      print('페이지 로드 시간: $pageName (${loadTime.toStringAsFixed(2)}ms)');
    }
  }

  /// 인터랙션 응답 시간 기록
  void recordInteractionResponseTime(String interaction, double responseTime) {
    _interactionResponseTimes.add(responseTime);

    // 응답 시간 히스토리 크기 제한
    if (_interactionResponseTimes.length > 100) {
      _interactionResponseTimes.removeAt(0);
    }

    if (kDebugMode) {
      print('인터랙션 응답 시간: $interaction (${responseTime.toStringAsFixed(2)}ms)');
    }
  }

  /// 사용자 경험 통계 가져오기
  Map<String, dynamic> getUserExperienceStats() {
    return {
      'screenVisits': Map<String, int>.from(_screenVisitCount),
      'screenTimeSpent': _screenTimeSpent.map(
        (key, value) => MapEntry(key, value.inSeconds),
      ),
      'totalActions': _userActions.length,
      'averagePageLoadTime': _calculateAverage(_pageLoadTimes),
      'averageResponseTime': _calculateAverage(_interactionResponseTimes),
      'mostVisitedScreen': _getMostVisitedScreen(),
      'longestScreenTime': _getLongestScreenTime(),
    };
  }

  /// 평균 계산
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// 가장 많이 방문한 화면
  String? _getMostVisitedScreen() {
    if (_screenVisitCount.isEmpty) return null;

    String? mostVisited;
    int maxVisits = 0;

    for (final entry in _screenVisitCount.entries) {
      if (entry.value > maxVisits) {
        maxVisits = entry.value;
        mostVisited = entry.key;
      }
    }

    return mostVisited;
  }

  /// 가장 오래 체류한 화면
  String? _getLongestScreenTime() {
    if (_screenTimeSpent.isEmpty) return null;

    String? longestScreen;
    Duration maxTime = Duration.zero;

    for (final entry in _screenTimeSpent.entries) {
      if (entry.value > maxTime) {
        maxTime = entry.value;
        longestScreen = entry.key;
      }
    }

    return longestScreen;
  }

    /// 사용자 행동 패턴 분석
  Map<String, dynamic> analyzeUserBehavior() {
    return {
      'preferredScreens': _getPreferredScreens(),
      'usagePatterns': _getUsagePatterns(),
      'performanceIssues': _getPerformanceIssues(),
      'userEngagement': _calculateUserEngagement(),
    };
  }

  /// 선호하는 화면들
  List<String> _getPreferredScreens() {
    final sortedScreens = _screenVisitCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedScreens.take(5).map((e) => e.key).toList();
  }

  /// 사용 패턴
  Map<String, dynamic> _getUsagePatterns() {
    return {
      'totalScreens': _screenVisitCount.length,
      'totalActions': _userActions.length,
      'averageActionsPerSession':
          _userActions.length / (_screenVisitCount.length + 1),
    };
  }

  /// 성능 이슈
  List<String> _getPerformanceIssues() {
    final issues = <String>[];

    final avgLoadTime = _calculateAverage(_pageLoadTimes);
    if (avgLoadTime > 2000) {
      // 2초 이상
      issues.add('페이지 로드 시간이 느림 (${avgLoadTime.toStringAsFixed(0)}ms)');
    }

    final avgResponseTime = _calculateAverage(_interactionResponseTimes);
    if (avgResponseTime > 500) {
      // 500ms 이상
      issues.add('인터랙션 응답 시간이 느림 (${avgResponseTime.toStringAsFixed(0)}ms)');
    }

    return issues;
  }

  /// 사용자 참여도 계산
  double _calculateUserEngagement() {
    if (_screenVisitCount.isEmpty) return 0.0;

    final totalVisits = _screenVisitCount.values.reduce((a, b) => a + b);
    final uniqueScreens = _screenVisitCount.length;
    final totalActions = _userActions.length;

    // 간단한 참여도 공식: (방문 횟수 + 액션 수) / 고유 화면 수
    return (totalVisits + totalActions) / uniqueScreens;
  }

  /// 사용자 경험 개선 제안
  List<String> getImprovementSuggestions() {
    final suggestions = <String>[];
    final behavior = analyzeUserBehavior();

    // 성능 관련 제안
    final performanceIssues = behavior['performanceIssues'] as List<String>;
    suggestions.addAll(performanceIssues);

    // 사용성 관련 제안
    final preferredScreens = behavior['preferredScreens'] as List<String>;
    if (preferredScreens.isNotEmpty) {
      suggestions.add('자주 사용하는 화면: ${preferredScreens.join(', ')}');
    }

    // 참여도 관련 제안
    final engagement = behavior['userEngagement'] as double;
    if (engagement < 10) {
      suggestions.add('사용자 참여도가 낮습니다. 기능 개선이 필요합니다.');
    }

    return suggestions;
  }

  /// 분석 활성화/비활성화
  void setAnalyticsEnabled(bool enabled) {
    _isAnalyticsEnabled = enabled;

    if (kDebugMode) {
      print('사용자 분석 ${enabled ? '활성화' : '비활성화'}');
    }
  }

  /// 성능 추적 활성화/비활성화
  void setPerformanceTrackingEnabled(bool enabled) {
    _isPerformanceTrackingEnabled = enabled;

    if (kDebugMode) {
      print('성능 추적 ${enabled ? '활성화' : '비활성화'}');
    }
  }

  /// 사용자 데이터 정리
  void clearUserData() {
    _screenVisitCount.clear();
    _screenTimeSpent.clear();
    _userActions.clear();
    _pageLoadTimes.clear();
    _interactionResponseTimes.clear();

    if (kDebugMode) {
      print('사용자 데이터 정리 완료');
    }
  }

  /// 서비스 정리
  void dispose() {
    _loadingController.close();
    _feedbackController.close();
    _screenVisitCount.clear();
    _screenTimeSpent.clear();
    _userActions.clear();
    _pageLoadTimes.clear();
    _interactionResponseTimes.clear();

    if (kDebugMode) {
      print('사용자 경험 서비스 정리 완료');
    }
  }
}
