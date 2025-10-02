/// 문자열 관련 공통 유틸리티 함수들
class StringUtils {
  StringUtils._();

  /// 문자열이 비어있거나 null인지 확인
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// 문자열이 비어있지 않은지 확인
  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  /// 문자열을 안전하게 trim
  static String safeTrim(String? value) {
    return value?.trim() ?? '';
  }

  /// 문자열 길이 확인 (null 안전)
  static int safeLength(String? value) {
    return value?.length ?? 0;
  }

  /// 문자열이 최소 길이를 만족하는지 확인
  static bool hasMinLength(String? value, int minLength) {
    return safeLength(value) >= minLength;
  }

  /// 문자열이 최대 길이를 만족하는지 확인
  static bool hasMaxLength(String? value, int maxLength) {
    return safeLength(value) <= maxLength;
  }

  /// 문자열이 길이 범위 내에 있는지 확인
  static bool isLengthInRange(String? value, int minLength, int maxLength) {
    final length = safeLength(value);
    return length >= minLength && length <= maxLength;
  }

  /// 이메일 형식 검증
  static bool isValidEmail(String? email) {
    if (isEmpty(email)) return false;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email!);
  }

  /// 전화번호 형식 검증 (한국 형식)
  static bool isValidPhoneNumber(String? phone) {
    if (isEmpty(phone)) return false;

    final phoneRegex = RegExp(r'^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$');
    return phoneRegex.hasMatch(phone!);
  }

  /// URL 형식 검증
  static bool isValidUrl(String? url) {
    if (isEmpty(url)) return false;

    try {
      Uri.parse(url!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 숫자만 포함하는지 확인
  static bool isNumeric(String? value) {
    if (isEmpty(value)) return false;
    return double.tryParse(value!) != null;
  }

  /// 양수인지 확인
  static bool isPositiveNumber(String? value) {
    if (isEmpty(value)) return false;
    final number = double.tryParse(value!);
    return number != null && number > 0;
  }

  /// 문자열을 숫자로 변환 (안전)
  static double? parseDouble(String? value) {
    if (isEmpty(value)) return null;
    return double.tryParse(value!);
  }

  /// 문자열을 정수로 변환 (안전)
  static int? parseInt(String? value) {
    if (isEmpty(value)) return null;
    return int.tryParse(value!);
  }

  /// 문자열을 대문자로 변환 (null 안전)
  static String toUpperCase(String? value) {
    return value?.toUpperCase() ?? '';
  }

  /// 문자열을 소문자로 변환 (null 안전)
  static String toLowerCase(String? value) {
    return value?.toLowerCase() ?? '';
  }

  /// 첫 글자를 대문자로 변환
  static String capitalize(String? value) {
    if (isEmpty(value)) return '';
    if (value!.length == 1) return value.toUpperCase();
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// 모든 단어의 첫 글자를 대문자로 변환
  static String capitalizeWords(String? value) {
    if (isEmpty(value)) return '';

    return value!.split(' ').map((word) => capitalize(word)).join(' ');
  }

  /// 문자열을 지정된 길이로 자르고 말줄임표 추가
  static String truncate(String? value, int maxLength, {String suffix = '...'}) {
    if (isEmpty(value)) return '';
    if (value!.length <= maxLength) return value;

    return value.substring(0, maxLength - suffix.length) + suffix;
  }

  /// 문자열에서 특정 패턴을 다른 문자열로 치환
  static String replaceAll(String? value, String pattern, String replacement) {
    if (isEmpty(value)) return '';
    return value!.replaceAll(pattern, replacement);
  }

  /// 문자열에서 공백 제거
  static String removeWhitespace(String? value) {
    if (isEmpty(value)) return '';
    return value!.replaceAll(RegExp(r'\s+'), '');
  }

  /// 문자열이 특정 문자열로 시작하는지 확인
  static bool startsWith(String? value, String prefix) {
    if (isEmpty(value)) return false;
    return value!.startsWith(prefix);
  }

  /// 문자열이 특정 문자열로 끝나는지 확인
  static bool endsWith(String? value, String suffix) {
    if (isEmpty(value)) return false;
    return value!.endsWith(suffix);
  }

  /// 문자열에 특정 문자열이 포함되어 있는지 확인
  static bool contains(String? value, String substring) {
    if (isEmpty(value)) return false;
    return value!.contains(substring);
  }

  /// 문자열을 지정된 구분자로 분할
  static List<String> split(String? value, String delimiter) {
    if (isEmpty(value)) return [];
    return value!.split(delimiter);
  }

  /// 문자열 배열을 지정된 구분자로 결합
  static String join(List<String> values, String delimiter) {
    return values.join(delimiter);
  }

  /// 문자열이 null이면 기본값 반환
  static String defaultIfEmpty(String? value, String defaultValue) {
    return isEmpty(value) ? defaultValue : value!;
  }

  /// 문자열이 null이면 빈 문자열 반환
  static String emptyIfNull(String? value) {
    return value ?? '';
  }

  /// 마스킹 처리 (이메일, 전화번호 등)
  static String maskEmail(String? email) {
    if (isEmpty(email) || !isValidEmail(email)) return email ?? '';

    final parts = email!.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}*@$domain';
    } else {
      return '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}@$domain';
    }
  }

  /// 마스킹 처리 (전화번호)
  static String maskPhoneNumber(String? phone) {
    if (isEmpty(phone)) return phone ?? '';

    final cleaned = phone!.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 4) return phone;

    return '${cleaned.substring(0, 3)}-****-${cleaned.substring(cleaned.length - 4)}';
  }

  /// 문자열을 지정된 길이로 패딩 (왼쪽)
  static String padLeft(String? value, int width, String padding) {
    if (isEmpty(value)) return padding * width;
    return value!.padLeft(width, padding);
  }

  /// 문자열을 지정된 길이로 패딩 (오른쪽)
  static String padRight(String? value, int width, String padding) {
    if (isEmpty(value)) return padding * width;
    return value!.padRight(width, padding);
  }
}
