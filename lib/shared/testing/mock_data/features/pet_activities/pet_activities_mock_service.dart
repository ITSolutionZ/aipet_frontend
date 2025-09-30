import 'package:aipet_frontend/shared/testing/mock_data/core/base_mock_service.dart';
import 'package:flutter/material.dart';

/// Pet Activities Feature 전용 Mock 데이터 서비스
class PetActivitiesMockService extends BaseMockService {
  // ==================== 트릭 데이터 ====================

  /// Mock 트릭 목록
  static List<Map<String, dynamic>> getMockTricks() {
    return [
      {
        'id': '1',
        'name': '앉기',
        'petId': '1',
        'difficulty': 'easy',
        'progress': 95,
        'isCompleted': true,
        'learningDays': 5,
        'description': '기본적인 앉기 자세 훈련',
        'instructions': ['간식을 펫의 코 위로 들어 올리기', '"앉아" 명령과 함께 자세 유도', '성공하면 즉시 보상하기'],
        'videoUrl': 'https://youtube.com/watch?v=example1',
        'imagePath': 'assets/images/tricks/sit.png',
        'createdAt': DateTime.now().subtract(const Duration(days: 20)),
        'completedAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': '2',
        'name': '손 내밀기',
        'petId': '1',
        'difficulty': 'easy',
        'progress': 70,
        'isCompleted': false,
        'learningDays': 8,
        'description': '앞발을 들어 손 맞추기',
        'instructions': ['앉은 상태에서 시작', '손을 펫 앞에 내밀기', '"손" 명령과 함께 발 유도'],
        'videoUrl': 'https://youtube.com/watch?v=example2',
        'imagePath': 'assets/images/tricks/shake.png',
        'createdAt': DateTime.now().subtract(const Duration(days: 8)),
      },
      {
        'id': '3',
        'name': '돌기',
        'petId': '1',
        'difficulty': 'medium',
        'progress': 30,
        'isCompleted': false,
        'learningDays': 12,
        'description': '제자리에서 한 바퀴 돌기',
        'instructions': ['간식으로 원형 유도', '"돌아" 명령 사용', '천천히 속도 조절'],
        'videoUrl': 'https://youtube.com/watch?v=example3',
        'imagePath': 'assets/images/tricks/spin.png',
        'createdAt': DateTime.now().subtract(const Duration(days: 12)),
      },
    ];
  }

  /// 펫별 트릭 목록 조회
  static List<Map<String, dynamic>> getTricksByPet(String petId) {
    return getMockTricks().where((trick) => trick['petId'] == petId).toList();
  }

  /// 완료된 트릭 목록
  static List<Map<String, dynamic>> getCompletedTricks({String? petId}) {
    return getMockTricks()
        .where((trick) => trick['isCompleted'] == true)
        .where((trick) => petId == null || trick['petId'] == petId)
        .toList();
  }

  // ==================== 비디오 북마크 데이터 ====================

  /// Mock 비디오 북마크 목록
  static List<Map<String, dynamic>> getMockVideoBookmarks() {
    return [
      {
        'id': MockHelper.generateId(),
        'videoId': 'abc123def456',
        'title': '강아지 기초 훈련 - 앉기',
        'channelName': '펫트레이너 김코치',
        'duration': '05:32',
        'thumbnailUrl': 'https://img.youtube.com/vi/abc123def456/mqdefault.jpg',
        'url': 'https://youtube.com/watch?v=abc123def456',
        'addedAt': DateTime.now().subtract(const Duration(days: 3)),
        'category': 'basic_training',
        'tags': ['기초', '앉기', '훈련'],
      },
      {
        'id': MockHelper.generateId(),
        'videoId': 'xyz789ghi012',
        'title': '고양이 놀이 방법 - 낚싯대 놀이',
        'channelName': '고양이전문가',
        'duration': '08:15',
        'thumbnailUrl': 'https://img.youtube.com/vi/xyz789ghi012/mqdefault.jpg',
        'url': 'https://youtube.com/watch?v=xyz789ghi012',
        'addedAt': DateTime.now().subtract(const Duration(days: 7)),
        'category': 'play',
        'tags': ['고양이', '놀이', '운동'],
      },
    ];
  }

  // ==================== 비디오 진행률 데이터 ====================

  /// Mock 비디오 진행률 맵
  static Map<String, Map<String, dynamic>> getMockVideoProgress() {
    return {
      'abc123def456': {
        'videoId': 'abc123def456',
        'watchedSeconds': 245,
        'totalSeconds': 332,
        'progress': 0.74, // 74%
        'lastWatched': DateTime.now().subtract(const Duration(hours: 2)),
        'completed': false,
      },
      'xyz789ghi012': {
        'videoId': 'xyz789ghi012',
        'watchedSeconds': 495,
        'totalSeconds': 495,
        'progress': 1.0, // 100%
        'lastWatched': DateTime.now().subtract(const Duration(days: 1)),
        'completed': true,
      },
    };
  }

  // ==================== YouTube 비디오 정보 ====================

  /// YouTube 비디오 정보 조회
  static Map<String, dynamic> getMockYouTubeVideoInfo(String videoId) {
    // Mock 비디오 정보 - 실제로는 YouTube API에서 가져옴
    final mockVideos = {
      'abc123def456': {
        'id': 'abc123def456',
        'title': '강아지 기초 훈련 - 앉기 마스터하기',
        'description': '반려견 기초 훈련의 첫 번째 단계인 앉기 훈련에 대해 상세히 설명합니다.',
        'channelName': '펫트레이너 김코치',
        'duration': '05:32',
        'viewCount': 125000,
        'likeCount': 3200,
        'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
        'publishedAt': DateTime.now().subtract(const Duration(days: 30)),
        'tags': ['강아지훈련', '펫트레이닝', '기초훈련', '앉기'],
      },
      'def456ghi789': {
        'id': 'def456ghi789',
        'title': '고양이 스트레스 해소 놀이법',
        'description': '실내 고양이의 스트레스를 해소하는 다양한 놀이 방법을 소개합니다.',
        'channelName': '고양이전문가',
        'duration': '08:15',
        'viewCount': 89000,
        'likeCount': 2100,
        'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
        'publishedAt': DateTime.now().subtract(const Duration(days: 15)),
        'tags': ['고양이놀이', '스트레스해소', '실내고양이'],
      },
    };

    return mockVideos[videoId] ??
        {
          'id': videoId,
          'title': '비디오 제목',
          'description': '비디오 설명',
          'channelName': '채널명',
          'duration': '00:00',
          'viewCount': 0,
          'likeCount': 0,
          'thumbnailUrl': 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
          'publishedAt': DateTime.now(),
          'tags': [],
        };
  }

  /// 기본 비디오 제목 생성
  static String getDefaultVideoTitle(String videoId) {
    final videoInfo = getMockYouTubeVideoInfo(videoId);
    return videoInfo['title'] ?? '새로운 훈련 비디오';
  }

  // ==================== 활동 통계 ====================

  /// 펫 활동 통계
  static Map<String, dynamic> getActivityStats({String? petId}) {
    return {
      'totalTricks': 3,
      'completedTricks': 1,
      'inProgressTricks': 2,
      'totalLearningDays': 25,
      'averageProgress': 65.0,
      'bookmarkedVideos': 2,
      'watchedVideos': 1,
      'achievements': [
        {
          'name': '첫 번째 트릭 완성',
          'description': '첫 번째 트릭을 성공적으로 완료했습니다!',
          'earnedAt': DateTime.now().subtract(const Duration(days: 5)),
          'icon': Icons.star,
        },
      ],
    };
  }
}
