import 'result.dart';

/// Repository 기본 인터페이스
abstract class BaseRepository<T, ID> {
  Future<Result<List<T>>> getAll();
  Future<Result<T?>> getById(ID id);
  Future<Result<T>> create(T entity);
  Future<Result<T>> update(T entity);
  Future<Result<void>> delete(ID id);
}

/// Repository 구현을 위한 믹스인
mixin RepositoryMixin<T, ID> {
  /// 공통 에러 처리
  Result<R> handleError<R>(dynamic error, String operation) {
    final errorMessage = _getErrorMessage(error, operation);
    return Result.failure(errorMessage, error is Exception ? error : Exception(error.toString()));
  }

  /// 에러 메시지 생성
  String _getErrorMessage(dynamic error, String operation) {
    if (error is Exception) {
      final errorMessage = error.toString();

      // 네트워크 관련 에러
      if (errorMessage.contains('SocketException') || errorMessage.contains('HandshakeException')) {
        return 'ネットワーク接続エラーが発生しました';
      }

      if (errorMessage.contains('TimeoutException')) {
        return 'タイムアウトが発生しました';
      }

      // HTTP 관련 에러
      if (errorMessage.contains('404')) {
        return 'データが見つかりませんでした';
      }

      if (errorMessage.contains('401')) {
        return '認証が必要です';
      }

      if (errorMessage.contains('403')) {
        return 'アクセスが拒否されました';
      }

      if (errorMessage.contains('500')) {
        return 'サーバーエラーが発生しました';
      }
    }

    return '$operationに失敗しました: ${error.toString()}';
  }

  /// 성공 결과 생성 헬퍼
  Result<T> success<T>(String message, T data) {
    return Result.success(message, data);
  }

  /// 실패 결과 생성 헬퍼
  Result<T> failure<T>(String message, [Exception? error]) {
    return Result.failure(message, error);
  }
}

/// 메모리 기반 Repository 구현을 위한 믹스인
mixin MemoryRepositoryMixin<T, ID> {
  final List<T> _items = [];
  bool _isInitialized = false;

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;

  /// 초기화 완료 표시
  void markAsInitialized() {
    _isInitialized = true;
  }

  /// 데이터 초기화
  void clearData() {
    _items.clear();
    _isInitialized = false;
  }

  /// 리소스 정리
  void dispose() {
    clearData();
  }

  /// 모든 아이템 반환
  List<T> get allItems => List.unmodifiable(_items);

  /// ID로 아이템 찾기
  T? findById(ID id) {
    try {
      return _items.firstWhere((item) => _getId(item) == id);
    } catch (e) {
      return null;
    }
  }

  /// ID 추출 메서드 (구현체에서 오버라이드)
  ID _getId(T item);

  /// 아이템 추가
  void addItem(T item) {
    _items.add(item);
  }

  /// 아이템 업데이트
  void updateItem(T item) {
    final index = _items.indexWhere((existing) => _getId(existing) == _getId(item));
    if (index != -1) {
      _items[index] = item;
    }
  }

  /// 아이템 삭제
  void removeItem(ID id) {
    _items.removeWhere((item) => _getId(item) == id);
  }

  /// 시뮬레이션 지연
  Future<void> simulateDelay([Duration? duration]) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 300));
  }
}

/// Mock 데이터를 사용하는 Repository 구현을 위한 믹스인
mixin MockDataRepositoryMixin<T> {
  /// Mock 데이터 로드 (구현체에서 오버라이드)
  List<T> loadMockData();

  /// Mock 데이터 초기화
  void initializeMockData() {
    // 구현체에서 오버라이드하여 Mock 데이터 로드
  }

  /// Mock 데이터 사용 여부 확인
  bool get isMockDataEnabled => true;
}
