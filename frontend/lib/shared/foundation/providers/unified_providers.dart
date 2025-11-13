import 'package:aipet_frontend/app/services/unified_error_handler.dart';
import 'package:aipet_frontend/shared/core/services/unified_validation_service.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_providers.g.dart';

/// 🎯 통합 프로바이더들
///
/// AI와 Auth 기능에서 공통으로 사용하는 프로바이더들을 정의합니다.

/// 통합 에러 핸들러 프로바이더
final unifiedErrorHandlerProvider = Provider<UnifiedErrorHandler>((ref) {
  return UnifiedErrorHandler();
});

/// 통합 유효성 검사 서비스 프로바이더
final unifiedValidationServiceProvider = Provider<UnifiedValidationService>((
  ref,
) {
  return UnifiedValidationService();
});

/// 공통 로깅 서비스 프로바이더 (싱글톤)
final baseLoggingServiceProvider = Provider<BaseLoggingService>((ref) {
  return _LoggingService('unified_service');
});

/// BaseLoggingService의 구체적인 구현체
class _LoggingService extends BaseLoggingService {
  _LoggingService(super.serviceName);
}

/// 공통 상태 관리 프로바이더
@riverpod
class UnifiedStateNotifierController extends _$UnifiedStateNotifierController {
  @override
  UnifiedState build() => const UnifiedState.initial();

  /// 로딩 상태 설정
  void setLoading() {
    state = const UnifiedState.loading();
  }

  /// 성공 상태 설정
  void setSuccess(String message) {
    state = UnifiedState.success(message);
  }

  /// 에러 상태 설정
  void setError(String error) {
    state = UnifiedState.error(error);
  }

  /// 초기 상태로 리셋
  void reset() {
    state = const UnifiedState.initial();
  }
}

/// 통합 상태 클래스
sealed class UnifiedState {
  const UnifiedState();

  const factory UnifiedState.initial() = _Initial;
  const factory UnifiedState.loading() = _Loading;
  const factory UnifiedState.success(String message) = _Success;
  const factory UnifiedState.error(String error) = _Error;

  bool get isLoading => this is _Loading;
  bool get isSuccess => this is _Success;
  bool get isError => this is _Error;
  bool get isInitial => this is _Initial;
}

class _Initial extends UnifiedState {
  const _Initial();
}

class _Loading extends UnifiedState {
  const _Loading();
}

class _Success extends UnifiedState {
  final String message;
  const _Success(this.message);
}

class _Error extends UnifiedState {
  final String error;
  const _Error(this.error);
}

/// 공통 폼 상태 프로바이더
@riverpod
class UnifiedFormNotifierController extends _$UnifiedFormNotifierController {
  @override
  UnifiedFormState build() => const UnifiedFormState();

  /// 필드 값 업데이트
  void updateField(String key, dynamic value) {
    final newFields = Map<String, dynamic>.from(state.fields);
    newFields[key] = value;
    state = state.copyWith(fields: newFields);
  }

  /// 에러 설정
  void setFieldError(String key, String error) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors[key] = error;
    state = state.copyWith(errors: newErrors);
  }

  /// 에러 초기화
  void clearFieldError(String key) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove(key);
    state = state.copyWith(errors: newErrors);
  }

  /// 모든 에러 초기화
  void clearAllErrors() {
    state = state.copyWith(errors: {});
  }

  /// 폼 리셋
  void resetForm() {
    state = const UnifiedFormState();
  }
}

/// 통합 폼 상태 클래스
class UnifiedFormState {
  final Map<String, dynamic> fields;
  final Map<String, String> errors;
  final bool isLoading;
  final String? error;

  const UnifiedFormState({
    this.fields = const {},
    this.errors = const {},
    this.isLoading = false,
    this.error,
  });

  UnifiedFormState copyWith({
    Map<String, dynamic>? fields,
    Map<String, String>? errors,
    bool? isLoading,
    String? error,
  }) {
    return UnifiedFormState(
      fields: fields ?? this.fields,
      errors: errors ?? this.errors,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// 특정 필드 값 가져오기
  dynamic getField(String key) => fields[key];

  /// 폼 유효성 검사
  bool get isValid => error == null && errors.isEmpty;
}
