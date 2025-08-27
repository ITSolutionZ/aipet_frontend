import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_provider.g.dart';

/// 앱 전체 상태 관리
@riverpod
class AppState extends _$AppState {
  @override
  AppStateData build() {
    return const AppStateData(
      isLoading: false,
      error: null,
      currentTime: null,
      isOnline: true,
      appVersion: '1.0.0',
      lastSyncTime: null,
    );
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 에러 상태 설정
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// 현재 시간 업데이트
  void updateCurrentTime() {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(currentTime: timeString);
  }

  /// 온라인 상태 설정
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  /// 앱 버전 설정
  void setAppVersion(String version) {
    state = state.copyWith(appVersion: version);
  }

  /// 마지막 동기화 시간 설정
  void setLastSyncTime(DateTime? syncTime) {
    state = state.copyWith(lastSyncTime: syncTime);
  }

  /// 앱 상태 초기화
  void reset() {
    state = const AppStateData(
      isLoading: false,
      error: null,
      currentTime: null,
      isOnline: true,
      appVersion: '1.0.0',
      lastSyncTime: null,
    );
  }
}

/// 앱 상태 데이터 클래스
class AppStateData {
  final bool isLoading;
  final String? error;
  final String? currentTime;
  final bool isOnline;
  final String appVersion;
  final DateTime? lastSyncTime;

  const AppStateData({
    required this.isLoading,
    this.error,
    this.currentTime,
    required this.isOnline,
    required this.appVersion,
    this.lastSyncTime,
  });

  AppStateData copyWith({
    bool? isLoading,
    String? error,
    String? currentTime,
    bool? isOnline,
    String? appVersion,
    DateTime? lastSyncTime,
  }) {
    return AppStateData(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentTime: currentTime ?? this.currentTime,
      isOnline: isOnline ?? this.isOnline,
      appVersion: appVersion ?? this.appVersion,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  /// 에러가 있는지 확인
  bool get hasError => error != null;

  /// 오프라인 상태인지 확인
  bool get isOffline => !isOnline;

  /// 마지막 동기화로부터 경과 시간 (분)
  int? get minutesSinceLastSync {
    if (lastSyncTime == null) return null;
    return DateTime.now().difference(lastSyncTime!).inMinutes;
  }
}

/// 네비게이션 상태 관리
@riverpod
class NavigationState extends _$NavigationState {
  @override
  NavigationStateData build() {
    return const NavigationStateData(
      selectedIndex: 0,
      previousIndex: 0,
      canGoBack: false,
    );
  }

  /// 선택된 탭 인덱스 설정
  void setSelectedIndex(int index) {
    final previousIndex = state.selectedIndex;
    state = state.copyWith(
      selectedIndex: index,
      previousIndex: previousIndex,
      canGoBack: previousIndex != index,
    );
  }

  /// 이전 탭으로 돌아가기
  void goBack() {
    if (state.canGoBack) {
      state = state.copyWith(
        selectedIndex: state.previousIndex,
        previousIndex: state.selectedIndex,
        canGoBack: false,
      );
    }
  }

  /// 네비게이션 상태 초기화
  void reset() {
    state = const NavigationStateData(
      selectedIndex: 0,
      previousIndex: 0,
      canGoBack: false,
    );
  }
}

/// 네비게이션 상태 데이터 클래스
class NavigationStateData {
  final int selectedIndex;
  final int previousIndex;
  final bool canGoBack;

  const NavigationStateData({
    required this.selectedIndex,
    required this.previousIndex,
    required this.canGoBack,
  });

  NavigationStateData copyWith({
    int? selectedIndex,
    int? previousIndex,
    bool? canGoBack,
  }) {
    return NavigationStateData(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      previousIndex: previousIndex ?? this.previousIndex,
      canGoBack: canGoBack ?? this.canGoBack,
    );
  }
}
