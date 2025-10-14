import 'package:aipet_frontend/features/pet_activities/data/services/pet_activities_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart';

/// 트릭 리포지토리 헬퍼
class TrickRepositoryHelper {
  /// 모든 트릭 가져오기
  static Future<List<TrickEntity>> getAllTricks() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final tricksData = await PetActivitiesLocalStorageService.getTricks();

    return tricksData.map((trickData) {
      // 난이도 매핑
      DifficultyLevel difficulty;
      final difficultyStr = trickData['difficulty'] as String? ?? 'easy';
      switch (difficultyStr.toLowerCase()) {
        case 'hard':
          difficulty = DifficultyLevel.hard;
          break;
        case 'medium':
          difficulty = DifficultyLevel.medium;
          break;
        case 'expert':
          difficulty = DifficultyLevel.expert;
          break;
        default:
          difficulty = DifficultyLevel.easy;
      }

      return TrickEntity(
        id: trickData['id'] as String,
        name: trickData['name'] as String,
        description: trickData['description'] as String? ?? '',
        category: trickData['category'] as String? ?? 'General',
        difficulty: difficulty,
        estimatedTime: trickData['estimatedTime'] as int? ?? 30,
        imageUrl: trickData['imagePath'] as String?,
        imagePath: trickData['imagePath'] as String?,
        videoUrl: trickData['videoUrl'] as String?,
        isLearned: trickData['isCompleted'] as bool? ?? false,
        learnedAt: trickData['completedAt'] != null
            ? DateTime.parse(trickData['completedAt'] as String)
            : null,
        practiceCount: trickData['progress'] as int? ?? 0,
        status: (trickData['isCompleted'] as bool?) == true
            ? TrickStatus.completed
            : TrickStatus.available,
        createdAt: DateTime.parse(trickData['createdAt'] as String),
        updatedAt: trickData['updatedAt'] != null
            ? DateTime.parse(trickData['updatedAt'] as String)
            : DateTime.parse(trickData['createdAt'] as String),
      );
    }).toList();
  }

  /// 특정 펫의 트릭 가져오기
  static Future<List<TrickEntity>> getTricksByPetId(String petId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tricksData = await PetActivitiesLocalStorageService.getTricks(
      petId: petId,
    );

    return tricksData
        .map((trickData) => _mapTrickDataToEntity(trickData))
        .toList();
  }

  /// 트릭 추가
  static Future<void> addTrick(TrickEntity trick) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final trickData = {
      'id': trick.id,
      'name': trick.name,
      'description': trick.description,
      'category': trick.category,
      'difficulty': trick.difficulty.name,
      'estimatedTime': trick.estimatedTime,
      'imagePath': trick.imagePath,
      'videoUrl': trick.videoUrl,
      'isCompleted': trick.isLearned,
      'completedAt': trick.learnedAt?.toIso8601String(),
      'progress': trick.practiceCount,
      'petId': 'default', // 기본값
      'createdAt': trick.createdAt.toIso8601String(),
      'updatedAt': trick.updatedAt.toIso8601String(),
    };

    await PetActivitiesLocalStorageService.addTrick(trickData);
  }

  /// 트릭 업데이트
  static Future<void> updateTrick(String trickId, TrickEntity updates) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final updateData = {
      'id': trickId,
      'name': updates.name,
      'description': updates.description,
      'category': updates.category,
      'difficulty': updates.difficulty.name,
      'estimatedTime': updates.estimatedTime,
      'imagePath': updates.imagePath,
      'videoUrl': updates.videoUrl,
      'isCompleted': updates.isLearned,
      'completedAt': updates.learnedAt?.toIso8601String(),
      'progress': updates.practiceCount,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await PetActivitiesLocalStorageService.updateTrick(trickId, updateData);
  }

  /// 트릭 삭제
  static Future<void> deleteTrick(String trickId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await PetActivitiesLocalStorageService.deleteTrick(trickId);
  }

  /// 트릭 검색
  static Future<List<TrickEntity>> searchTricks(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final tricksData = await PetActivitiesLocalStorageService.searchTricks(
      query,
    );
    return tricksData
        .map((trickData) => _mapTrickDataToEntity(trickData))
        .toList();
  }

  /// 트릭 통계
  static Future<Map<String, int>> getTrickStats({String? petId}) async {
    return PetActivitiesLocalStorageService.getTrickStats(petId: petId);
  }

  /// 트릭 데이터를 엔티티로 매핑
  static TrickEntity _mapTrickDataToEntity(Map<String, dynamic> trickData) {
    // 난이도 매핑
    DifficultyLevel difficulty;
    final difficultyStr = trickData['difficulty'] as String? ?? 'easy';
    switch (difficultyStr.toLowerCase()) {
      case 'hard':
        difficulty = DifficultyLevel.hard;
        break;
      case 'medium':
        difficulty = DifficultyLevel.medium;
        break;
      case 'expert':
        difficulty = DifficultyLevel.expert;
        break;
      default:
        difficulty = DifficultyLevel.easy;
    }

    return TrickEntity(
      id: trickData['id'] as String,
      name: trickData['name'] as String,
      description: trickData['description'] as String? ?? '',
      category: trickData['category'] as String? ?? 'General',
      difficulty: difficulty,
      estimatedTime: trickData['estimatedTime'] as int? ?? 30,
      imageUrl: trickData['imagePath'] as String?,
      imagePath: trickData['imagePath'] as String?,
      videoUrl: trickData['videoUrl'] as String?,
      isLearned: trickData['isCompleted'] as bool? ?? false,
      learnedAt: trickData['completedAt'] != null
          ? DateTime.parse(trickData['completedAt'] as String)
          : null,
      practiceCount: trickData['progress'] as int? ?? 0,
      status: (trickData['isCompleted'] as bool?) == true
          ? TrickStatus.completed
          : TrickStatus.available,
      createdAt: DateTime.parse(trickData['createdAt'] as String),
      updatedAt: trickData['updatedAt'] != null
          ? DateTime.parse(trickData['updatedAt'] as String)
          : DateTime.parse(trickData['createdAt'] as String),
    );
  }
}
