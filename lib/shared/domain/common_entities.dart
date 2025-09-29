/// 공통 엔티티들
///
/// 프로젝트 전반에서 사용되는 공통 엔티티들을 정의합니다.
library;

/// 펫 정보 엔티티
class PetInfo {
  final String id;
  final String name;
  final String type;
  final String? breed;
  final int age;
  final String? imageUrl;

  const PetInfo({
    required this.id,
    required this.name,
    required this.type,
    this.breed,
    required this.age,
    this.imageUrl,
  });

  PetInfo copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    int? age,
    String? imageUrl,
  }) {
    return PetInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// 산책 기록 엔티티
class WalkRecordEntity {
  final String id;
  final String petId;
  final DateTime startTime;
  final DateTime? endTime;
  final double? distance;
  final List<WalkLocation> route;
  final String? notes;

  const WalkRecordEntity({
    required this.id,
    required this.petId,
    required this.startTime,
    this.endTime,
    this.distance,
    required this.route,
    this.notes,
  });

  WalkRecordEntity copyWith({
    String? id,
    String? petId,
    DateTime? startTime,
    DateTime? endTime,
    double? distance,
    List<WalkLocation>? route,
    String? notes,
  }) {
    return WalkRecordEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distance: distance ?? this.distance,
      route: route ?? this.route,
      notes: notes ?? this.notes,
    );
  }
}

/// 산책 위치 엔티티
class WalkLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const WalkLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  WalkLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) {
    return WalkLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// 트릭 엔티티
class TrickEntity {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final List<String> steps;
  final String? videoUrl;
  final String? imageUrl;

  const TrickEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.steps,
    this.videoUrl,
    this.imageUrl,
  });

  TrickEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? difficulty,
    List<String>? steps,
    String? videoUrl,
    String? imageUrl,
  }) {
    return TrickEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      steps: steps ?? this.steps,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// 비디오 북마크 엔티티
class VideoBookmarkEntity {
  final String id;
  final String videoId;
  final int positionSec;
  final String title;
  final DateTime createdAt;

  const VideoBookmarkEntity({
    required this.id,
    required this.videoId,
    required this.positionSec,
    required this.title,
    required this.createdAt,
  });

  VideoBookmarkEntity copyWith({
    String? id,
    String? videoId,
    int? positionSec,
    String? title,
    DateTime? createdAt,
  }) {
    return VideoBookmarkEntity(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      positionSec: positionSec ?? this.positionSec,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 비디오 진행률 엔티티
class VideoProgressEntity {
  final String id;
  final String videoId;
  final int currentPosition;
  final int totalDuration;
  final bool isCompleted;
  final DateTime lastWatched;

  const VideoProgressEntity({
    required this.id,
    required this.videoId,
    required this.currentPosition,
    required this.totalDuration,
    required this.isCompleted,
    required this.lastWatched,
  });

  VideoProgressEntity copyWith({
    String? id,
    String? videoId,
    int? currentPosition,
    int? totalDuration,
    bool? isCompleted,
    DateTime? lastWatched,
  }) {
    return VideoProgressEntity(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWatched: lastWatched ?? this.lastWatched,
    );
  }
}
