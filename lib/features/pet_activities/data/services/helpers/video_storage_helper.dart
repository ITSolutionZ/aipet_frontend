import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 비디오 저장소 헬퍼
class VideoStorageHelper {
  static const String _keyYouTubeVideos = 'youtube_videos';
  static const String _keyVideoProgress = 'video_progress';

  /// YouTube 비디오 가져오기
  static Future<List<Map<String, dynamic>>> getYouTubeVideos({
    String? petId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = prefs.getStringList(_keyYouTubeVideos) ?? [];

      if (videosJson.isEmpty) {
        return await _initializeDefaultVideos();
      }

      final videos = videosJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      if (petId != null) {
        return videos.where((v) => v['petId'] == petId).toList();
      }

      return videos;
    } catch (e) {
      debugPrint('YouTube 비디오 로드 실패: $e');
      return [];
    }
  }

  /// YouTube 비디오 추가
  static Future<void> addYouTubeVideo(Map<String, dynamic> video) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videos = prefs.getStringList(_keyYouTubeVideos) ?? [];

      if (video['id'] == null || (video['id'] as String).isEmpty) {
        video['id'] = 'video-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (video['createdAt'] == null) {
        video['createdAt'] = DateTime.now().toIso8601String();
      }

      if (video['updatedAt'] == null) {
        video['updatedAt'] = DateTime.now().toIso8601String();
      }

      videos.add(jsonEncode(video));
      await prefs.setStringList(_keyYouTubeVideos, videos);

      if (kDebugMode) {
        debugPrint('YouTube 비디오 추가 완료: ${video['title']}');
      }
    } catch (e) {
      debugPrint('YouTube 비디오 추가 실패: $e');
      rethrow;
    }
  }

  /// YouTube 비디오 업데이트
  static Future<void> updateYouTubeVideo(
    String videoId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videos = prefs.getStringList(_keyYouTubeVideos) ?? [];

      final updatedVideos = videos.map((json) {
        final video = jsonDecode(json) as Map<String, dynamic>;
        if (video['id'] == videoId) {
          video.addAll(updates);
          video['updatedAt'] = DateTime.now().toIso8601String();
        }
        return jsonEncode(video);
      }).toList();

      await prefs.setStringList(_keyYouTubeVideos, updatedVideos);

      if (kDebugMode) {
        debugPrint('YouTube 비디오 업데이트 완료: $videoId');
      }
    } catch (e) {
      debugPrint('YouTube 비디오 업데이트 실패: $e');
      rethrow;
    }
  }

  /// YouTube 비디오 삭제
  static Future<void> deleteYouTubeVideo(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videos = prefs.getStringList(_keyYouTubeVideos) ?? [];

      final filteredVideos = videos.where((json) {
        final video = jsonDecode(json) as Map<String, dynamic>;
        return video['id'] != videoId;
      }).toList();

      await prefs.setStringList(_keyYouTubeVideos, filteredVideos);

      if (kDebugMode) {
        debugPrint('YouTube 비디오 삭제 완료: $videoId');
      }
    } catch (e) {
      debugPrint('YouTube 비디오 삭제 실패: $e');
      rethrow;
    }
  }

  /// 비디오 진행률 가져오기
  static Future<Map<String, int>> getVideoProgress(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('${_keyVideoProgress}_$videoId');

      if (progressJson != null) {
        final progress = jsonDecode(progressJson) as Map<String, dynamic>;
        return {
          'currentPosition': progress['currentPosition'] ?? 0,
          'totalDuration': progress['totalDuration'] ?? 0,
        };
      }

      return {'currentPosition': 0, 'totalDuration': 0};
    } catch (e) {
      debugPrint('비디오 진행률 로드 실패: $e');
      return {'currentPosition': 0, 'totalDuration': 0};
    }
  }

  /// 비디오 진행률 저장
  static Future<void> saveVideoProgress(
    String videoId,
    int currentPosition,
    int totalDuration,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progress = {
        'currentPosition': currentPosition,
        'totalDuration': totalDuration,
        'lastWatched': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
        '${_keyVideoProgress}_$videoId',
        jsonEncode(progress),
      );

      if (kDebugMode) {
        debugPrint('비디오 진행률 저장 완료: $videoId');
      }
    } catch (e) {
      debugPrint('비디오 진행률 저장 실패: $e');
      rethrow;
    }
  }

  /// 비디오 검색
  static Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    try {
      final allVideos = await getYouTubeVideos();
      final lowerQuery = query.toLowerCase();

      return allVideos.where((video) {
        final title = (video['title'] as String? ?? '').toLowerCase();
        final description = (video['description'] as String? ?? '')
            .toLowerCase();
        final tags = (video['tags'] as List<dynamic>? ?? [])
            .map((tag) => (tag as String).toLowerCase())
            .toList();

        return title.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            tags.any((tag) => tag.contains(lowerQuery));
      }).toList();
    } catch (e) {
      debugPrint('비디오 검색 실패: $e');
      return [];
    }
  }

  /// 비디오 통계
  static Future<Map<String, int>> getVideoStats({String? petId}) async {
    try {
      final videos = await getYouTubeVideos(petId: petId);

      return {
        'total': videos.length,
        'watched': videos.where((v) => v['isWatched'] == true).length,
        'bookmarked': videos.where((v) => v['isBookmarked'] == true).length,
      };
    } catch (e) {
      debugPrint('비디오 통계 실패: $e');
      return {'total': 0, 'watched': 0, 'bookmarked': 0};
    }
  }

  /// 기본 비디오 초기화
  static Future<List<Map<String, dynamic>>> _initializeDefaultVideos() async {
    final defaultVideos = [
      {
        'id': 'video-1',
        'title': '基本のしつけ',
        'description': '基本的な犬のしつけ方法を学びます',
        'url': 'https://www.youtube.com/watch?v=example1',
        'thumbnail': 'https://img.youtube.com/vi/example1/maxresdefault.jpg',
        'duration': 300,
        'tags': ['しつけ', '基本'],
        'petId': 'default',
        'isWatched': false,
        'isBookmarked': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = defaultVideos
          .map((video) => jsonEncode(video))
          .toList();
      await prefs.setStringList(_keyYouTubeVideos, videosJson);

      if (kDebugMode) {
        debugPrint('기본 YouTube 비디오 초기화 완료');
      }

      return defaultVideos;
    } catch (e) {
      debugPrint('기본 YouTube 비디오 초기화 실패: $e');
      return [];
    }
  }
}
