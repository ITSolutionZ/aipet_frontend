import 'dart:convert';

import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// YouTube API 통합 서비스
class YouTubeApiService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const Duration _timeout = Duration(seconds: 10);

  /// 반려동물 훈련 비디오 검색
  Future<Result<List<YouTubeVideo>>> searchPetTrainingVideos({
    required String query,
    int maxResults = 20,
    String order = 'relevance', // relevance, date, rating, viewCount
  }) async {
    try {
      final apiKey = AppConfig.current.youtubeApiKey;
      if (apiKey.isEmpty) {
        if (AppConfig.current.isMockMode) {
          return _getMockVideos();
        }
        return const Failure('YouTube API 키가 설정되지 않았습니다');
      }

      final searchQuery = '$query 반려동물 훈련 pet training';
      final Map<String, String> params = {
        'part': 'snippet',
        'q': searchQuery,
        'type': 'video',
        'maxResults': maxResults.toString(),
        'order': order,
        'key': apiKey,
        'relevanceLanguage': 'ja',
        'safeSearch': 'strict',
        'videoEmbeddable': 'true',
        'videoSyndicated': 'true',
      };

      final uri = Uri.parse(
        '$_baseUrl/search',
      ).replace(queryParameters: params);

      debugPrint('🎥 YouTube API 검색: $searchQuery');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        final videos = items
            .map((item) => _mapYouTubeItem(item as Map<String, dynamic>))
            .where((video) => video != null)
            .cast<YouTubeVideo>()
            .toList();

        return Success(videos, '비디오를 성공적으로 찾았습니다');
      } else {
        return Result.failure('YouTube API 요청 실패: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('YouTube API 오류: $error');
      if (AppConfig.current.isMockMode) {
        return _getMockVideos();
      }
      return Result.failure('비디오 검색에 실패했습니다: ${error.toString()}');
    }
  }

  /// 인기 반려동물 비디오 가져오기
  Future<Result<List<YouTubeVideo>>> getPopularPetVideos({
    int maxResults = 20,
    String regionCode = 'JP',
  }) async {
    try {
      final apiKey = AppConfig.current.youtubeApiKey;
      if (apiKey.isEmpty) {
        if (AppConfig.current.isMockMode) {
          return _getMockVideos();
        }
        return const Failure('YouTube API 키가 설정되지 않았습니다');
      }

      final Map<String, String> params = {
        'part': 'snippet,statistics',
        'chart': 'mostPopular',
        'maxResults': maxResults.toString(),
        'regionCode': regionCode,
        'videoCategoryId': '15', // Pets & Animals category
        'key': apiKey,
      };

      final uri = Uri.parse(
        '$_baseUrl/videos',
      ).replace(queryParameters: params);

      debugPrint('🏆 YouTube 인기 동물 비디오 요청');

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        final videos = items
            .map((item) => _mapYouTubeItem(item as Map<String, dynamic>))
            .where((video) => video != null)
            .cast<YouTubeVideo>()
            .toList();

        return Success(videos, '인기 비디오를 성공적으로 가져왔습니다');
      } else {
        return Result.failure('YouTube API 요청 실패: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('YouTube 인기 비디오 오류: $error');
      if (AppConfig.current.isMockMode) {
        return _getMockVideos();
      }
      return Result.failure('인기 비디오를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  /// 비디오 상세 정보 가져오기
  Future<Result<YouTubeVideo>> getVideoDetails(String videoId) async {
    try {
      final apiKey = AppConfig.current.youtubeApiKey;
      if (apiKey.isEmpty) {
        return const Failure('YouTube API 키가 설정되지 않았습니다');
      }

      final Map<String, String> params = {
        'part': 'snippet,statistics,contentDetails',
        'id': videoId,
        'key': apiKey,
      };

      final uri = Uri.parse(
        '$_baseUrl/videos',
      ).replace(queryParameters: params);

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];

        if (items.isNotEmpty) {
          final video = _mapYouTubeItem(items.first as Map<String, dynamic>);
          if (video != null) {
            return Success(video, '비디오 상세 정보를 가져왔습니다');
          }
        }

        return const Failure('비디오를 찾을 수 없습니다');
      } else {
        return Result.failure('YouTube API 요청 실패: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('YouTube 비디오 상세 정보 오류: $error');
      return Result.failure('비디오 상세 정보를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  /// YouTube API 응답을 YouTubeVideo 객체로 변환
  YouTubeVideo? _mapYouTubeItem(Map<String, dynamic> item) {
    try {
      final snippet = item['snippet'] as Map<String, dynamic>?;
      final statistics = item['statistics'] as Map<String, dynamic>?;
      final contentDetails = item['contentDetails'] as Map<String, dynamic>?;

      if (snippet == null) return null;

      final videoId = item['id'] is String
          ? item['id'] as String
          : (item['id'] as Map<String, dynamic>?)?['videoId'] as String?;

      if (videoId == null) return null;

      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
      final highThumbnail = thumbnails?['high'] as Map<String, dynamic>?;
      final thumbnailUrl =
          highThumbnail?['url'] as String? ??
          thumbnails?['medium']?['url'] as String? ??
          thumbnails?['default']?['url'] as String?;

      return YouTubeVideo(
        id: videoId,
        title: snippet['title'] as String? ?? '제목 없음',
        description: snippet['description'] as String? ?? '',
        thumbnailUrl: thumbnailUrl ?? '',
        channelTitle: snippet['channelTitle'] as String? ?? '알 수 없는 채널',
        publishedAt: _parseDateTime(snippet['publishedAt'] as String?),
        duration: _parseDuration(contentDetails?['duration'] as String?),
        viewCount:
            int.tryParse(statistics?['viewCount'] as String? ?? '0') ?? 0,
        likeCount:
            int.tryParse(statistics?['likeCount'] as String? ?? '0') ?? 0,
        url: 'https://www.youtube.com/watch?v=$videoId',
        embedUrl: 'https://www.youtube.com/embed/$videoId',
      );
    } catch (error) {
      debugPrint('YouTube 아이템 변환 오류: $error');
      return null;
    }
  }

  /// ISO 8601 duration을 초로 변환
  int _parseDuration(String? duration) {
    if (duration == null) return 0;

    // PT4M13S -> 253초
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);

    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  /// ISO 8601 날짜 파싱
  DateTime _parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Mock 비디오 데이터 반환
  Future<Result<List<YouTubeVideo>>> _getMockVideos() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockVideos = [
      YouTubeVideo(
        id: 'mock_video_1',
        title: '강아지 기본 훈련 - 앉기, 기다리기, 오기',
        description: '강아지 기본 훈련 방법을 자세히 설명합니다. 초보자도 쉽게 따라할 수 있습니다.',
        thumbnailUrl: 'https://img.youtube.com/vi/mock_video_1/hqdefault.jpg',
        channelTitle: '펫 트레이닝 마스터',
        publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        duration: 480, // 8분
        viewCount: 125340,
        likeCount: 3420,
        url: 'https://www.youtube.com/watch?v=mock_video_1',
        embedUrl: 'https://www.youtube.com/embed/mock_video_1',
      ),
      YouTubeVideo(
        id: 'mock_video_2',
        title: '고양이 화장실 훈련 완벽 가이드',
        description: '고양이가 화장실을 올바르게 사용하도록 훈련하는 방법을 알려드립니다.',
        thumbnailUrl: 'https://img.youtube.com/vi/mock_video_2/hqdefault.jpg',
        channelTitle: '캣맘 TV',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: 360, // 6분
        viewCount: 89760,
        likeCount: 2156,
        url: 'https://www.youtube.com/watch?v=mock_video_2',
        embedUrl: 'https://www.youtube.com/embed/mock_video_2',
      ),
      YouTubeVideo(
        id: 'mock_video_3',
        title: '반려동물과 함께하는 놀이 활동 10가지',
        description: '집에서 쉽게 할 수 있는 반려동물 놀이 활동들을 소개합니다.',
        thumbnailUrl: 'https://img.youtube.com/vi/mock_video_3/hqdefault.jpg',
        channelTitle: '해피펫 라이프',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: 720, // 12분
        viewCount: 234580,
        likeCount: 5670,
        url: 'https://www.youtube.com/watch?v=mock_video_3',
        embedUrl: 'https://www.youtube.com/embed/mock_video_3',
      ),
    ];

    return Success(mockVideos, 'Mock 비디오 데이터를 로드했습니다');
  }
}

/// YouTube 비디오 데이터 모델
class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final DateTime publishedAt;
  final int duration; // 초 단위
  final int viewCount;
  final int likeCount;
  final String url;
  final String embedUrl;

  const YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
    required this.url,
    required this.embedUrl,
  });

  /// 길이를 MM:SS 형식으로 포맷
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// 조회수를 사람이 읽기 쉬운 형식으로 포맷
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
    }
  }

  /// 좋아요 수를 사람이 읽기 쉬운 형식으로 포맷
  String get formattedLikeCount {
    if (likeCount >= 1000000) {
      return '${(likeCount / 1000000).toStringAsFixed(1)}M';
    } else if (likeCount >= 1000) {
      return '${(likeCount / 1000).toStringAsFixed(1)}K';
    } else {
      return likeCount.toString();
    }
  }

  /// 게시 날짜를 상대적 시간으로 포맷
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

/// YouTubeApiService Provider
final youTubeApiServiceProvider = Provider<YouTubeApiService>((ref) {
  return YouTubeApiService();
});
