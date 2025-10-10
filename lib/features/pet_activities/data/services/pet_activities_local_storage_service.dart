import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/bookmark_storage_helper.dart';
import 'helpers/trick_storage_helper.dart';
import 'helpers/video_storage_helper.dart';

/// 펫 활동 로컬 저장소 서비스 (리팩토링됨)
///
/// 트릭, 비디오 북마크, 비디오 진행률을 SharedPreferences에 저장/관리합니다
class PetActivitiesLocalStorageService {
  static const String _keyTricks = 'pet_tricks';
  static const String _keyVideoBookmarks = 'video_bookmarks';
  static const String _keyVideoProgress = 'video_progress';
  static const String _keyYouTubeVideos = 'youtube_videos';

  // ========== 트릭 관련 메서드 (헬퍼 위임) ==========

  /// 트릭 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getTricks({String? petId}) async {
    return TrickStorageHelper.getTricks(petId: petId);
  }

  /// 트릭 추가 (헬퍼 위임)
  static Future<void> addTrick(Map<String, dynamic> trick) async {
    return TrickStorageHelper.addTrick(trick);
  }

  /// 트릭 업데이트 (헬퍼 위임)
  static Future<void> updateTrick(
    String trickId,
    Map<String, dynamic> updates,
  ) async {
    return TrickStorageHelper.updateTrick(trickId, updates);
  }

  /// 트릭 삭제 (헬퍼 위임)
  static Future<void> deleteTrick(String trickId) async {
    return TrickStorageHelper.deleteTrick(trickId);
  }

  /// 트릭 검색 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> searchTricks(String query) async {
    return TrickStorageHelper.searchTricks(query);
  }

  /// 트릭 통계 (헬퍼 위임)
  static Future<Map<String, int>> getTrickStats({String? petId}) async {
    return TrickStorageHelper.getTrickStats(petId: petId);
  }

  // ========== YouTube 비디오 관련 메서드 (헬퍼 위임) ==========

  /// YouTube 비디오 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getYouTubeVideos({
    String? petId,
  }) async {
    return VideoStorageHelper.getYouTubeVideos(petId: petId);
  }

  /// YouTube 비디오 추가 (헬퍼 위임)
  static Future<void> addYouTubeVideo(Map<String, dynamic> video) async {
    return VideoStorageHelper.addYouTubeVideo(video);
  }

  /// YouTube 비디오 업데이트 (헬퍼 위임)
  static Future<void> updateYouTubeVideo(
    String videoId,
    Map<String, dynamic> updates,
  ) async {
    return VideoStorageHelper.updateYouTubeVideo(videoId, updates);
  }

  /// YouTube 비디오 삭제 (헬퍼 위임)
  static Future<void> deleteYouTubeVideo(String videoId) async {
    return VideoStorageHelper.deleteYouTubeVideo(videoId);
  }

  /// 비디오 검색 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    return VideoStorageHelper.searchVideos(query);
  }

  /// 비디오 통계 (헬퍼 위임)
  static Future<Map<String, int>> getVideoStats({String? petId}) async {
    return VideoStorageHelper.getVideoStats(petId: petId);
  }

  // ========== 비디오 진행률 관련 메서드 (헬퍼 위임) ==========

  /// 비디오 진행률 가져오기 (헬퍼 위임)
  static Future<Map<String, int>> getVideoProgress(String videoId) async {
    return VideoStorageHelper.getVideoProgress(videoId);
  }

  /// 비디오 진행률 저장 (헬퍼 위임)
  static Future<void> saveVideoProgress(
    String videoId,
    int currentPosition,
    int totalDuration,
  ) async {
    return VideoStorageHelper.saveVideoProgress(
      videoId,
      currentPosition,
      totalDuration,
    );
  }

  // ========== 비디오 북마크 관련 메서드 (헬퍼 위임) ==========

  /// 비디오 북마크 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getVideoBookmarks(
    String videoId,
  ) async {
    return BookmarkStorageHelper.getVideoBookmarks(videoId);
  }

  /// 비디오 북마크 추가 (헬퍼 위임)
  static Future<void> addVideoBookmark(Map<String, dynamic> bookmark) async {
    return BookmarkStorageHelper.addVideoBookmark(bookmark);
  }

  /// 비디오 북마크 업데이트 (헬퍼 위임)
  static Future<void> updateVideoBookmark(
    String bookmarkId,
    Map<String, dynamic> updates,
  ) async {
    return BookmarkStorageHelper.updateVideoBookmark(bookmarkId, updates);
  }

  /// 비디오 북마크 삭제 (헬퍼 위임)
  static Future<void> deleteVideoBookmark(String bookmarkId) async {
    return BookmarkStorageHelper.deleteVideoBookmark(bookmarkId);
  }

  /// 모든 비디오 북마크 가져오기 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getAllVideoBookmarks() async {
    return BookmarkStorageHelper.getAllVideoBookmarks();
  }

  /// 비디오 북마크 검색 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> searchVideoBookmarks(
    String query,
  ) async {
    return BookmarkStorageHelper.searchVideoBookmarks(query);
  }

  /// 비디오 북마크 통계 (헬퍼 위임)
  static Future<Map<String, int>> getBookmarkStats(String videoId) async {
    return BookmarkStorageHelper.getBookmarkStats(videoId);
  }

  /// 비디오별 북마크 개수 (헬퍼 위임)
  static Future<Map<String, int>> getBookmarkCountsByVideo() async {
    return BookmarkStorageHelper.getBookmarkCountsByVideo();
  }

  /// 북마크 정렬 (헬퍼 위임)
  static Future<List<Map<String, dynamic>>> getSortedBookmarks(
    String videoId, {
    bool ascending = true,
  }) async {
    return BookmarkStorageHelper.getSortedBookmarks(
      videoId,
      ascending: ascending,
    );
  }

  // ========== 통합 관리 메서드 ==========

  /// 모든 데이터 초기화
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyTricks);
      await prefs.remove(_keyVideoBookmarks);
      await prefs.remove(_keyVideoProgress);
      await prefs.remove(_keyYouTubeVideos);

      if (kDebugMode) {
        debugPrint('모든 펫 활동 데이터 초기화 완료');
      }
    } catch (e) {
      debugPrint('데이터 초기화 실패: $e');
      rethrow;
    }
  }

  /// 데이터 백업
  static Future<Map<String, dynamic>> backupData() async {
    try {
      final tricks = await getTricks();
      final videos = await getYouTubeVideos();
      final bookmarks = await getAllVideoBookmarks();

      return {
        'tricks': tricks,
        'videos': videos,
        'bookmarks': bookmarks,
        'backupDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('데이터 백업 실패: $e');
      rethrow;
    }
  }

  /// 데이터 복원
  static Future<void> restoreData(Map<String, dynamic> backupData) async {
    try {
      // 기존 데이터 초기화
      await clearAllData();

      // 트릭 복원
      final tricks = backupData['tricks'] as List<dynamic>? ?? [];
      for (final trick in tricks) {
        await addTrick(trick as Map<String, dynamic>);
      }

      // 비디오 복원
      final videos = backupData['videos'] as List<dynamic>? ?? [];
      for (final video in videos) {
        await addYouTubeVideo(video as Map<String, dynamic>);
      }

      // 북마크 복원
      final bookmarks = backupData['bookmarks'] as List<dynamic>? ?? [];
      for (final bookmark in bookmarks) {
        await addVideoBookmark(bookmark as Map<String, dynamic>);
      }

      if (kDebugMode) {
        debugPrint('데이터 복원 완료');
      }
    } catch (e) {
      debugPrint('데이터 복원 실패: $e');
      rethrow;
    }
  }

  /// 전체 통계
  static Future<Map<String, dynamic>> getOverallStats({String? petId}) async {
    try {
      final trickStats = await getTrickStats(petId: petId);
      final videoStats = await getVideoStats(petId: petId);
      final allBookmarks = await getAllVideoBookmarks();
      final bookmarkCounts = await getBookmarkCountsByVideo();

      return {
        'tricks': trickStats,
        'videos': videoStats,
        'bookmarks': {'total': allBookmarks.length, 'byVideo': bookmarkCounts},
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('전체 통계 생성 실패: $e');
      return {};
    }
  }
}
