/// 표준화된 로딩 상태 관리 클래스
class LoadingState {
  final bool isLoading;
  final String? loadingMessage;
  final String? error;
  final DateTime? lastUpdated;

  const LoadingState({
    this.isLoading = false,
    this.loadingMessage,
    this.error,
    this.lastUpdated,
  });

  /// 초기 상태 (로딩 중이 아님)
  factory LoadingState.initial() {
    return const LoadingState();
  }

  /// 로딩 시작 상태
  factory LoadingState.loading([String? message]) {
    return LoadingState(
      isLoading: true,
      loadingMessage: message,
      lastUpdated: DateTime.now(),
    );
  }

  /// 로딩 완료 상태
  factory LoadingState.success() {
    return LoadingState(isLoading: false, lastUpdated: DateTime.now());
  }

  /// 에러 상태
  factory LoadingState.error(String error) {
    return LoadingState(
      isLoading: false,
      error: error,
      lastUpdated: DateTime.now(),
    );
  }

  /// 복사본 생성
  LoadingState copyWith({
    bool? isLoading,
    String? loadingMessage,
    String? error,
    DateTime? lastUpdated,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 로딩 중인지 확인
  bool get isNotLoading => !isLoading;

  /// 에러가 있는지 확인
  bool get hasError => error != null;

  /// 성공 상태인지 확인 (로딩 중이 아니고 에러도 없음)
  bool get isSuccess => !isLoading && error == null;

  /// 마지막 업데이트로부터 경과 시간 (초)
  int get secondsSinceLastUpdate {
    if (lastUpdated == null) return 0;
    return DateTime.now().difference(lastUpdated!).inSeconds;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          loadingMessage == other.loadingMessage &&
          error == other.error &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      loadingMessage.hashCode ^
      error.hashCode ^
      lastUpdated.hashCode;

  @override
  String toString() {
    return 'LoadingState(isLoading: $isLoading, loadingMessage: $loadingMessage, error: $error, lastUpdated: $lastUpdated)';
  }
}

/// 로딩 상태를 관리하는 믹스인
mixin LoadingStateMixin {
  LoadingState _loadingState = LoadingState.initial();

  /// 현재 로딩 상태
  LoadingState get loadingState => _loadingState;

  /// 로딩 중인지 확인
  bool get isLoading => _loadingState.isLoading;

  /// 에러가 있는지 확인
  bool get hasError => _loadingState.hasError;

  /// 성공 상태인지 확인
  bool get isSuccess => _loadingState.isSuccess;

  /// 로딩 메시지
  String? get loadingMessage => _loadingState.loadingMessage;

  /// 에러 메시지
  String? get error => _loadingState.error;

  /// 로딩 시작
  void startLoading([String? message]) {
    _loadingState = LoadingState.loading(message);
  }

  /// 로딩 완료
  void finishLoading() {
    _loadingState = LoadingState.success();
  }

  /// 에러 설정
  void setError(String error) {
    _loadingState = LoadingState.error(error);
  }

  /// 로딩 상태 업데이트
  void updateLoadingState(LoadingState newState) {
    _loadingState = newState;
  }

  /// 로딩 상태 초기화
  void resetLoadingState() {
    _loadingState = LoadingState.initial();
  }

  /// 안전한 비동기 작업 실행
  Future<T?> executeWithLoading<T>(
    Future<T> Function() action, {
    String? loadingMessage,
  }) async {
    try {
      startLoading(loadingMessage);
      final result = await action();
      finishLoading();
      return result;
    } catch (error) {
      setError(error.toString());
      return null;
    }
  }
}

/// 로딩 상태 리스너
abstract class LoadingStateListener {
  void onLoadingStarted(String? message);
  void onLoadingFinished();
  void onError(String error);
  void onStateChanged(LoadingState state);
}

/// 로딩 상태 관리자
class LoadingStateManager {
  final List<LoadingStateListener> _listeners = [];
  LoadingState _currentState = LoadingState.initial();

  /// 현재 상태
  LoadingState get currentState => _currentState;

  /// 리스너 추가
  void addListener(LoadingStateListener listener) {
    _listeners.add(listener);
  }

  /// 리스너 제거
  void removeListener(LoadingStateListener listener) {
    _listeners.remove(listener);
  }

  /// 로딩 시작
  void startLoading([String? message]) {
    _currentState = LoadingState.loading(message);
    _notifyListeners();
  }

  /// 로딩 완료
  void finishLoading() {
    _currentState = LoadingState.success();
    _notifyListeners();
  }

  /// 에러 설정
  void setError(String error) {
    _currentState = LoadingState.error(error);
    _notifyListeners();
  }

  /// 상태 업데이트
  void updateState(LoadingState newState) {
    _currentState = newState;
    _notifyListeners();
  }

  /// 리스너들에게 알림
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener.onStateChanged(_currentState);

      if (_currentState.isLoading) {
        listener.onLoadingStarted(_currentState.loadingMessage);
      } else if (_currentState.hasError) {
        listener.onError(_currentState.error!);
      } else {
        listener.onLoadingFinished();
      }
    }
  }
}
