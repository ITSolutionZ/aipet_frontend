/// 🎯 고급 테스트 유틸리티
///
/// 자동화된 테스트 작성을 위한 고급 유틸리티와 헬퍼 함수들을 제공합니다.
/// Mock 데이터 생성, 테스트 케이스 자동화, 성능 테스트 등을 지원합니다.
library;

import 'dart:async';
import 'dart:math' as math;

/// 테스트 데이터 생성기
class TestDataGenerator {
  static final math.Random _random = math.Random();

  /// 랜덤 문자열 생성
  static String randomString({
    int length = 10,
    bool includeNumbers = true,
    bool includeSpecialChars = false,
  }) {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = letters;
    if (includeNumbers) chars += numbers;
    if (includeSpecialChars) chars += special;

    return List.generate(
      length,
      (index) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// 랜덤 이메일 생성
  static String randomEmail() {
    final username = randomString(length: 8);
    final domain = randomString(length: 6);
    final tld = ['com', 'org', 'net', 'jp'][_random.nextInt(4)];
    return '$username@$domain.$tld';
  }

  /// 랜덤 전화번호 생성
  static String randomPhoneNumber() {
    final areaCode = _random.nextInt(900) + 100;
    final exchange = _random.nextInt(900) + 100;
    final number = _random.nextInt(9000) + 1000;
    return '+1-$areaCode-$exchange-$number';
  }

  /// 랜덤 날짜 생성
  static DateTime randomDate({DateTime? start, DateTime? end}) {
    final startDate = start ?? DateTime(2020, 1, 1);
    final endDate = end ?? DateTime.now();
    final duration = endDate.difference(startDate);
    final randomDays = _random.nextInt(duration.inDays);
    return startDate.add(Duration(days: randomDays));
  }

  /// 랜덤 ID 생성
  static String randomId({String prefix = 'id'}) {
    return '$prefix${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(1000)}';
  }

  /// 랜덤 리스트 생성
  static List<T> randomList<T>(
    T Function() generator, {
    int minLength = 1,
    int maxLength = 10,
  }) {
    final length = _random.nextInt(maxLength - minLength + 1) + minLength;
    return List.generate(length, (index) => generator());
  }

  /// 랜덤 맵 생성
  static Map<String, dynamic> randomMap({int minKeys = 1, int maxKeys = 5}) {
    final keyCount = _random.nextInt(maxKeys - minKeys + 1) + minKeys;
    final map = <String, dynamic>{};

    for (int i = 0; i < keyCount; i++) {
      final key = randomString(length: 6);
      final value = _random.nextBool() ? randomString() : _random.nextInt(1000);
      map[key] = value;
    }

    return map;
  }
}

/// 테스트 케이스 자동화기
class TestCaseAutomator {
  /// 여러 입력값으로 테스트 실행
  static Future<List<TestResult>> runParameterizedTests<T, R>(
    Future<R> Function(T input) testFunction,
    List<T> inputs,
  ) async {
    final results = <TestResult>[];

    for (int i = 0; i < inputs.length; i++) {
      final input = inputs[i];
      final stopwatch = Stopwatch()..start();

      try {
        final result = await testFunction(input);
        stopwatch.stop();

        results.add(
          TestResult.success(
            input: input,
            result: result,
            duration: stopwatch.elapsed,
          ),
        );
      } catch (e) {
        stopwatch.stop();

        results.add(
          TestFailure(
            input: input,
            error: e.toString(),
            duration: stopwatch.elapsed,
          ),
        );
      }
    }

    return results;
  }

  /// 성능 테스트 실행
  static Future<PerformanceTestResult> runPerformanceTest<T>(
    Future<T> Function() testFunction, {
    int iterations = 100,
    Duration? maxDuration,
  }) async {
    final durations = <Duration>[];
    final errors = <String>[];
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      final iterationStopwatch = Stopwatch()..start();

      try {
        await testFunction();
        iterationStopwatch.stop();
        durations.add(iterationStopwatch.elapsed);

        if (maxDuration != null && stopwatch.elapsed > maxDuration) {
          break;
        }
      } catch (e) {
        iterationStopwatch.stop();
        errors.add(e.toString());
      }
    }

    stopwatch.stop();

    return PerformanceTestResult(
      totalDuration: stopwatch.elapsed,
      iterations: durations.length,
      averageDuration: Duration(
        microseconds:
            durations.map((d) => d.inMicroseconds).reduce((a, b) => a + b) ~/
            durations.length,
      ),
      minDuration: durations.reduce((a, b) => a < b ? a : b),
      maxDuration: durations.reduce((a, b) => a > b ? a : b),
      errorCount: errors.length,
      errors: errors,
    );
  }

  /// 스트레스 테스트 실행
  static Future<StressTestResult> runStressTest<T>(
    Future<T> Function() testFunction, {
    int concurrentTasks = 10,
    Duration duration = const Duration(seconds: 30),
  }) async {
    final completer = Completer<StressTestResult>();
    final results = <TestResult>[];
    final stopwatch = Stopwatch()..start();

    // 동시 실행 태스크들
    final tasks = <Future<void>>[];
    for (int i = 0; i < concurrentTasks; i++) {
      tasks.add(_runStressTask(testFunction, results, stopwatch, duration));
    }

    // 타이머 설정
    Timer(duration, () {
      stopwatch.stop();
      if (!completer.isCompleted) {
        completer.complete(
          StressTestResult(
            totalDuration: stopwatch.elapsed,
            totalTasks: results.length,
            successfulTasks: results.where((r) => r.isSuccess).length,
            failedTasks: results.where((r) => !r.isSuccess).length,
            averageDuration: _calculateAverageDuration(results),
            results: results,
          ),
        );
      }
    });

    return completer.future;
  }

  static Future<void> _runStressTask<T>(
    Future<T> Function() testFunction,
    List<TestResult> results,
    Stopwatch stopwatch,
    Duration maxDuration,
  ) async {
    while (stopwatch.isRunning && stopwatch.elapsed < maxDuration) {
      final iterationStopwatch = Stopwatch()..start();

      try {
        await testFunction();
        iterationStopwatch.stop();

        results.add(
          TestResult.success(
            input: null,
            result: null,
            duration: iterationStopwatch.elapsed,
          ),
        );
      } catch (e) {
        iterationStopwatch.stop();

        results.add(
          TestFailure(
            input: null,
            error: e.toString(),
            duration: iterationStopwatch.elapsed,
          ),
        );
      }
    }
  }

  static Duration _calculateAverageDuration(List<TestResult> results) {
    if (results.isEmpty) return Duration.zero;

    final totalMicroseconds = results
        .map((r) => r.duration.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ results.length);
  }
}

/// 테스트 결과 클래스들
class TestResult {
  final dynamic input;
  final dynamic result;
  final String? error;
  final Duration duration;
  final bool isSuccess;

  TestResult._({
    required this.input,
    required this.result,
    required this.error,
    required this.duration,
    required this.isSuccess,
  });

  factory TestResult.success({
    required dynamic input,
    required dynamic result,
    required Duration duration,
  }) {
    return TestResult._(
      input: input,
      result: result,
      error: null,
      duration: duration,
      isSuccess: true,
    );
  }

  factory TestFailure({
    required dynamic input,
    required String error,
    required Duration duration,
  }) {
    return TestResult._(
      input: input,
      result: null,
      error: error,
      duration: duration,
      isSuccess: false,
    );
  }
}

class PerformanceTestResult {
  final Duration totalDuration;
  final int iterations;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final int errorCount;
  final List<String> errors;

  const PerformanceTestResult({
    required this.totalDuration,
    required this.iterations,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.errorCount,
    required this.errors,
  });

  @override
  String toString() {
    return '''
Performance Test Results:
- Total Duration: ${totalDuration.inMilliseconds}ms
- Iterations: $iterations
- Average Duration: ${averageDuration.inMicroseconds}μs
- Min Duration: ${minDuration.inMicroseconds}μs
- Max Duration: ${maxDuration.inMicroseconds}μs
- Error Count: $errorCount
- Success Rate: ${((iterations - errorCount) / iterations * 100).toStringAsFixed(2)}%
''';
  }
}

class StressTestResult {
  final Duration totalDuration;
  final int totalTasks;
  final int successfulTasks;
  final int failedTasks;
  final Duration averageDuration;
  final List<TestResult> results;

  const StressTestResult({
    required this.totalDuration,
    required this.totalTasks,
    required this.successfulTasks,
    required this.failedTasks,
    required this.averageDuration,
    required this.results,
  });

  @override
  String toString() {
    return '''
Stress Test Results:
- Total Duration: ${totalDuration.inSeconds}s
- Total Tasks: $totalTasks
- Successful Tasks: $successfulTasks
- Failed Tasks: $failedTasks
- Success Rate: ${(successfulTasks / totalTasks * 100).toStringAsFixed(2)}%
- Average Duration: ${averageDuration.inMicroseconds}μs
- Tasks per Second: ${(totalTasks / totalDuration.inSeconds).toStringAsFixed(2)}
''';
  }
}

/// Mock 데이터 빌더
class MockDataBuilder<T> {
  final Map<String, dynamic> _data = {};
  final T Function(Map<String, dynamic> data) _builder;

  MockDataBuilder(this._builder);

  /// 필드 설정
  MockDataBuilder<T> withField(String key, dynamic value) {
    _data[key] = value;
    return this;
  }

  /// 랜덤 필드 설정
  MockDataBuilder<T> withRandomField(String key) {
    _data[key] = TestDataGenerator.randomString();
    return this;
  }

  /// 랜덤 이메일 설정
  MockDataBuilder<T> withRandomEmail([String key = 'email']) {
    _data[key] = TestDataGenerator.randomEmail();
    return this;
  }

  /// 랜덤 전화번호 설정
  MockDataBuilder<T> withRandomPhone([String key = 'phone']) {
    _data[key] = TestDataGenerator.randomPhoneNumber();
    return this;
  }

  /// 랜덤 날짜 설정
  MockDataBuilder<T> withRandomDate([String key = 'date']) {
    _data[key] = TestDataGenerator.randomDate();
    return this;
  }

  /// 랜덤 ID 설정
  MockDataBuilder<T> withRandomId([String key = 'id']) {
    _data[key] = TestDataGenerator.randomId();
    return this;
  }

  /// 객체 빌드
  T build() {
    return _builder(_data);
  }

  /// 여러 객체 빌드
  List<T> buildMany(int count) {
    return List.generate(count, (index) => build());
  }
}

/// 테스트 헬퍼 확장 메서드들
extension TestHelperExtensions on Object {
  /// 객체가 특정 타입인지 확인
  bool isType<T>() => this is T;

  /// 객체를 특정 타입으로 캐스팅 (테스트용)
  T asType<T>() => this as T;

  /// 객체의 JSON 표현 생성 (테스트용)
  Map<String, dynamic> toTestJson() {
    // TODO: JSON 변환 구현
    return {'type': runtimeType.toString(), 'value': toString()};
  }
}

extension ListTestExtensions<T> on List<T> {
  /// 리스트에서 랜덤 요소 선택
  T get randomElement {
    if (isEmpty) throw StateError('Cannot get random element from empty list');
    return this[math.Random().nextInt(length)];
  }

  /// 리스트에서 랜덤 요소들 선택
  List<T> randomElements(int count) {
    if (count > length) {
      throw ArgumentError('Count cannot be greater than list length');
    }

    final shuffled = List<T>.from(this)..shuffle();
    return shuffled.take(count).toList();
  }

  /// 리스트를 테스트용 JSON으로 변환
  List<Map<String, dynamic>> toTestJsonList() {
    return map(
      (item) => item?.toTestJson(),
    ).where((json) => json != null).cast<Map<String, dynamic>>().toList();
  }
}
