import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'common_providers.g.dart';

/// 공통 상태 관리 패턴들
///
/// 모든 feature에서 공통으로 사용되는 Provider 패턴들을 제공합니다.

/// 기본 상태 데이터 클래스
abstract class BaseState {
  const BaseState();

  /// 상태 복사
  BaseState copyWith();
}

/// 로딩 상태가 포함된 기본 상태
abstract class BaseLoadingState extends BaseState {
  const BaseLoadingState();

  /// 로딩 중 여부
  bool get isLoading;

  /// 에러 메시지
  String? get error;

  /// 성공 여부
  bool get isSuccess;
}

/// 리스트 상태 관리 기본 클래스
abstract class BaseListState<T> extends BaseLoadingState {
  const BaseListState();

  /// 리스트 데이터
  List<T> get items;

  /// 선택된 항목
  T? get selectedItem;

  /// 선택된 항목 인덱스
  int? get selectedIndex;
}

/// 페이징 상태 관리 기본 클래스
abstract class BasePaginationState<T> extends BaseListState<T> {
  const BasePaginationState();

  /// 현재 페이지
  int get currentPage;

  /// 총 페이지 수
  int get totalPages;

  /// 다음 페이지 존재 여부
  bool get hasNextPage;

  /// 이전 페이지 존재 여부
  bool get hasPreviousPage;
}

/// 폼 상태 관리 기본 클래스
abstract class BaseFormState extends BaseLoadingState {
  const BaseFormState();

  /// 폼 유효성 검사 결과
  Map<String, String> get validationErrors;

  /// 폼 제출 가능 여부
  bool get canSubmit;

  /// 폼 초기화 여부
  bool get isInitialized;
}

/// 선택 상태 관리 기본 클래스
abstract class BaseSelectionState<T> extends BaseState {
  const BaseSelectionState();

  /// 선택된 항목들
  List<T> get selectedItems;

  /// 다중 선택 여부
  bool get isMultiSelect;

  /// 선택 가능한 최대 개수
  int? get maxSelection;
}

/// 공통 리스트 상태 데이터
class CommonListState<T> extends BaseListState<T> {
  @override
  final List<T> items;
  @override
  final T? selectedItem;
  @override
  final int? selectedIndex;
  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final bool isSuccess;

  const CommonListState({
    this.items = const [],
    this.selectedItem,
    this.selectedIndex,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  @override
  CommonListState<T> copyWith({
    List<T>? items,
    T? selectedItem,
    int? selectedIndex,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CommonListState<T>(
      items: items ?? this.items,
      selectedItem: selectedItem ?? this.selectedItem,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// 공통 폼 상태 데이터
class CommonFormState extends BaseFormState {
  @override
  final Map<String, String> validationErrors;
  @override
  final bool canSubmit;
  @override
  final bool isInitialized;
  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  final bool isSuccess;

  const CommonFormState({
    this.validationErrors = const {},
    this.canSubmit = false,
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  @override
  CommonFormState copyWith({
    Map<String, String>? validationErrors,
    bool? canSubmit,
    bool? isInitialized,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CommonFormState(
      validationErrors: validationErrors ?? this.validationErrors,
      canSubmit: canSubmit ?? this.canSubmit,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// 공통 선택 상태 데이터
class CommonSelectionState<T> extends BaseSelectionState<T> {
  @override
  final List<T> selectedItems;
  @override
  final bool isMultiSelect;
  @override
  final int? maxSelection;

  const CommonSelectionState({
    this.selectedItems = const [],
    this.isMultiSelect = false,
    this.maxSelection,
  });

  @override
  CommonSelectionState<T> copyWith({
    List<T>? selectedItems,
    bool? isMultiSelect,
    int? maxSelection,
  }) {
    return CommonSelectionState<T>(
      selectedItems: selectedItems ?? this.selectedItems,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      maxSelection: maxSelection ?? this.maxSelection,
    );
  }
}

/// 공통 리스트 상태 관리 Provider
@riverpod
class CommonListNotifier extends _$CommonListNotifier {
  @override
  CommonListState<dynamic> build() {
    return const CommonListState<dynamic>();
  }

  /// 리스트 설정
  void setItems(List<dynamic> items) {
    state = state.copyWith(items: items, isLoading: false, error: null, isSuccess: true);
  }

  /// 항목 추가
  void addItem(dynamic item) {
    state = state.copyWith(items: [...state.items, item], isSuccess: true);
  }

  /// 항목 업데이트
  void updateItem(dynamic item, int index) {
    if (index >= 0 && index < state.items.length) {
      final newItems = List<dynamic>.from(state.items);
      newItems[index] = item;
      state = state.copyWith(items: newItems);
    }
  }

  /// 항목 삭제
  void removeItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final newItems = List<dynamic>.from(state.items);
      newItems.removeAt(index);
      state = state.copyWith(items: newItems);
    }
  }

  /// 항목 선택
  void selectItem(dynamic item, int index) {
    state = state.copyWith(selectedItem: item, selectedIndex: index);
  }

  /// 선택 해제
  void clearSelection() {
    state = state.copyWith(selectedItem: null, selectedIndex: null);
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 에러 설정
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false, isSuccess: false);
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 공통 폼 상태 관리 Provider
@riverpod
class CommonFormNotifier extends _$CommonFormNotifier {
  @override
  CommonFormState build() {
    return const CommonFormState();
  }

  /// 폼 초기화
  void initialize() {
    state = state.copyWith(
      isInitialized: true,
      validationErrors: {},
      canSubmit: false,
      error: null,
      isSuccess: false,
    );
  }

  /// 유효성 검사 에러 설정
  void setValidationError(String field, String error) {
    final newErrors = Map<String, String>.from(state.validationErrors);
    newErrors[field] = error;
    state = state.copyWith(validationErrors: newErrors, canSubmit: false);
  }

  /// 유효성 검사 에러 제거
  void clearValidationError(String field) {
    final newErrors = Map<String, String>.from(state.validationErrors);
    newErrors.remove(field);
    state = state.copyWith(validationErrors: newErrors, canSubmit: newErrors.isEmpty);
  }

  /// 모든 유효성 검사 에러 제거
  void clearAllValidationErrors() {
    state = state.copyWith(validationErrors: {}, canSubmit: true);
  }

  /// 폼 제출 가능 상태 설정
  void setCanSubmit(bool canSubmit) {
    state = state.copyWith(canSubmit: canSubmit);
  }

  /// 로딩 상태 설정
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// 에러 설정
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false, isSuccess: false);
  }

  /// 성공 상태 설정
  void setSuccess() {
    state = state.copyWith(isSuccess: true, isLoading: false, error: null);
  }

  /// 폼 리셋
  void reset() {
    state = const CommonFormState();
  }
}

/// 공통 선택 상태 관리 Provider
@riverpod
class CommonSelectionNotifier extends _$CommonSelectionNotifier {
  @override
  CommonSelectionState<dynamic> build() {
    return const CommonSelectionState<dynamic>();
  }

  /// 항목 선택
  void selectItem(dynamic item) {
    if (state.isMultiSelect) {
      if (state.selectedItems.contains(item)) {
        // 이미 선택된 항목이면 선택 해제
        final newItems = List<dynamic>.from(state.selectedItems);
        newItems.remove(item);
        state = state.copyWith(selectedItems: newItems);
      } else {
        // 최대 선택 개수 확인
        if (state.maxSelection == null || state.selectedItems.length < state.maxSelection!) {
          final newItems = [...state.selectedItems, item];
          state = state.copyWith(selectedItems: newItems);
        }
      }
    } else {
      // 단일 선택
      state = state.copyWith(selectedItems: [item]);
    }
  }

  /// 항목 선택 해제
  void deselectItem(dynamic item) {
    final newItems = List<dynamic>.from(state.selectedItems);
    newItems.remove(item);
    state = state.copyWith(selectedItems: newItems);
  }

  /// 모든 선택 해제
  void clearSelection() {
    state = state.copyWith(selectedItems: []);
  }

  /// 다중 선택 모드 설정
  void setMultiSelect(bool isMultiSelect) {
    state = state.copyWith(
      isMultiSelect: isMultiSelect,
      selectedItems: isMultiSelect ? state.selectedItems : [],
    );
  }

  /// 최대 선택 개수 설정
  void setMaxSelection(int? maxSelection) {
    state = state.copyWith(maxSelection: maxSelection);
  }
}

/// 공통 Provider 팩토리
class CommonProviderFactory {
  /// 리스트 상태 Provider 생성
  static AutoDisposeNotifierProvider<CommonListNotifier, CommonListState<dynamic>>
  createListProvider() {
    return commonListNotifierProvider;
  }

  /// 폼 상태 Provider 생성
  static AutoDisposeNotifierProvider<CommonFormNotifier, CommonFormState> createFormProvider() {
    return commonFormNotifierProvider;
  }

  /// 선택 상태 Provider 생성
  static AutoDisposeNotifierProvider<CommonSelectionNotifier, CommonSelectionState<dynamic>>
  createSelectionProvider() {
    return commonSelectionNotifierProvider;
  }
}
