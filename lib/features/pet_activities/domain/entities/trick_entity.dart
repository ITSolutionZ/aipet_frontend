/// 펫 트릭 엔티티
class TrickEntity {
  final String id;
  final String name;
  final String description;
  final String category;
  final DifficultyLevel difficulty;
  final int estimatedTime; // 예상 학습 시간 (분)
  final List<String> steps;
  final List<String> tips;
  final String? imageUrl;
  final String? videoUrl;
  final bool isLearned;
  final DateTime? learnedAt;
  final int practiceCount;
  final TrickStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrickEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedTime,
    this.steps = const [],
    this.tips = const [],
    this.imageUrl,
    this.videoUrl,
    this.isLearned = false,
    this.learnedAt,
    this.practiceCount = 0,
    this.status = TrickStatus.available,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 트릭이 학습 가능한지 확인
  bool get isAvailable => status == TrickStatus.available;

  /// 트릭이 학습 중인지 확인
  bool get isLearning => status == TrickStatus.learning;

  /// 트릭이 완료된지 확인
  bool get isCompleted => status == TrickStatus.completed;

  /// 학습 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (isCompleted) return 1.0;
    if (practiceCount == 0) return 0.0;

    // 난이도에 따른 필요 연습 횟수
    final requiredPractice = _getRequiredPracticeCount();
    return (practiceCount / requiredPractice).clamp(0.0, 1.0);
  }

  /// 난이도별 필요 연습 횟수
  int _getRequiredPracticeCount() {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 3;
      case DifficultyLevel.medium:
        return 5;
      case DifficultyLevel.hard:
        return 8;
      case DifficultyLevel.expert:
        return 12;
    }
  }

  /// 트릭 복사
  TrickEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    DifficultyLevel? difficulty,
    int? estimatedTime,
    List<String>? steps,
    List<String>? tips,
    String? imageUrl,
    String? videoUrl,
    bool? isLearned,
    DateTime? learnedAt,
    int? practiceCount,
    TrickStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrickEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      steps: steps ?? this.steps,
      tips: tips ?? this.tips,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isLearned: isLearned ?? this.isLearned,
      learnedAt: learnedAt ?? this.learnedAt,
      practiceCount: practiceCount ?? this.practiceCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrickEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TrickEntity(id: $id, name: $name, difficulty: $difficulty, status: $status)';
  }
}

/// 트릭 난이도 열거형
enum DifficultyLevel {
  easy, // 쉬움
  medium, // 보통
  hard, // 어려움
  expert, // 전문가
}

/// 트릭 상태 열거형
enum TrickStatus {
  available, // 학습 가능
  learning, // 학습 중
  completed, // 완료
  locked, // 잠김
}
