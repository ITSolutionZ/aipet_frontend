import 'dart:math';

import 'package:flutter/foundation.dart';

import 'mock_config.dart';

/// 목업 데이터 시나리오 타입
enum MockScenario {
  /// 성공 시나리오 - 정상적인 데이터 반환
  success,

  /// 에러 시나리오 - 서버 에러 시뮬레이션
  error,

  /// 지연 시나리오 - 네트워크 지연 시뮬레이션
  delay,

  /// 부분 성공 시나리오 - 일부 데이터만 로드
  partialSuccess,

  /// 빈 데이터 시나리오 - 데이터 없음
  empty,

  /// 로딩 시나리오 - 무한 로딩
  loading,
}

/// 중앙집중형 목업 데이터 관리자
///
/// 모든 Mock 데이터를 중앙에서 관리하고,
/// 시나리오별 테스트와 실제 API 연동을 지원합니다.
class CentralizedMockManager {
  static final CentralizedMockManager _instance =
      CentralizedMockManager._internal();
  factory CentralizedMockManager() => _instance;
  CentralizedMockManager._internal();

  // Mock 데이터 저장소
  final Map<String, dynamic> _dataStore = {};
  final Map<String, MockScenario> _scenarioOverrides = {};
  final Map<String, int> _callCounts = {};
  final Random _random = Random();

  /// Mock 데이터 초기화
  static Future<void> initialize() async {
    if (!MockConfig.shouldUseMock) return;

    final instance = CentralizedMockManager();
    await instance._loadMockData();

    if (MockConfig.enableMockLogging) {
      debugPrint('🎭 CentralizedMockManager initialized');
      debugPrint('📊 Environment: ${MockConfig.currentEnvironment.name}');
      debugPrint('🔧 Config: ${MockConfig.debugInfo}');
    }
  }

  /// Mock 데이터 로드
  Future<void> _loadMockData() async {
    // 여기서 모든 Mock 데이터를 중앙에서 로드
    // 실제로는 각 feature의 mock 데이터를 통합
    await _loadPetMockData();
    await _loadAiMockData();
    await _loadWalkMockData();
    await _loadSchedulingMockData();
  }

  /// Pet 관련 Mock 데이터 로드
  Future<void> _loadPetMockData() async {
    _dataStore['pets'] = [
      {
        'id': 'pet_001',
        'name': '몽이',
        'type': 'dog',
        'breed': '골든 리트리버',
        'age': 3,
        'weight': 25.5,
        'imageUrl': 'https://example.com/pet1.jpg',
        'birthDate': '2021-03-15',
        'isActive': true,
      },
      {
        'id': 'pet_002',
        'name': '나비',
        'type': 'cat',
        'breed': '페르시안',
        'age': 2,
        'weight': 4.2,
        'imageUrl': 'https://example.com/pet2.jpg',
        'birthDate': '2022-06-20',
        'isActive': true,
      },
    ];

    _dataStore['pet_activities'] = [
      {
        'id': 'activity_001',
        'petId': 'pet_001',
        'type': 'walk',
        'duration': 3600,
        'distance': 2.5,
        'date': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
    ];
  }

  /// AI 관련 Mock 데이터 로드
  Future<void> _loadAiMockData() async {
    _dataStore['ai_messages'] = [
      {
        'id': 'msg_001',
        'type': 'user',
        'content': '우리 강아지가 계속 기침을 해요',
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      },
      {
        'id': 'msg_002',
        'type': 'assistant',
        'content': '강아지의 기침은 여러 원인이 있을 수 있습니다. 지속적인 기침이라면 수의사 상담을 권합니다.',
        'timestamp': DateTime.now()
            .subtract(const Duration(minutes: 4))
            .toIso8601String(),
      },
    ];
  }

  /// Walk 관련 Mock 데이터 로드
  Future<void> _loadWalkMockData() async {
    _dataStore['walk_records'] = [
      {
        'id': 'walk_001',
        'petId': 'pet_001',
        'startTime': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
        'distance': 1.8,
        'route': [
          {'lat': 37.5665, 'lng': 126.9780},
          {'lat': 37.5675, 'lng': 126.9790},
        ],
      },
    ];
  }

  /// Scheduling 관련 Mock 데이터 로드
  Future<void> _loadSchedulingMockData() async {
    _dataStore['feeding_schedules'] = [
      {
        'id': 'schedule_001',
        'petId': 'pet_001',
        'time': '08:00',
        'amount': '200g',
        'foodType': '사료',
        'isActive': true,
      },
    ];
  }

  /// Mock 데이터 조회
  static Future<T> getMockData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    T? fallback,
    MockScenario? forceScenario,
  }) async {
    if (!MockConfig.shouldUseMock) {
      throw Exception('Mock 데이터가 비활성화되었습니다');
    }

    final instance = CentralizedMockManager();
    return instance._getMockDataInternal<T>(
      key: key,
      fromJson: fromJson,
      fallback: fallback,
      forceScenario: forceScenario,
    );
  }

  /// Mock 데이터 목록 조회
  static Future<List<T>> getMockDataList<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    List<T>? fallback,
    MockScenario? forceScenario,
  }) async {
    if (!MockConfig.shouldUseMock) {
      throw Exception('Mock 데이터가 비활성화되었습니다');
    }

    final instance = CentralizedMockManager();
    return instance._getMockDataListInternal<T>(
      key: key,
      fromJson: fromJson,
      fallback: fallback ?? [],
      forceScenario: forceScenario,
    );
  }

  /// 내부 Mock 데이터 조회 구현
  Future<T> _getMockDataInternal<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    T? fallback,
    MockScenario? forceScenario,
  }) async {
    _incrementCallCount(key);

    final scenario = _determineScenario(key, forceScenario);
    await _simulateScenario(scenario, key);

    switch (scenario) {
      case MockScenario.success:
        final data = _dataStore[key];
        if (data != null) {
          return fromJson(data as Map<String, dynamic>);
        }
        break;
      case MockScenario.error:
        throw Exception('Mock 에러: $key 데이터 로드 실패');
      case MockScenario.loading:
        // 무한 대기 (실제로는 타임아웃 설정 권장)
        await Future.delayed(const Duration(seconds: 30));
        break;
      case MockScenario.empty:
        if (fallback != null) return fallback;
        break;
      case MockScenario.partialSuccess:
      case MockScenario.delay:
        final data = _dataStore[key];
        if (data != null) {
          return fromJson(data as Map<String, dynamic>);
        }
        break;
    }

    if (fallback != null) return fallback;
    throw Exception('Mock 데이터를 찾을 수 없습니다: $key');
  }

  /// 내부 Mock 데이터 목록 조회 구현
  Future<List<T>> _getMockDataListInternal<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    required List<T> fallback,
    MockScenario? forceScenario,
  }) async {
    _incrementCallCount(key);

    final scenario = _determineScenario(key, forceScenario);
    await _simulateScenario(scenario, key);

    switch (scenario) {
      case MockScenario.success:
        final dataList = _dataStore[key] as List?;
        if (dataList != null) {
          return dataList
              .cast<Map<String, dynamic>>()
              .map((data) => fromJson(data))
              .toList();
        }
        break;
      case MockScenario.error:
        throw Exception('Mock 에러: $key 데이터 목록 로드 실패');
      case MockScenario.loading:
        await Future.delayed(const Duration(seconds: 30));
        break;
      case MockScenario.empty:
        return [];
      case MockScenario.partialSuccess:
        final dataList = _dataStore[key] as List?;
        if (dataList != null && dataList.isNotEmpty) {
          // 부분적으로만 반환 (50% 확률로 절반만)
          final halfSize = (dataList.length / 2).ceil();
          return dataList
              .take(halfSize)
              .cast<Map<String, dynamic>>()
              .map((data) => fromJson(data))
              .toList();
        }
        break;
      case MockScenario.delay:
        final dataList = _dataStore[key] as List?;
        if (dataList != null) {
          return dataList
              .cast<Map<String, dynamic>>()
              .map((data) => fromJson(data))
              .toList();
        }
        break;
    }

    return fallback;
  }

  /// 시나리오 결정
  MockScenario _determineScenario(String key, MockScenario? forceScenario) {
    if (forceScenario != null) return forceScenario;
    if (_scenarioOverrides.containsKey(key)) return _scenarioOverrides[key]!;

    if (!MockConfig.shouldSimulateErrors) return MockScenario.success;

    // 확률 기반 시나리오 선택
    final probability = _random.nextDouble();
    if (probability < 0.8) return MockScenario.success;
    if (probability < 0.9) return MockScenario.delay;
    if (probability < 0.95) return MockScenario.partialSuccess;
    return MockScenario.error;
  }

  /// 시나리오별 동작 시뮬레이션
  Future<void> _simulateScenario(MockScenario scenario, String key) async {
    if (!MockConfig.shouldSimulateNetworkDelay &&
        scenario != MockScenario.error &&
        scenario != MockScenario.loading) {
      return;
    }

    switch (scenario) {
      case MockScenario.success:
        await Future.delayed(
          Duration(milliseconds: 200 + _random.nextInt(300)),
        );
        break;
      case MockScenario.delay:
        await Future.delayed(
          Duration(milliseconds: 1000 + _random.nextInt(2000)),
        );
        break;
      case MockScenario.partialSuccess:
        await Future.delayed(
          Duration(milliseconds: 500 + _random.nextInt(500)),
        );
        break;
      case MockScenario.error:
        await Future.delayed(
          Duration(milliseconds: 100 + _random.nextInt(200)),
        );
        break;
      case MockScenario.empty:
        await Future.delayed(
          Duration(milliseconds: 100 + _random.nextInt(100)),
        );
        break;
      case MockScenario.loading:
        // 로딩 시나리오는 호출하는 곳에서 처리
        break;
    }

    if (MockConfig.enableMockLogging) {
      debugPrint('🎭 Mock [$key]: ${scenario.name}');
    }
  }

  /// 호출 횟수 증가
  void _incrementCallCount(String key) {
    _callCounts[key] = (_callCounts[key] ?? 0) + 1;
  }

  /// 특정 키에 대한 시나리오 강제 설정
  static void setScenarioOverride(String key, MockScenario scenario) {
    CentralizedMockManager()._scenarioOverrides[key] = scenario;
  }

  /// 시나리오 오버라이드 제거
  static void clearScenarioOverride(String key) {
    CentralizedMockManager()._scenarioOverrides.remove(key);
  }

  /// 모든 시나리오 오버라이드 제거
  static void clearAllScenarioOverrides() {
    CentralizedMockManager()._scenarioOverrides.clear();
  }

  /// Mock 데이터 통계
  static Map<String, dynamic> getStatistics() {
    final instance = CentralizedMockManager();
    return {
      'totalCalls': instance._callCounts.values.fold<int>(
        0,
        (sum, count) => sum + count,
      ),
      'callsByKey': Map.from(instance._callCounts),
      'activeOverrides': Map.from(instance._scenarioOverrides),
      'dataKeys': instance._dataStore.keys.toList(),
    };
  }

  /// Mock 데이터 초기화 (테스트용)
  static void reset() {
    final instance = CentralizedMockManager();
    instance._dataStore.clear();
    instance._scenarioOverrides.clear();
    instance._callCounts.clear();
  }

  /// Custom Mock 데이터 추가 (테스트용)
  static void addMockData(String key, dynamic data) {
    CentralizedMockManager()._dataStore[key] = data;
  }

  /// Mock 상태 확인
  static bool get isInitialized =>
      CentralizedMockManager()._dataStore.isNotEmpty;
}
