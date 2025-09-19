/// 펫 액티비티 Mock 서비스
///
/// 펫 액티비티 관련 Mock 데이터를 제공합니다.
class PetActivitiesMockService {
  /// Mock 트릭 데이터 반환
  static List<Map<String, dynamic>> getMockTricks() {
    return [
      {
        'id': 'trick-1',
        'name': 'お手',
        'petId': 'pet-1',
        'progress': 100,
        'imagePath': 'assets/images/activities/trick_hand.png',
        'isCompleted': true,
        'difficulty': 'easy',
        'videoUrl': 'https://youtube.com/watch?v=example1',
        'description': '基本的なトリックです',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'completedAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': 'trick-2',
        'name': 'お座り',
        'petId': 'pet-1',
        'progress': 75,
        'imagePath': 'assets/images/activities/trick_sit.png',
        'isCompleted': false,
        'difficulty': 'easy',
        'videoUrl': 'https://youtube.com/watch?v=example2',
        'description': '座ることを教えるトリック',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'completedAt': null,
      },
      {
        'id': 'trick-3',
        'name': '伏せ',
        'petId': 'pet-1',
        'progress': null,
        'imagePath': 'assets/images/activities/trick_down.png',
        'isCompleted': false,
        'difficulty': 'medium',
        'videoUrl': null,
        'description': '伏せることを教えるトリック',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'completedAt': null,
      },
    ];
  }

  /// Mock 비디오 북마크 데이터 반환
  static List<Map<String, dynamic>> getMockVideoBookmarks() {
    return [
      {
        'id': 'bookmark-1',
        'videoId': 'video-1',
        'youtubeVideoId': 'dQw4w9WgXcQ',
        'positionSec': 120,
        'label': '重要なポイント',
        'description': 'ここから重要な説明が始まります',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'bookmark-2',
        'videoId': 'video-1',
        'youtubeVideoId': 'dQw4w9WgXcQ',
        'positionSec': 300,
        'label': '実践編',
        'description': '実際の練習方法の説明',
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
      },
    ];
  }

  /// Mock 비디오 진행도 데이터 반환
  static Map<String, Map<String, dynamic>> getMockVideoProgress() {
    return {
      'video-1': {
        'videoId': 'video-1',
        'lastPositionSec': 180,
        'updatedAt': DateTime.now().subtract(const Duration(minutes: 30)),
      },
      'video-2': {
        'videoId': 'video-2',
        'lastPositionSec': 450,
        'updatedAt': DateTime.now().subtract(const Duration(hours: 1)),
      },
    };
  }

  /// 기본 비디오 제목 반환
  static String getDefaultVideoTitle(String videoId) {
    return 'ペットのしつけ動画 - $videoId';
  }
}
