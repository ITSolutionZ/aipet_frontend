import 'dart:convert';

import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_timeline_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// YouTube 비디오의 Chapters 정보를 추출하는 서비스
class YoutubeChaptersService {
  static final YoutubeChaptersService _instance = YoutubeChaptersService._();
  late String _apiKey;

  YoutubeChaptersService._() {
    _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  }

  static YoutubeChaptersService get instance => _instance;

  /// YouTube 비디오 ID로부터 Chapters 추출
  ///
  /// 비디오 설명란에서 타임스탬프 형식의 chapters를 파싱합니다.
  /// 예: "0:00 소개\n2:30 기본 트릭\n5:00 고급 트릭"
  ///
  /// API 호출 타임아웃: 5초
  Future<List<YouTubeTimelineEntity>> extractChapters(String videoId) async {
    try {
      debugPrint('📺 YouTube 영상 메타데이터 요청: $videoId');

      // YouTube Data API v3 호출 (5초 타임아웃)
      final url =
          'https://www.googleapis.com/youtube/v3/videos?'
          'id=$videoId&'
          'key=$_apiKey&'
          'part=snippet&'
          'fields=items(snippet/description)';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('⏱️ YouTube API 요청 타임아웃 (5초)');
              return http.Response('{"items":[]}', 408);
            },
          );

      if (response.statusCode != 200) {
        debugPrint(
          '❌ YouTube API 요청 실패: ${response.statusCode}',
        );
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final items = json['items'] as List? ?? [];

      if (items.isEmpty) {
        debugPrint('⚠️ YouTube 영상 데이터 없음: $videoId');
        return [];
      }

      final videoData = items.first as Map<String, dynamic>;
      final snippet = videoData['snippet'] as Map<String, dynamic>?;
      final description = snippet?['description'] as String? ?? '';

      if (description.isEmpty) {
        debugPrint('⚠️ 비디오 설명란이 비어있습니다: $videoId');
        return [];
      }

      final descPreview = description.substring(
        0,
        description.length > 100 ? 100 : description.length,
      );
      debugPrint('📝 비디오 설명란 찾음: $descPreview...');

      // 설명란에서 chapters 파싱
      return _parseChapters(description, videoId);
    } catch (e) {
      debugPrint('❌ Chapters 추출 실패: $e');
      return [];
    }
  }

  /// 비디오 설명란에서 타임스탬프 기반 chapters 파싱
  ///
  /// 지원하는 형식:
  /// - "0:00 소개" 또는 "00:00 소개"
  /// - "0:00 - 소개" 또는 "00:00 - 소개"
  /// - "0:00 소개\n2:30 기본 트릭"
  List<YouTubeTimelineEntity> _parseChapters(
    String description,
    String videoId,
  ) {
    final chapters = <YouTubeTimelineEntity>[];

    // 타임스탬프 정규식: MM:SS, H:MM:SS, HH:MM:SS 형식
    // 예: "0:00", "00:00", "1:23:45"
    final timestampRegex = RegExp(
      r'(\d{1,2}):(\d{2}):(\d{2})|(\d{1,2}):(\d{2})',
      multiLine: true,
    );

    final lines = description.split('\n');
    final timestamps = <Map<String, dynamic>>[];

    // 각 라인에서 타임스탬프 추출
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final match = timestampRegex.firstMatch(trimmed);
      if (match == null) continue;

      // 시간 계산
      int seconds = 0;
      if (match.group(1) != null) {
        // HH:MM:SS 형식
        final hours = int.parse(match.group(1)!);
        final minutes = int.parse(match.group(2)!);
        final secs = int.parse(match.group(3)!);
        seconds = hours * 3600 + minutes * 60 + secs;
      } else {
        // MM:SS 형식
        final minutes = int.parse(match.group(4)!);
        final secs = int.parse(match.group(5)!);
        seconds = minutes * 60 + secs;
      }

      // 타임스탬프 뒤의 텍스트 추출 (제목/설명)
      final endPos = match.end;
      var title = trimmed.substring(endPos).trim();

      // 하이픈, 대시 제거
      if (title.startsWith('-') || title.startsWith('–')) {
        title = title.substring(1).trim();
      }

      if (title.isNotEmpty) {
        timestamps.add({
          'seconds': seconds,
          'title': title,
          'originalLine': trimmed,
        });
      }
    }

    if (timestamps.isEmpty) {
      debugPrint('⚠️ 설명란에서 타임스탬프를 찾을 수 없습니다');
      return [];
    }

    debugPrint('✅ ${timestamps.length}개의 타임스탬프 발견');

    // 타임스탬프를 기반으로 YouTube 타임라인 엔티티 생성
    final now = DateTime.now();
    for (int i = 0; i < timestamps.length; i++) {
      final current = timestamps[i];
      final next = i + 1 < timestamps.length ? timestamps[i + 1] : null;

      final startSec = current['seconds'] as int;
      final endSec = next?['seconds'] as int? ?? (startSec + 300); // 기본 5분

      chapters.add(
        YouTubeTimelineEntity(
          id: '${videoId}_ch_$i',
          videoId: videoId,
          title: current['title'] as String,
          description: '${current['originalLine']}', // 원본 라인을 설명으로
          startTimeSec: startSec,
          endTimeSec: endSec,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    debugPrint('📅 ${chapters.length}개의 Chapter 생성 완료');
    return chapters;
  }
}
