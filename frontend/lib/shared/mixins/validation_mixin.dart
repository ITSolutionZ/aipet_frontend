/// 검증 로직 Mixin
///
/// 폼 필드의 검증 로직을 공통화합니다.
mixin ValidationMixin {
  /// 필수 필드 검증
  String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldNameを入力してください' : 'この項目は必須です';
    }
    return null;
  }

  /// 문자열 길이 검증
  String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null) return null;

    final trimmedValue = value.trim();

    if (minLength != null && trimmedValue.length < minLength) {
      return fieldName != null
          ? '$fieldNameは$minLength文字以上で入力してください'
          : '$minLength文字以上で入力してください';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return fieldName != null
          ? '$fieldNameは$maxLength文字以下で入力してください'
          : '$maxLength文字以下で入力してください';
    }

    return null;
  }

  /// 이메일 형식 검증
  String? validateEmail(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return fieldName != null
          ? '$fieldNameの形式が正しくありません'
          : 'メールアドレスの形式が正しくありません';
    }
    return null;
  }

  /// 전화번호 형식 검증
  String? validatePhoneNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return null;

    // 일본 전화번호 형식 (예시)
    final phoneRegex = RegExp(r'^(\+81|0)[0-9]{1,4}[0-9]{1,4}[0-9]{4}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll('-', ''))) {
      return fieldName != null ? '$fieldNameの形式が正しくありません' : '電話番号の形式が正しくありません';
    }
    return null;
  }

  /// 숫자 범위 검증
  String? validateNumberRange(
    String? value, {
    double? min,
    double? max,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) return null;

    final number = double.tryParse(value.trim());
    if (number == null) {
      return fieldName != null ? '$fieldNameは数値で入力してください' : '数値で入力してください';
    }

    if (min != null && number < min) {
      return fieldName != null
          ? '$fieldNameは$min以上で入力してください'
          : '$min以上の数値を入力してください';
    }

    if (max != null && number > max) {
      return fieldName != null
          ? '$fieldNameは$max以下で入力してください'
          : '$max以下の数値を入力してください';
    }

    return null;
  }

  /// 날짜 형식 검증
  String? validateDate(
    String? value, {
    String? fieldName,
    String? format = 'yyyy-MM-dd',
  }) {
    if (value == null || value.trim().isEmpty) return null;

    try {
      // 간단한 날짜 형식 검증
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(value.trim())) {
        return fieldName != null
            ? '$fieldNameの形式が正しくありません (YYYY-MM-DD)'
            : '日付の形式が正しくありません (YYYY-MM-DD)';
      }

      // 실제 날짜 유효성 검사
      final parts = value.trim().split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return fieldName != null
            ? '$fieldNameは有効な日付を入力してください'
            : '有効な日付を入力してください';
      }

      return null;
    } catch (e) {
      return fieldName != null ? '$fieldNameの形式が正しくありません' : '日付の形式が正しくありません';
    }
  }

  /// 비밀번호 강도 검증
  String? validatePasswordStrength(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return null;

    final password = value.trim();

    if (password.length < 8) {
      return fieldName != null
          ? '$fieldNameは8文字以上で入力してください'
          : 'パスワードは8文字以上で入力してください';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return fieldName != null
          ? '$fieldNameには大文字を含めてください'
          : 'パスワードには大文字を含めてください';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return fieldName != null
          ? '$fieldNameには小文字を含めてください'
          : 'パスワードには小文字を含めてください';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return fieldName != null ? '$fieldNameには数字を含めてください' : 'パスワードには数字を含めてください';
    }

    return null;
  }

  /// 비밀번호 확인 검증
  String? validatePasswordConfirm(
    String? value,
    String? password, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) return null;

    if (value.trim() != password?.trim()) {
      return fieldName != null ? '$fieldNameが一致しません' : 'パスワードが一致しません';
    }

    return null;
  }

  /// URL 형식 검증
  String? validateUrl(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return null;

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return fieldName != null ? '$fieldNameの形式が正しくありません' : 'URLの形式が正しくありません';
    }

    return null;
  }

  /// 일본어 문자 검증
  String? validateJapanese(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return null;

    final japaneseRegex = RegExp(
      r'^[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF\s]+$',
    );
    if (!japaneseRegex.hasMatch(value.trim())) {
      return fieldName != null ? '$fieldNameは日本語で入力してください' : '日本語で入力してください';
    }

    return null;
  }

  /// 영숫자 검증
  String? validateAlphanumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) return null;

    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumericRegex.hasMatch(value.trim())) {
      return fieldName != null ? '$fieldNameは英数字で入力してください' : '英数字で入力してください';
    }

    return null;
  }

  /// 커스텀 정규식 검증
  String? validateRegex(
    String? value,
    RegExp regex, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.trim().isEmpty) return null;

    if (!regex.hasMatch(value.trim())) {
      return errorMessage ??
          (fieldName != null ? '$fieldNameの形式が正しくありません' : '入力形式が正しくありません');
    }

    return null;
  }

  /// 복합 검증 (여러 검증을 순차적으로 실행)
  String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// 펫 이름 검증
  String? validatePetName(String? value) {
    return validateMultiple(value, [
      (v) => validateRequired(v, fieldName: 'ペットの名前'),
      (v) =>
          validateLength(v, minLength: 2, maxLength: 10, fieldName: 'ペットの名前'),
    ]);
  }

  /// 펫 체중 검증
  String? validatePetWeight(String? value) {
    return validateMultiple(value, [
      (v) => validateRequired(v, fieldName: '体重'),
      (v) => validateNumberRange(v, min: 0.1, max: 100.0, fieldName: '体重'),
    ]);
  }

  /// 펫 체온 검증
  String? validatePetTemperature(String? value) {
    return validateMultiple(value, [
      (v) => validateRequired(v, fieldName: '体温'),
      (v) => validateNumberRange(v, min: 35.0, max: 42.0, fieldName: '体温'),
    ]);
  }

  /// 날짜 선택 검증
  String? validateDateSelection(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return fieldName != null ? '$fieldNameを選択してください' : '日付を選択してください';
    }

    if (date.isAfter(DateTime.now())) {
      return fieldName != null ? '$fieldNameは未来の日付を選択できません' : '未来の日付を選択できません';
    }

    return null;
  }

  /// 선택 옵션 검증
  String? validateSelection(dynamic value, {String? fieldName}) {
    if (value == null || (value is String && value.isEmpty)) {
      return fieldName != null ? '$fieldNameを選択してください' : '選択してください';
    }
    return null;
  }

  /// 다중 선택 검증
  String? validateMultipleSelection(List<dynamic> values, {String? fieldName}) {
    if (values.isEmpty) {
      return fieldName != null ? '$fieldNameを選択してください' : '選択してください';
    }
    return null;
  }
}
