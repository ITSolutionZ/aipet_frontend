import 'package:aipet_frontend/shared/validation/input_validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidationService Tests', () {
    group('XSS 공격 패턴 탐지', () {
      test('스크립트 태그 탐지', () {
        const maliciousInputs = [
          '<script>alert("xss")</script>',
          '<SCRIPT>alert("XSS")</SCRIPT>',
          '<script src="malicious.js"></script>',
          'Hello <script>alert(1)</script> World',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect XSS in: $input',
          );
          expect(result.message, contains('不正な文字'));
        }
      });

      test('JavaScript URL 탐지', () {
        const maliciousInputs = [
          'javascript:alert(1)',
          'JAVASCRIPT:alert("XSS")',
          'jAvAsCrIpT:alert(1)',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect JavaScript URL in: $input',
          );
        }
      });

      test('이벤트 핸들러 탐지', () {
        const maliciousInputs = [
          'onload=alert(1)',
          'onclick="alert(1)"',
          'onmouseover=alert(1)',
          '<img onload="alert(1)">',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect event handler in: $input',
          );
        }
      });

      test('iframe 및 object 태그 탐지', () {
        const maliciousInputs = [
          '<iframe src="malicious.html"></iframe>',
          '<object data="malicious.swf"></object>',
          '<embed src="malicious.swf">',
          '<applet code="Malicious.class"></applet>',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect dangerous tag in: $input',
          );
        }
      });
    });

    group('SQL Injection 공격 패턴 탐지', () {
      test('SQL 키워드 탐지', () {
        const maliciousInputs = [
          "'; DROP TABLE users; --",
          '1 OR 1=1',
          'UNION SELECT * FROM users',
          'admin\' --',
          '1; DELETE FROM users; --',
          'SELECT * FROM users WHERE 1=1',
          'INSERT INTO users VALUES',
          'UPDATE users SET',
          'exec xp_cmdshell',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect SQL injection in: $input',
          );
          expect(result.message, contains('SQL'));
        }
      });

      test('SQL 주석 패턴 탐지', () {
        const maliciousInputs = [
          'admin\' --',
          'test /* comment */ union',
          'value -- comment',
          '/* multi line comment */',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect SQL comment in: $input',
          );
        }
      });
    });

    group('Command Injection 공격 패턴 탐지', () {
      test('명령어 실행 패턴 탐지', () {
        const maliciousInputs = [
          'cmd("rm -rf /")',
          'exec("del *.*")',
          'system("format c:")',
          'powershell("Get-Process")',
          'bash("cat /etc/passwd")',
          '`rm -rf /`',
          '\$(cat /etc/passwd)',
          '| rm -rf /',
          '&& del *.*',
          '; format c:',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect command injection in: $input',
          );
          expect(result.message, contains('コマンド'));
        }
      });
    });

    group('Path Traversal 공격 패턴 탐지', () {
      test('디렉토리 탐색 패턴 탐지', () {
        const maliciousInputs = [
          '../../../etc/passwd',
          '..\\..\\..\\windows\\system32',
          '..%2F..%2F..%2Fetc%2Fpasswd',
          '%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd',
          '....//....//....//etc/passwd',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect path traversal in: $input',
          );
          expect(result.message, contains('パス'));
        }
      });
    });

    group('제어 문자 탐지', () {
      test('제어 문자 패턴 탐지', () {
        final maliciousInputs = [
          'test\x00null',
          'test\x08backspace',
          'test\x1Funit_separator',
          'test\x7Fdelete',
          'test\uFEFFbom',
        ];

        for (final input in maliciousInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            false,
            reason: 'Should detect control character in: $input',
          );
          expect(result.message, contains('制御文字'));
        }
      });
    });

    group('정상 입력 허용', () {
      test('일반적인 안전한 입력', () {
        const safeInputs = [
          'Hello World',
          'こんにちは世界',
          'test@example.com',
          '123-456-7890',
          'https://example.com',
          'My pet\'s name is Fluffy',
          'Price: \$19.99',
          'Temperature: 25°C',
        ];

        for (final input in safeInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
          );
          expect(
            result.isSuccess,
            true,
            reason: 'Should allow safe input: $input',
          );
        }
      });

      test('HTML 허용 모드에서 안전한 HTML', () {
        const safeHtmlInputs = [
          '<p>Hello World</p>',
          '<strong>Bold text</strong>',
          '<em>Italic text</em>',
          '<a href="https://example.com">Link</a>',
        ];

        for (final input in safeHtmlInputs) {
          final result = InputValidationService.validateUserInput(
            input,
            fieldName: 'Test Field',
            allowHtml: true,
          );
          expect(
            result.isSuccess,
            true,
            reason: 'Should allow safe HTML: $input',
          );
        }
      });
    });

    group('길이 제한', () {
      test('최대 길이 초과', () {
        const longInput = 'a' * 101;
        final result = InputValidationService.validateUserInput(
          longInput,
          fieldName: 'Test Field',
          maxLength: 100,
        );
        expect(result.isSuccess, false);
        expect(result.message, contains('100文字以下'));
      });

      test('최대 길이 내', () {
        const validInput = 'a' * 50;
        final result = InputValidationService.validateUserInput(
          validInput,
          fieldName: 'Test Field',
          maxLength: 100,
        );
        expect(result.isSuccess, true);
      });
    });

    group('필수 입력 검증', () {
      test('필수 필드 빈 값', () {
        final result = InputValidationService.validateUserInput(
          '',
          fieldName: 'Test Field',
          isRequired: true,
        );
        expect(result.isSuccess, false);
        expect(result.message, contains('必須'));
      });

      test('선택 필드 빈 값', () {
        final result = InputValidationService.validateUserInput(
          '',
          fieldName: 'Test Field',
          isRequired: false,
        );
        expect(result.isSuccess, true);
      });
    });

    group('특수 검증 메서드', () {
      test('이메일 입력 검증', () {
        // 정상 이메일
        var result = InputValidationService.validateEmailInput(
          'test@example.com',
        );
        expect(result.isSuccess, true);

        // XSS 공격이 포함된 이메일
        result = InputValidationService.validateEmailInput(
          '<script>alert(1)</script>@example.com',
        );
        expect(result.isSuccess, false);

        // 너무 긴 이메일
        result = InputValidationService.validateEmailInput(
          '${'a' * 250}@example.com',
        );
        expect(result.isSuccess, false);
      });

      test('비밀번호 입력 검증', () {
        // 정상 비밀번호
        var result = InputValidationService.validatePasswordInput(
          'SecurePassword123!',
        );
        expect(result.isSuccess, true);

        // SQL Injection 시도
        result = InputValidationService.validatePasswordInput(
          "'; DROP TABLE users; --",
        );
        expect(result.isSuccess, false);

        // 너무 긴 비밀번호
        result = InputValidationService.validatePasswordInput('a' * 130);
        expect(result.isSuccess, false);
      });

      test('펫 이름 입력 검증', () {
        // 정상 펫 이름
        var result = InputValidationService.validatePetNameInput('Fluffy');
        expect(result.isSuccess, true);

        // XSS 공격 시도
        result = InputValidationService.validatePetNameInput(
          '<script>alert(1)</script>',
        );
        expect(result.isSuccess, false);

        // 특수문자 포함 (허용되지 않음)
        result = InputValidationService.validatePetNameInput('Pet<>Name');
        expect(result.isSuccess, false);
      });

      test('숫자 입력 검증', () {
        // 정상 숫자
        var result = InputValidationService.validateNumericInput(
          '25.5',
          fieldName: 'Weight',
          min: 0.1,
          max: 100.0,
        );
        expect(result.isSuccess, true);
        expect(result.data, 25.5);

        // 범위 초과
        result = InputValidationService.validateNumericInput(
          '150',
          fieldName: 'Weight',
          min: 0.1,
          max: 100.0,
        );
        expect(result.isSuccess, false);

        // SQL Injection 시도
        result = InputValidationService.validateNumericInput(
          '25; DROP TABLE pets; --',
          fieldName: 'Weight',
        );
        expect(result.isSuccess, false);
      });

      test('URL 입력 검증', () {
        // 정상 URL
        var result = InputValidationService.validateUrlInput(
          'https://example.com',
        );
        expect(result.isSuccess, true);

        // JavaScript URL (보안 위협)
        result = InputValidationService.validateUrlInput('javascript:alert(1)');
        expect(result.isSuccess, false);

        // 너무 긴 URL
        result = InputValidationService.validateUrlInput(
          'https://${'a' * 2050}.com',
        );
        expect(result.isSuccess, false);
      });

      test('전화번호 입력 검증', () {
        // 정상 전화번호
        var result = InputValidationService.validatePhoneInput('090-1234-5678');
        expect(result.isSuccess, true);

        // XSS 공격 시도
        result = InputValidationService.validatePhoneInput(
          '<script>alert(1)</script>',
        );
        expect(result.isSuccess, false);

        // 허용되지 않는 문자
        result = InputValidationService.validatePhoneInput('090-1234-ABCD');
        expect(result.isSuccess, false);
      });
    });

    group('입력 정규화', () {
      test('제어 문자 제거', () {
        const input = 'Hello\x00World\x08Test';
        final sanitized = InputValidationService.sanitizeInput(input);
        expect(sanitized, 'HelloWorldTest');
      });

      test('연속 공백을 단일 공백으로', () {
        const input = 'Hello     World';
        final sanitized = InputValidationService.sanitizeInput(input);
        expect(sanitized, 'Hello World');
      });

      test('스크립트 태그 제거', () {
        const input = 'Hello <script>alert(1)</script> World';
        final sanitized = InputValidationService.sanitizeInput(input);
        expect(sanitized, 'Hello  World');
      });
    });

    group('복수 입력 검증', () {
      test('모든 입력이 유효한 경우', () {
        final inputs = {
          'name': 'Test User',
          'email': 'test@example.com',
          'age': '25',
        };

        final configs = {
          'name': const InputValidationConfig(
            displayName: 'Name',
            maxLength: 50,
            allowSpecialChars: false,
          ),
          'email': const InputValidationConfig(
            displayName: 'Email',
            maxLength: 254,
            allowSpecialChars: true,
          ),
          'age': const InputValidationConfig(
            displayName: 'Age',
            maxLength: 3,
            allowSpecialChars: false,
          ),
        };

        final result = InputValidationService.validateMultipleInputs(
          inputs,
          configs,
        );
        expect(result.isSuccess, true);
        expect(result.data!['name'], 'Test User');
        expect(result.data!['email'], 'test@example.com');
        expect(result.data!['age'], '25');
      });

      test('하나의 입력이 무효한 경우', () {
        final inputs = {
          'name': 'Test User',
          'email': '<script>alert(1)</script>',
          'age': '25',
        };

        final configs = {
          'name': const InputValidationConfig(
            displayName: 'Name',
            maxLength: 50,
          ),
          'email': const InputValidationConfig(
            displayName: 'Email',
            maxLength: 254,
          ),
          'age': const InputValidationConfig(displayName: 'Age', maxLength: 3),
        };

        final result = InputValidationService.validateMultipleInputs(
          inputs,
          configs,
        );
        expect(result.isSuccess, false);
        expect(result.message, contains('Email'));
      });
    });

    group('에지 케이스', () {
      test('null 입력', () {
        final result = InputValidationService.validateUserInput(
          null,
          fieldName: 'Test Field',
          isRequired: true,
        );
        expect(result.isSuccess, false);
      });

      test('빈 문자열', () {
        final result = InputValidationService.validateUserInput(
          '',
          fieldName: 'Test Field',
          isRequired: true,
        );
        expect(result.isSuccess, false);
      });

      test('공백만 있는 문자열', () {
        final result = InputValidationService.validateUserInput(
          '   ',
          fieldName: 'Test Field',
          isRequired: true,
        );
        expect(result.isSuccess, false);
      });

      test('매우 긴 입력', () {
        final longInput = 'a' * 10000;
        final result = InputValidationService.validateUserInput(
          longInput,
          fieldName: 'Test Field',
          maxLength: 100,
        );
        expect(result.isSuccess, false);
      });
    });
  });
}
