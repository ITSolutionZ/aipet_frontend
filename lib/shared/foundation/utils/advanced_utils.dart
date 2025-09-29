/// 🎯 고급 유틸리티 및 확장 메서드
///
/// 코드 재사용성을 극대화하는 고급 유틸리티 함수들과
/// 편리한 확장 메서드들을 제공합니다.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:aipet_frontend/shared/foundation/result/result.dart';

/// 고급 비동기 유틸리티
class AdvancedAsyncUtils {
  /// 여러 Future를 병렬로 실행하고 첫 번째 완료된 결과 반환
  static Future<T> race<T>(List<Future<T>> futures) async {
    if (futures.isEmpty) {
      throw ArgumentError('Futures list cannot be empty');
    }

    final completer = Completer<T>();
    final subscription = Stream.fromFutures(futures).listen((result) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    });

    final result = await completer.future;
    await subscription.cancel();
    return result;
  }

  /// Future를 타임아웃과 함께 실행하고 Result로 래핑
  static Future<Result<T>> withTimeout<T>(
    Future<T> future,
    Duration timeout, {
    String? timeoutMessage,
  }) async {
    try {
      final result = await future.timeout(timeout);
      return Result.success(result);
    } on TimeoutException {
      return Result.failure(
        timeoutMessage ??
            'Operation timed out after ${timeout.inSeconds} seconds',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return Result.fromException(Exception(e.toString()));
    }
  }

  /// Future를 디바운스하여 실행
  static Future<T> debounce<T>(
    Duration delay,
    Future<T> Function() operation,
  ) async {
    final completer = Completer<T>();
    Timer? timer;

    timer?.cancel();
    timer = Timer(delay, () async {
      try {
        final result = await operation();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return completer.future;
  }

  /// Future를 스로틀링하여 실행
  static Future<T> throttle<T>(
    Duration interval,
    Future<T> Function() operation,
  ) async {
    final now = DateTime.now();
    final lastExecution = _lastThrottleExecution[operation.hashCode];

    if (lastExecution != null && now.difference(lastExecution) < interval) {
      // 스로틀링 중이면 마지막 결과 반환
      return _lastThrottleResult[operation.hashCode] as T;
    }

    final result = await operation();
    _lastThrottleExecution[operation.hashCode] = now;
    _lastThrottleResult[operation.hashCode] = result;

    return result;
  }

  static final Map<int, DateTime> _lastThrottleExecution = {};
  static final Map<int, dynamic> _lastThrottleResult = {};

  /// Future를 재시도와 함께 실행
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Exception)? retryCondition,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts <= maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (retryCondition != null && !retryCondition(lastException)) {
          break;
        }

        if (attempts <= maxRetries) {
          await Future.delayed(delay * attempts); // 지수 백오프
        }
      }
    }

    throw lastException!;
  }
}

/// 고급 컬렉션 유틸리티
class AdvancedCollectionUtils {
  /// 리스트를 청크로 분할
  static List<List<T>> chunk<T>(List<T> list, int chunkSize) {
    if (chunkSize <= 0) {
      throw ArgumentError('Chunk size must be positive');
    }

    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, math.min(i + chunkSize, list.length)));
    }
    return chunks;
  }

  /// 리스트에서 중복 제거 (순서 유지)
  static List<T> distinct<T>(List<T> list) {
    final seen = <T>{};
    return list.where((item) => seen.add(item)).toList();
  }

  /// 리스트에서 조건에 맞는 중복 제거
  static List<T> distinctBy<T, K>(
    List<T> list,
    K Function(T item) keySelector,
  ) {
    final seen = <K>{};
    return list.where((item) => seen.add(keySelector(item))).toList();
  }

  /// 리스트를 그룹화
  static Map<K, List<T>> groupBy<T, K>(
    List<T> list,
    K Function(T item) keySelector,
  ) {
    final groups = <K, List<T>>{};
    for (final item in list) {
      final key = keySelector(item);
      groups.putIfAbsent(key, () => <T>[]).add(item);
    }
    return groups;
  }

  /// 리스트에서 윈도우 슬라이딩
  static List<List<T>> windowed<T>(
    List<T> list,
    int windowSize, {
    int step = 1,
    bool partialWindows = false,
  }) {
    final windows = <List<T>>[];
    for (int i = 0; i < list.length; i += step) {
      final window = list.sublist(i, math.min(i + windowSize, list.length));

      if (partialWindows || window.length == windowSize) {
        windows.add(window);
      }
    }
    return windows;
  }

  /// 리스트에서 슬라이딩 윈도우
  static List<List<T>> sliding<T>(
    List<T> list,
    int windowSize, {
    bool partialWindows = false,
  }) {
    return windowed(list, windowSize, step: 1, partialWindows: partialWindows);
  }
}

/// 고급 문자열 유틸리티
class AdvancedStringUtils {
  /// 문자열을 카멜케이스로 변환
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    final words = input.split(RegExp(r'[\s\-_]+'));
    if (words.length == 1) {
      return words[0].toLowerCase();
    }

    return words[0].toLowerCase() +
        words.skip(1).map((word) => word.capitalize()).join();
  }

  /// 문자열을 파스칼케이스로 변환
  static String toPascalCase(String input) {
    if (input.isEmpty) return input;

    final words = input.split(RegExp(r'[\s\-_]+'));
    return words.map((word) => word.capitalize()).join();
  }

  /// 문자열을 스네이크케이스로 변환
  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// 문자열을 케밥케이스로 변환
  static String toKebabCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '-${match.group(0)!.toLowerCase()}',
        )
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// 문자열을 마스킹 (중간 부분 숨기기)
  static String mask(
    String input, {
    int visibleStart = 2,
    int visibleEnd = 2,
    String maskChar = '*',
  }) {
    if (input.length <= visibleStart + visibleEnd) {
      return maskChar * input.length;
    }

    final start = input.substring(0, visibleStart);
    final end = input.substring(input.length - visibleEnd);
    final middle = maskChar * (input.length - visibleStart - visibleEnd);

    return '$start$middle$end';
  }

  /// 문자열을 트리밍하고 null/빈 문자열 처리
  static String? trimOrNull(String? input) {
    final trimmed = input?.trim();
    return trimmed?.isEmpty == true ? null : trimmed;
  }

  /// 문자열이 이메일 형식인지 확인
  static bool isEmail(String input) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(input);
  }

  /// 문자열이 전화번호 형식인지 확인
  static bool isPhoneNumber(String input) {
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(input.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// 문자열을 Base64로 인코딩
  static String toBase64(String input) {
    return base64Encode(utf8.encode(input));
  }

  /// Base64 문자열을 디코딩
  static String fromBase64(String input) {
    return utf8.decode(base64Decode(input));
  }
}

/// 고급 JSON 유틸리티
class AdvancedJsonUtils {
  /// 객체를 JSON으로 안전하게 변환
  static Result<String> toJson(dynamic object) {
    try {
      final json = jsonEncode(object);
      return Result.success(json);
    } catch (e) {
      return Result.failure(
        'Failed to convert to JSON: ${e.toString()}',
        code: 'JSON_ENCODE_ERROR',
      );
    }
  }

  /// JSON을 객체로 안전하게 변환
  static Result<T> fromJson<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJsonConverter,
  ) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final object = fromJsonConverter(json);
      return Result.success(object);
    } catch (e) {
      return Result.failure(
        'Failed to parse JSON: ${e.toString()}',
        code: 'JSON_DECODE_ERROR',
      );
    }
  }

  /// JSON을 리스트로 안전하게 변환
  static Result<List<T>> fromJsonList<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJsonConverter,
  ) {
    try {
      final jsonList = jsonDecode(jsonString) as List;
      final objects = jsonList
          .map((item) => fromJsonConverter(item as Map<String, dynamic>))
          .toList();
      return Result.success(objects);
    } catch (e) {
      return Result.failure(
        'Failed to parse JSON list: ${e.toString()}',
        code: 'JSON_DECODE_ERROR',
      );
    }
  }

  /// JSON 파일을 읽고 파싱
  static Future<Result<T>> loadJsonFromFile<T>(
    String filePath,
    T Function(Map<String, dynamic>) fromJsonConverter,
  ) async {
    try {
      // TODO: 파일 읽기 구현 (path_provider 등 사용)
      throw UnimplementedError('File reading not implemented yet');
    } catch (e) {
      return Result.failure(
        'Failed to load JSON from file: ${e.toString()}',
        code: 'FILE_READ_ERROR',
      );
    }
  }
}

/// 확장 메서드들
extension StringExtensions on String {
  /// 첫 번째 문자를 대문자로 변환
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// 모든 단어의 첫 번째 문자를 대문자로 변환
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// 문자열이 null이거나 비어있는지 확인
  bool get isNullOrEmpty => isEmpty;

  /// 문자열이 null이 아니고 비어있지 않은지 확인
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 문자열을 지정된 길이로 자르고 생략 부호 추가
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// 문자열에서 HTML 태그 제거
  String stripHtmlTags() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 문자열을 단어 단위로 자르기
  List<String> splitIntoWords() {
    return split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  }

  /// 문자열에서 특수문자 제거
  String removeSpecialCharacters() {
    return replaceAll(RegExp(r'[^\w\s]'), '');
  }

  /// 문자열을 반전
  String get reversed => split('').reversed.join();

  /// 문자열이 팰린드롬인지 확인
  bool get isPalindrome {
    final cleaned = toLowerCase().removeSpecialCharacters().replaceAll(' ', '');
    return cleaned == cleaned.reversed;
  }
}

extension ListExtensions<T> on List<T> {
  /// 리스트가 null이 아니고 비어있지 않은지 확인
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 리스트가 null이거나 비어있는지 확인
  bool get isNullOrEmpty => isEmpty;

  /// 리스트에서 중복 제거
  List<T> get distinct => AdvancedCollectionUtils.distinct(this);

  /// 조건에 맞는 중복 제거
  List<T> distinctBy<K>(K Function(T item) keySelector) {
    return AdvancedCollectionUtils.distinctBy(this, keySelector);
  }

  /// 리스트를 그룹화
  Map<K, List<T>> groupBy<K>(K Function(T item) keySelector) {
    return AdvancedCollectionUtils.groupBy(this, keySelector);
  }

  /// 리스트를 청크로 분할
  List<List<T>> chunk(int chunkSize) {
    return AdvancedCollectionUtils.chunk(this, chunkSize);
  }

  /// 윈도우 슬라이딩
  List<List<T>> windowed(
    int windowSize, {
    int step = 1,
    bool partialWindows = false,
  }) {
    return AdvancedCollectionUtils.windowed(
      this,
      windowSize,
      step: step,
      partialWindows: partialWindows,
    );
  }

  /// 슬라이딩 윈도우
  List<List<T>> sliding(int windowSize, {bool partialWindows = false}) {
    return AdvancedCollectionUtils.sliding(
      this,
      windowSize,
      partialWindows: partialWindows,
    );
  }

  /// 안전한 인덱스 접근
  T? getOrNull(int index) {
    return (index >= 0 && index < length) ? this[index] : null;
  }

  /// 안전한 첫 번째 요소 접근
  T? get firstOrNull => isNotEmpty ? first : null;

  /// 안전한 마지막 요소 접근
  T? get lastOrNull => isNotEmpty ? last : null;
}

extension MapExtensions<K, V> on Map<K, V> {
  /// 맵이 null이 아니고 비어있지 않은지 확인
  bool get isNotNullOrEmpty => isNotEmpty;

  /// 맵이 null이거나 비어있는지 확인
  bool get isNullOrEmpty => isEmpty;

  /// 키로 값을 안전하게 가져오기
  T? getAs<T>(K key) => this[key] is T ? this[key] as T : null;

  /// 키로 값을 안전하게 가져오기 (기본값 포함)
  T getAsOr<T>(K key, T defaultValue) =>
      this[key] is T ? this[key] as T : defaultValue;

  /// 키로 값을 안전하게 가져오기 (계산된 기본값)
  T getAsOrElse<T>(K key, T Function() defaultValueSupplier) {
    return this[key] is T ? this[key] as T : defaultValueSupplier();
  }

  /// 맵을 JSON 문자열로 변환
  Result<String> toJsonString() {
    return AdvancedJsonUtils.toJson(this);
  }
}

extension DateTimeExtensions on DateTime {
  /// 날짜가 오늘인지 확인
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 날짜가 어제인지 확인
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 날짜가 내일인지 확인
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// 날짜를 상대적 시간 문자열로 변환
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years年前';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$monthsヶ月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  /// 날짜를 포맷된 문자열로 변환
  String format(String pattern) {
    // TODO: 날짜 포맷팅 구현 (intl 패키지 등 사용)
    return toIso8601String();
  }
}
