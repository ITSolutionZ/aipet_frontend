import 'dart:convert';

import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// YouTube Data API v3 서비스
class YouTubeApiService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static String get _apiKey => dotenv.env['YOUTUBE_API_KEY'] ?? '';

  /// 비디오 정보 조회
  static Future<Map<String, dynamic>?> getVideoInfo(String videoId) async {
    try {
      final url =
          '$_baseUrl/videos?id=$videoId&part=snippet,contentDetails&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return data['items'][0];
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ YouTube API Error: $e');
      }
      return null;
    }
  }

  /// 비디오 설명에서 타임라인 섹션 추출
  static Future<List<YouTubeTimelineEntity>> extractTimelineFromDescription(
    String videoId,
  ) async {
    try {
      final videoInfo = await getVideoInfo(videoId);
      if (videoInfo == null) return [];

      final snippet = videoInfo['snippet'];
      final description = snippet['description'] ?? '';

      return _parseDescriptionForTimestamps(description, videoId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Timeline extraction error: $e');
      }
      return [];
    }
  }

  /// 설명 텍스트에서 타임스탬프 패턴 파싱
  static List<YouTubeTimelineEntity> _parseDescriptionForTimestamps(
    String description,
    String videoId,
  ) {
    final List<YouTubeTimelineEntity> sections = [];
    final now = DateTime.now();

    // 다양한 타임스탬프 패턴 지원
    final patterns = [
      RegExp(r'(\d{1,2}:\d{2}(:\d{2})?)\s*[-–—]\s*(.+)'), // "1:23 - 제목"
      RegExp(r'(\d{1,2}:\d{2}(:\d{2})?)\s+(.+)'), // "1:23 제목"
      RegExp(r'(\d{1,2}:\d{2}(:\d{2})?)\s*:\s*(.+)'), // "1:23: 제목"
    ];

    final lines = description.split('\n');
    int previousEndTime = 0;

    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final timeString = match.group(1)!;
          final title = match.group(3)?.trim() ?? '섹션';
          final startTimeSec = _parseTimeStringToSeconds(timeString);

          if (startTimeSec >= 0 && title.isNotEmpty) {
            // 이전 섹션의 종료 시간을 현재 섹션의 시작 시간으로 설정
            if (sections.isNotEmpty) {
              sections.last = sections.last.copyWith(endTimeSec: startTimeSec);
            }

            sections.add(
              YouTubeTimelineEntity(
                id: '${videoId}_$startTimeSec',
                videoId: videoId,
                title: title,
                startTimeSec: startTimeSec,
                endTimeSec: startTimeSec + 60, // 임시 종료 시간
                createdAt: now,
                updatedAt: now,
              ),
            );
            previousEndTime = startTimeSec;
            break; // 패턴 매치되면 다른 패턴은 시도하지 않음
          }
        }
      }
    }

    // 마지막 섹션의 종료 시간을 비디오 길이로 설정 (비디오 길이를 알 수 없는 경우 기본값)
    if (sections.isNotEmpty) {
      sections.last = sections.last.copyWith(endTimeSec: previousEndTime + 120);
    }

    return sections;
  }

  /// 시간 문자열을 초 단위로 변환
  static int _parseTimeStringToSeconds(String timeString) {
    try {
      final parts = timeString.split(':').map(int.parse).toList();
      if (parts.length == 3) {
        // HH:MM:SS
        return parts[0] * 3600 + parts[1] * 60 + parts[2];
      } else if (parts.length == 2) {
        // MM:SS
        return parts[0] * 60 + parts[1];
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Time parsing error: $e');
      }
    }
    return 0;
  }

  /// 비디오 썸네일 URL 생성
  static String getThumbnailUrl(String videoId, {String quality = 'medium'}) {
    return 'https://img.youtube.com/vi/$videoId/${_getQualityCode(quality)}.jpg';
  }

  /// 품질 코드 반환
  static String _getQualityCode(String quality) {
    switch (quality) {
      case 'default':
        return 'default';
      case 'medium':
        return 'mqdefault';
      case 'high':
        return 'hqdefault';
      case 'standard':
        return 'sddefault';
      case 'maxres':
        return 'maxresdefault';
      default:
        return 'mqdefault';
    }
  }

  /// 비디오 길이를 초 단위로 변환
  static int parseDurationToSeconds(String duration) {
    // ISO 8601 duration format (PT4M13S)
    if (duration.startsWith('PT')) {
      final durationStr = duration.substring(2);
      int seconds = 0;

      final hoursMatch = RegExp(r'(\d+)H').firstMatch(durationStr);
      if (hoursMatch != null) {
        seconds += int.parse(hoursMatch.group(1)!) * 3600;
      }

      final minutesMatch = RegExp(r'(\d+)M').firstMatch(durationStr);
      if (minutesMatch != null) {
        seconds += int.parse(minutesMatch.group(1)!) * 60;
      }

      final secondsMatch = RegExp(r'(\d+)S').firstMatch(durationStr);
      if (secondsMatch != null) {
        seconds += int.parse(secondsMatch.group(1)!);
      }

      return seconds;
    }
    return 0;
  }
}
