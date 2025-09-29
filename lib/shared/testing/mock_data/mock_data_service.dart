/// Mock 데이터 서비스
///
/// 개발 및 테스트를 위한 Mock 데이터를 제공합니다.
class MockDataService {
  static bool isEnabled = true;

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

  /// Mock YouTube 비디오 정보 반환
  static Map<String, dynamic> getMockYouTubeVideoInfo(String videoId) {
    return {
      'title': 'ペットのしつけ動画 - $videoId',
      'description': 'ペットの基本的なしつけ方法を説明する動画です。',
      'duration': 600, // 10분
    };
  }

  /// 기본 비디오 제목 반환
  static String getDefaultVideoTitle(String videoId) {
    return 'ペットのしつけ動画 - $videoId';
  }

  /// Mock 펫 크기별 급식량 데이터 반환
  static List<Map<String, dynamic>> getMockPetSizesAndFeedingAmounts() {
    return [
      {
        'size': 'small',
        'minWeight': 1.0,
        'maxWeight': 10.0,
        'minAmount': 50.0,
        'maxAmount': 150.0,
        'recommendedAmount': 100.0,
      },
      {
        'size': 'medium',
        'minWeight': 10.0,
        'maxWeight': 25.0,
        'minAmount': 150.0,
        'maxAmount': 300.0,
        'recommendedAmount': 225.0,
      },
      {
        'size': 'large',
        'minWeight': 25.0,
        'maxWeight': 50.0,
        'minAmount': 300.0,
        'maxAmount': 500.0,
        'recommendedAmount': 400.0,
      },
    ];
  }

  /// 펫 크기별 급식 가이드 반환
  static Map<String, dynamic> getPetSizeFeedingGuide(String size) {
    final guides = {
      'small': {
        'size': 'small',
        'description': '小型犬の給餌ガイド',
        'feedingTimes': ['朝', '夕'],
        'amountPerMeal': 50.0,
        'notes': '小型犬は代謝が早いため、少量を頻繁に与えることが重要です。',
      },
      'medium': {
        'size': 'medium',
        'description': '中型犬の給餌ガイド',
        'feedingTimes': ['朝', '夕'],
        'amountPerMeal': 150.0,
        'notes': '中型犬は適度な運動とバランスの取れた食事が必要です。',
      },
      'large': {
        'size': 'large',
        'description': '大型犬の給餌ガイド',
        'feedingTimes': ['朝', '夕'],
        'amountPerMeal': 300.0,
        'notes': '大型犬は関節の健康に注意し、適切な量の食事を与えることが重要です。',
      },
    };
    return guides[size] ?? guides['medium']!;
  }

  /// 펫 현재 상태 반환
  static Map<String, dynamic> getPetCurrentStatus(String petId) {
    return {
      'petId': petId,
      'lastFeedingTime': DateTime.now().subtract(const Duration(hours: 6)),
      'nextFeedingTime': DateTime.now().add(const Duration(hours: 2)),
      'currentWeight': 15.5,
      'targetWeight': 16.0,
      'healthStatus': 'good',
      'lastVetVisit': DateTime.now().subtract(const Duration(days: 30)),
    };
  }

  /// 펫 상태 업데이트
  static void updatePetStatus(String petId, Map<String, dynamic> status) {
    // Mock 구현 - 실제로는 데이터베이스에 저장
  }

  /// Mock 급식 기록 추가
  static void addMockFeedingRecord(Map<String, dynamic> record) {
    // Mock 구현 - 실제로는 데이터베이스에 저장
  }

  /// Mock 급식 기록 반환
  static List<Map<String, dynamic>> getMockFeedingRecords() {
    return [
      {
        'id': 'feeding-1',
        'petId': 'pet-1',
        'amount': 100.0,
        'foodType': 'ドライフード',
        'feedingTime': DateTime.now().subtract(const Duration(hours: 6)),
        'notes': '通常の給餌',
      },
      {
        'id': 'feeding-2',
        'petId': 'pet-1',
        'amount': 80.0,
        'foodType': 'ウェットフード',
        'feedingTime': DateTime.now().subtract(const Duration(days: 1)),
        'notes': 'おやつとして少量',
      },
    ];
  }

  /// Mock 급식 통계 반환
  static Map<String, dynamic> getMockFeedingStatistics() {
    return {
      'totalFeedings': 14,
      'averageAmount': 95.5,
      'totalAmount': 1337.0,
      'mostUsedFoodType': 'ドライフード',
      'feedingFrequency': '2回/日',
    };
  }

  /// ID로 펫 정보 반환
  static Map<String, dynamic> getMockPetById(String petId) {
    return {
      'id': petId,
      'name': 'Maxi',
      'type': 'dog',
      'breed': '柴犬',
      'age': 3,
      'weight': 15.5,
      'gender': 'male',
      'birthDate': DateTime.now().subtract(const Duration(days: 1095)),
      'profileImage': 'assets/images/dogs/shiba.png',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    };
  }
}
