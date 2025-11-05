import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';


/// 산책 관련 폼 필드 컴포넌트들
class WalkFormFields {
  WalkFormFields._();

  /// 산책 제목 필드
  static Widget buildTitleField({
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return CommonFormPatterns.buildTextField(
      controller: controller,
      label: '散歩のタイトル',
      hint: '例: 朝の散歩、公園散歩',
      initialValue: initialValue,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      validator: validator ?? _titleValidator,
      onChanged: onChanged,
      onSaved: onSaved,
      prefixIcon: const Icon(Icons.pets),
      maxLength: 50,
    );
  }

  /// 산책 거리 필드
  static Widget buildDistanceField({
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return CommonFormPatterns.buildNumberField(
      controller: controller,
      label: '距離 (km)',
      hint: '0.0',
      initialValue: initialValue,
      validator: validator ?? _distanceValidator,
      onChanged: onChanged,
      onSaved: onSaved,
      min: 0.0,
      max: 100.0,
      decimalPlaces: 2,
    );
  }

  /// 산책 시간 필드 (소요 시간 - 분 단위)
  static Widget buildDurationField({
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return CommonFormPatterns.buildNumberField(
      controller: controller,
      label: '散歩時間 (分)',
      hint: '30',
      initialValue: initialValue,
      validator: validator ?? _durationValidator,
      onChanged: onChanged,
      onSaved: onSaved,
      min: 1.0,
      max: 480.0, // 8시간
      decimalPlaces: 0,
    );
  }

  /// 산책 시작 시간 필드
  static Widget buildStartTimeField({
    TimeOfDay? initialValue,
    void Function(TimeOfDay?)? onChanged,
    void Function(TimeOfDay?)? onSaved,
    String? Function(TimeOfDay?)? validator,
  }) {
    return CommonFormPatterns.buildTimeField(
      label: '開始時間',
      initialValue: initialValue,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }

  /// 산책 날짜 필드
  static Widget buildDateField({
    DateTime? initialValue,
    void Function(DateTime?)? onChanged,
    void Function(DateTime?)? onSaved,
    String? Function(DateTime?)? validator,
  }) {
    return CommonFormPatterns.buildDateField(
      label: '散歩日',
      initialValue: initialValue,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }

  /// 메모 필드
  static Widget buildNotesField({
    String? initialValue,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return CommonFormPatterns.buildTextField(
      controller: controller,
      label: 'メモ',
      hint: '散歩の様子や特記事項を記録してください',
      initialValue: initialValue,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      prefixIcon: const Icon(Icons.note),
      maxLines: 3,
      maxLength: 500,
    );
  }

  /// 펫 선택 필드
  static Widget buildPetSelectionField<T>({
    required List<T> pets,
    required String Function(T) petNameBuilder,
    required String Function(T) petIdBuilder,
    T? selectedPet,
    void Function(T?)? onChanged,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
  }) {
    return CommonFormPatterns.buildDropdownField<T>(
      label: 'ペット選択',
      items: pets,
      itemBuilder: petNameBuilder,
      value: selectedPet,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator ?? _petSelectionValidator,
      prefixIcon: const Icon(Icons.pets),
    );
  }

  /// 산책 상태 필드
  static Widget buildStatusField<T>({
    required List<T> statusOptions,
    required String Function(T) statusNameBuilder,
    T? selectedStatus,
    void Function(T?)? onChanged,
    void Function(T?)? onSaved,
    String? Function(T?)? validator,
  }) {
    return CommonFormPatterns.buildDropdownField<T>(
      label: '散歩ステータス',
      items: statusOptions,
      itemBuilder: statusNameBuilder,
      value: selectedStatus,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      prefixIcon: const Icon(Icons.flag),
    );
  }

  /// 날씨 선택 필드
  static Widget buildWeatherField({
    required List<String> weatherOptions,
    String? selectedWeather,
    void Function(String?)? onChanged,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return CommonFormPatterns.buildDropdownField<String>(
      label: '天気',
      items: weatherOptions,
      itemBuilder: (weather) => weather,
      value: selectedWeather,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      prefixIcon: const Icon(Icons.wb_sunny),
    );
  }

  /// 공개 설정 필드
  static Widget buildPrivacyField({
    required bool isPublic,
    void Function(bool)? onChanged,
    void Function(bool?)? onSaved,
    String? Function(bool?)? validator,
  }) {
    return CommonFormPatterns.buildSwitchField(
      label: '散歩記録を公開する',
      subtitle: '他のユーザーがあなたの散歩記録を見ることができます',
      value: isPublic,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }

  /// GPS 추적 활성화 필드
  static Widget buildGpsTrackingField({
    required bool isEnabled,
    void Function(bool)? onChanged,
    void Function(bool?)? onSaved,
    String? Function(bool?)? validator,
  }) {
    return CommonFormPatterns.buildSwitchField(
      label: 'GPS追跡を有効にする',
      subtitle: 'リアルタイムで散歩ルートを記録します',
      value: isEnabled,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }

  /// 폼 검증 함수들
  static String? _titleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'タイトルは必須です';
    }
    if (value.trim().length < 2) {
      return 'タイトルは2文字以上で入力してください';
    }
    if (value.trim().length > 50) {
      return 'タイトルは50文字以下で入力してください';
    }
    return null;
  }

  static String? _distanceValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '距離は必須です';
    }
    final distance = double.tryParse(value);
    if (distance == null) {
      return '有効な数値を入力してください';
    }
    if (distance < 0) {
      return '距離は0以上で入力してください';
    }
    if (distance > 100) {
      return '距離は100km以下で入力してください';
    }
    return null;
  }

  static String? _durationValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '散歩時間は必須です';
    }
    final duration = int.tryParse(value);
    if (duration == null) {
      return '有効な数値を入力してください';
    }
    if (duration < 1) {
      return '散歩時間は1分以上で入力してください';
    }
    if (duration > 480) {
      return '散歩時間は8時間以下で入力してください';
    }
    return null;
  }

  static String? _petSelectionValidator<T>(T? value) {
    if (value == null) {
      return 'ペットを選択してください';
    }
    return null;
  }
}
