class OnboardingState {
  final int currentPage;
  final bool isCompleted;
  final int viewCount; // 온보딩 시청 횟수

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
    this.viewCount = 0,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
    int? viewCount,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  /// 1회 이상 온보딩을 본 사용자인지 확인
  bool get hasSeenOnboardingBefore => viewCount > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.currentPage == currentPage &&
        other.isCompleted == other.isCompleted &&
        other.viewCount == viewCount;
  }

  @override
  int get hashCode =>
      currentPage.hashCode ^ isCompleted.hashCode ^ viewCount.hashCode;
}
