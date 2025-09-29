import 'package:flutter/foundation.dart';

import '../shared.dart';

/// 🛡️ 입력 검증 강화 서비스
///
/// 모든 사용자 입력에 대한 포괄적인 검증을 수행합니다.
/// XSS, SQL Injection, 악성 스크립트 등 보안 위협을 차단합니다.
class InputValidationService {
  static const _tag = 'InputValidationService';

  /// 포괄적 입력 검증
  ///
  /// [input] 검증할 입력 문자열
  /// [fieldName] 필드 이름 (에러 메시지용)
  /// [maxLength] 최대 길이 제한
  /// [allowHtml] HTML 태그 허용 여부 (기본: false)
  /// [allowSpecialChars] 특수문자 허용 여부 (기본: true)
  static Result<String> validateUserInput(
    String? input, {
    required String fieldName,
    int? maxLength,
    bool allowHtml = false,
    bool allowSpecialChars = true,
    bool isRequired = true,
  }) {
    try {
      // 1. 기본 null/empty 검사
      if (input == null || input.trim().isEmpty) {
        if (isRequired) {
          return Result.failure('$fieldNameは必須項目です');
        }
        return Result.success('', 'Empty input allowed');
      }

      final trimmedInput = input.trim();

      // 2. 길이 검사
      if (maxLength != null && trimmedInput.length > maxLength) {
        return Result.failure('$fieldNameは$maxLength文字以下で入力してください');
      }

      // 3. XSS 공격 패턴 검사
      if (!allowHtml) {
        if (_containsXssPatterns(trimmedInput)) {
          _logSecurityThreat('XSS attempt detected', fieldName, trimmedInput);
          return Result.failure('$fieldNameに不正な文字が含まれています');
        }
      }

      // 4. SQL Injection 패턴 검사
      if (_containsSqlInjectionPatterns(trimmedInput)) {
        _logSecurityThreat(
          'SQL injection attempt detected',
          fieldName,
          trimmedInput,
        );
        return Result.failure('$fieldNameに不正なSQL文字列が含まれています');
      }

      // 5. 명령어 실행 패턴 검사
      if (_containsCommandInjectionPatterns(trimmedInput)) {
        _logSecurityThreat(
          'Command injection attempt detected',
          fieldName,
          trimmedInput,
        );
        return Result.failure('$fieldNameに不正なコマンドが含まれています');
      }

      // 6. 파일 경로 탐색 패턴 검사
      if (_containsPathTraversalPatterns(trimmedInput)) {
        _logSecurityThreat(
          'Path traversal attempt detected',
          fieldName,
          trimmedInput,
        );
        return Result.failure('$fieldNameに不正なパス文字列が含まれています');
      }

      // 7. 제어 문자 검사
      if (_containsControlCharacters(trimmedInput)) {
        _logSecurityThreat(
          'Control character detected',
          fieldName,
          trimmedInput,
        );
        return Result.failure('$fieldNameに不正な制御文字が含まれています');
      }

      // 8. 특수문자 제한 검사
      if (!allowSpecialChars) {
        if (_containsSpecialCharacters(trimmedInput)) {
          return Result.failure('$fieldNameに使用できない特殊文字が含まれています');
        }
      }

      // 9. 안전한 입력으로 확인됨
      return Result.success(trimmedInput, '$fieldNameの検証が完了しました');
    } catch (error, stackTrace) {
      _logSecurityThreat('Input validation error', fieldName, input);
      if (kDebugMode) {
        debugPrint('[$_tag] Validation error: $error\n$stackTrace');
      }
      return Result.failure('$fieldNameの検証中にエラーが発生しました');
    }
  }

  /// XSS 패턴 검사
  static bool _containsXssPatterns(String input) {
    final lowerInput = input.toLowerCase();
    return lowerInput.contains('<script') ||
        lowerInput.contains('javascript:') ||
        lowerInput.contains('onload=') ||
        lowerInput.contains('onclick=') ||
        lowerInput.contains('<iframe') ||
        lowerInput.contains('<object') ||
        lowerInput.contains('<embed') ||
        lowerInput.contains('<applet') ||
        lowerInput.contains('expression(') ||
        lowerInput.contains('vbscript:') ||
        lowerInput.contains('data:text/html');
  }

  /// SQL Injection 패턴 검사
  static bool _containsSqlInjectionPatterns(String input) {
    final lowerInput = input.toLowerCase();
    return lowerInput.contains('select ') ||
        lowerInput.contains('insert ') ||
        lowerInput.contains('update ') ||
        lowerInput.contains('delete ') ||
        lowerInput.contains('drop ') ||
        lowerInput.contains('union select') ||
        lowerInput.contains('or 1=1') ||
        lowerInput.contains('and 1=1') ||
        lowerInput.contains('--') ||
        lowerInput.contains('/*') ||
        lowerInput.contains('cast(');
  }

  /// 명령어 실행 패턴 검사
  static bool _containsCommandInjectionPatterns(String input) {
    final lowerInput = input.toLowerCase();
    return lowerInput.contains('cmd ') ||
        lowerInput.contains('powershell') ||
        lowerInput.contains('bash') ||
        lowerInput.contains('exec(') ||
        lowerInput.contains('system(') ||
        lowerInput.contains('eval(') ||
        lowerInput.contains('rm ') ||
        lowerInput.contains('del ') ||
        lowerInput.contains('format') ||
        lowerInput.contains('&&') ||
        lowerInput.contains(';') ||
        lowerInput.contains('`') ||
        lowerInput.contains('\$(');
  }

  /// 파일 경로 탐색 패턴 검사
  static bool _containsPathTraversalPatterns(String input) {
    return input.contains('../') ||
        input.contains('..\\') ||
        input.contains('%2e%2e%2f') ||
        input.contains('%2e%2e%5c') ||
        input.contains('..%2f') ||
        input.contains('..%5c');
  }

  /// 제어 문자 검사
  static bool _containsControlCharacters(String input) {
    for (int i = 0; i < input.length; i++) {
      final char = input.codeUnitAt(i);
      if (char < 32 && char != 9 && char != 10 && char != 13) {
        return true;
      }
      if (char == 127) {
        return true;
      }
    }
    return false;
  }

  /// 특수문자 검사
  static bool _containsSpecialCharacters(String input) {
    const specialChars = '<>{}[]\\|`~!@#\$%^&*()+=';
    for (int i = 0; i < input.length; i++) {
      if (specialChars.contains(input[i])) {
        return true;
      }
    }
    return false;
  }

  /// 이메일 입력 특별 검증
  static Result<String> validateEmailInput(String? email) {
    // 기본 보안 검증 수행
    final securityResult = validateUserInput(
      email,
      fieldName: 'メールアドレス',
      maxLength: 254, // RFC 5321 기준
      allowHtml: false,
      allowSpecialChars: true, // @ 등 이메일 특수문자 허용
    );

    if (!securityResult.isSuccess) {
      return securityResult;
    }

    // 기존 이메일 검증 로직 활용
    final emailValidation = ValidationService.validateEmail(
      securityResult.data!,
    );
    if (!emailValidation.isSuccess) {
      return Result.failure(emailValidation.message);
    }
    return securityResult;
  }

  /// 비밀번호 입력 특별 검증
  static Result<String> validatePasswordInput(String? password) {
    // 기본 보안 검증 (특수문자 허용)
    final securityResult = validateUserInput(
      password,
      fieldName: 'パスワード',
      maxLength: 128,
      allowHtml: false,
      allowSpecialChars: true,
    );

    if (!securityResult.isSuccess) {
      return securityResult;
    }

    // 기존 비밀번호 검증 로직 활용
    final passwordValidation = ValidationService.validatePassword(
      securityResult.data!,
    );
    if (!passwordValidation.isSuccess) {
      return Result.failure(passwordValidation.message);
    }
    return securityResult;
  }

  /// 펫 이름 입력 특별 검증
  static Result<String> validatePetNameInput(String? name) {
    // 기본 보안 검증 (HTML, 특수문자 제한)
    final securityResult = validateUserInput(
      name,
      fieldName: 'ペット名',
      maxLength: 50,
      allowHtml: false,
      allowSpecialChars: false,
    );

    if (!securityResult.isSuccess) {
      return securityResult;
    }

    // 기존 펫 이름 검증 로직 활용
    final petNameValidation = ValidationService.validatePetName(
      securityResult.data!,
    );
    if (!petNameValidation.isSuccess) {
      return Result.failure(petNameValidation.message);
    }
    return securityResult;
  }

  /// 숫자 입력 특별 검증 (체중, 나이 등)
  static Result<double> validateNumericInput(
    String? input, {
    required String fieldName,
    double? min,
    double? max,
  }) {
    // 기본 보안 검증
    final securityResult = validateUserInput(
      input,
      fieldName: fieldName,
      maxLength: 20,
      allowHtml: false,
      allowSpecialChars: false, // 숫자와 소수점만 허용
    );

    if (!securityResult.isSuccess) {
      return Result.failure(securityResult.message);
    }

    // 숫자 형식 검증
    final validationResult = ValidationService.validateNumberField(
      securityResult.data!,
      fieldName,
      min: min,
      max: max,
    );

    if (!validationResult.isSuccess) {
      return Result.failure(validationResult.message);
    }

    // 숫자로 변환
    final number = double.tryParse(securityResult.data!);
    if (number == null) {
      return Result.failure('$fieldNameは有効な数値ではありません');
    }

    return Result.success('$fieldNameの検証が完了しました', number);
  }

  /// 검색어 입력 검증
  static Result<String> validateSearchInput(String? query) {
    return validateUserInput(
      query,
      fieldName: '検索キーワード',
      maxLength: 100,
      allowHtml: false,
      allowSpecialChars: true,
      isRequired: false,
    );
  }

  /// 댓글/리뷰 입력 검증
  static Result<String> validateCommentInput(String? comment) {
    return validateUserInput(
      comment,
      fieldName: 'コメント',
      maxLength: 1000,
      allowHtml: false,
      allowSpecialChars: true,
    );
  }

  /// URL 입력 검증
  static Result<String> validateUrlInput(String? url) {
    // 기본 보안 검증
    final securityResult = validateUserInput(
      url,
      fieldName: 'URL',
      maxLength: 2048,
      allowHtml: false,
      allowSpecialChars: true,
      isRequired: false,
    );

    if (!securityResult.isSuccess) {
      return securityResult;
    }

    if (securityResult.data?.isEmpty ?? true) {
      return securityResult;
    }

    // URL 형식 검증
    final urlValidation = ValidationService.validateUrl(securityResult.data);
    if (!urlValidation.isSuccess) {
      return Result.failure(urlValidation.message);
    }

    return securityResult;
  }

  /// 전화번호 입력 검증
  static Result<String> validatePhoneInput(String? phone) {
    // 기본 보안 검증 (숫자, 하이픈, 공백, 괄호만 허용)
    final securityResult = validateUserInput(
      phone,
      fieldName: '電話番号',
      maxLength: 20,
      allowHtml: false,
      allowSpecialChars: false,
      isRequired: false,
    );

    if (!securityResult.isSuccess) {
      return securityResult;
    }

    if (securityResult.data?.isEmpty ?? true) {
      return securityResult;
    }

    // 전화번호 패턴 검증 (숫자, 하이픈, 공백, 괄호만)
    if (!_isValidPhoneNumber(securityResult.data!)) {
      return Result.failure('電話番号は数字、ハイフン、スペース、括弧のみ使用できます');
    }

    // 기존 전화번호 검증 로직 활용
    final phoneValidation = ValidationService.validatePhoneNumber(
      securityResult.data!,
    );
    if (!phoneValidation.isSuccess) {
      return Result.failure(phoneValidation.message);
    }

    return securityResult;
  }

  /// 전화번호 패턴 검증
  static bool _isValidPhoneNumber(String phone) {
    for (int i = 0; i < phone.length; i++) {
      final char = phone[i];
      if (!RegExp(r'[0-9\s\-\(\)+]').hasMatch(char)) {
        return false;
      }
    }
    return true;
  }

  /// 보안 위협 로깅
  static void _logSecurityThreat(
    String threatType,
    String fieldName,
    String? input,
  ) {
    if (kDebugMode) {
      debugPrint('[$_tag] 🚨 SECURITY THREAT DETECTED 🚨');
      debugPrint('[$_tag] Type: $threatType');
      debugPrint('[$_tag] Field: $fieldName');
      debugPrint(
        '[$_tag] Input: ${input?.substring(0, (input.length).clamp(0, 100))}${input != null && input.length > 100 ? '...' : ''}',
      );
      debugPrint('[$_tag] Timestamp: ${DateTime.now().toIso8601String()}');
    }
  }

  /// 입력 무결성 검증 (해시 기반)
  static Result<bool> verifyInputIntegrity(String input, String expectedHash) {
    try {
      // 실제 구현에서는 보안 해시 함수 사용 (SHA-256 등)
      final actualHash = input.hashCode.toString();

      if (actualHash == expectedHash) {
        return Result.success('Input integrity verified', true);
      } else {
        _logSecurityThreat('Input integrity violation', 'hash_check', input);
        return Result.failure('入力データの整合性に問題があります');
      }
    } catch (error) {
      return Result.failure('整合性検証中にエラーが発生しました');
    }
  }

  /// 입력 정규화 (sanitization)
  static String sanitizeInput(String input) {
    try {
      return input
          .trim()
          .replaceAll(
            RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
            '',
          ) // 제어 문자 제거
          .replaceAll(RegExp(r'\s+'), ' ') // 연속 공백을 단일 공백으로
          .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
            '',
          ) // 스크립트 태그 제거
          .replaceAll(
            RegExp(r'javascript:', caseSensitive: false),
            '',
          ) // javascript: 제거
          .replaceAll(
            RegExp(r'on\w+\s*=', caseSensitive: false),
            '',
          ); // 이벤트 핸들러 제거
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] Sanitization error: $error');
      }
      return input.trim(); // 기본적으로 trim만 수행
    }
  }

  /// 대량 입력 검증 (여러 필드를 한번에 처리)
  static Result<Map<String, String>> validateMultipleInputs(
    Map<String, String?> inputs,
    Map<String, InputValidationConfig> configs,
  ) {
    try {
      final validatedInputs = <String, String>{};

      for (final entry in inputs.entries) {
        final fieldName = entry.key;
        final input = entry.value;
        final config = configs[fieldName];

        if (config == null) {
          return Result.failure('設定が見つからないフィールドがあります: $fieldName');
        }

        final result = validateUserInput(
          input,
          fieldName: config.displayName,
          maxLength: config.maxLength,
          allowHtml: config.allowHtml,
          allowSpecialChars: config.allowSpecialChars,
          isRequired: config.isRequired,
        );

        if (!result.isSuccess) {
          return Result.failure(result.message);
        }

        validatedInputs[fieldName] = result.data!;
      }

      return Result.success('全ての入力検証が完了しました', validatedInputs);
    } catch (error) {
      return Result.failure('複数入力検証中にエラーが発生しました: $error');
    }
  }
}

/// 입력 검증 설정 클래스
class InputValidationConfig {
  final String displayName;
  final int? maxLength;
  final bool allowHtml;
  final bool allowSpecialChars;
  final bool isRequired;

  const InputValidationConfig({
    required this.displayName,
    this.maxLength,
    this.allowHtml = false,
    this.allowSpecialChars = true,
    this.isRequired = true,
  });
}
