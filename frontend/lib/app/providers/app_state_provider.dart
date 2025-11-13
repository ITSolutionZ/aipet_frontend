import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_state_provider.g.dart';

/// 앱 전체 상태를 관리하는 Provider
///
/// 앱의 전역 상태를 관리하며, 로딩, 에러, 시간, 온라인 상태 등을 추적합니다.
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

  /// 로딩 상태를 설정합니다.
  ///
  /// [loading] 로딩 상태 여부
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// 에러 상태를 설정합니다.
  ///
  /// [error] 에러 메시지 (null이면 에러 없음)
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// 현재 시간을 업데이트합니다.
  ///
  /// 현재 시간을 HH:MM 형식으로 포맷하여 상태에 저장합니다.
  void updateCurrentTime() {
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(currentTime: timeString);
  }

  /// 온라인 상태를 설정합니다.
  ///
  /// [isOnline] 온라인 상태 여부
  void setOnlineStatus(bool isOnline) {
    state = state.copyWith(isOnline: isOnline);
  }

  /// 앱 버전을 설정합니다.
  ///
  /// [version] 설정할 앱 버전
  void setAppVersion(String version) {
    state = state.copyWith(appVersion: version);
  }

  /// 마지막 동기화 시간을 설정합니다.
  ///
  /// [syncTime] 마지막 동기화 시간 (null이면 동기화 기록 없음)
  void setLastSyncTime(DateTime? syncTime) {
    state = state.copyWith(lastSyncTime: syncTime);
  }

  /// 앱 상태를 초기화합니다.
  ///
  /// 모든 상태를 기본값으로 리셋합니다.
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
///
/// 앱의 전역 상태를 담는 불변 데이터 클래스입니다.
/// 모든 상태 변경은 copyWith 메서드를 통해 이루어집니다.
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
