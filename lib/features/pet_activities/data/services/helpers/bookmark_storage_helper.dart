import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 북마크 저장소 헬퍼
class BookmarkStorageHelper {
  static const String _keyVideoBookmarks = 'video_bookmarks';

  /// 비디오 북마크 가져오기
  static Future<List<Map<String, dynamic>>> getVideoBookmarks(
    String videoId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_keyVideoBookmarks) ?? [];

      final bookmarks = bookmarksJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList()
          .where((bookmark) => bookmark['videoId'] == videoId)
          .toList();

      return bookmarks;
    } catch (e) {
      debugPrint('비디오 북마크 로드 실패: $e');
      return [];
    }
  }

  /// 비디오 북마크 추가
  static Future<void> addVideoBookmark(Map<String, dynamic> bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_keyVideoBookmarks) ?? [];

      if (bookmark['id'] == null || (bookmark['id'] as String).isEmpty) {
        bookmark['id'] = 'bookmark-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (bookmark['createdAt'] == null) {
        bookmark['createdAt'] = DateTime.now().toIso8601String();
      }

      if (bookmark['updatedAt'] == null) {
        bookmark['updatedAt'] = DateTime.now().toIso8601String();
      }

      bookmarks.add(jsonEncode(bookmark));
      await prefs.setStringList(_keyVideoBookmarks, bookmarks);

      if (kDebugMode) {
        debugPrint('비디오 북마크 추가 완료: ${bookmark['title']}');
      }
    } catch (e) {
      debugPrint('비디오 북마크 추가 실패: $e');
      rethrow;
    }
  }

  /// 비디오 북마크 업데이트
  static Future<void> updateVideoBookmark(
    String bookmarkId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_keyVideoBookmarks) ?? [];

      final updatedBookmarks = bookmarks.map((json) {
        final bookmark = jsonDecode(json) as Map<String, dynamic>;
        if (bookmark['id'] == bookmarkId) {
          bookmark.addAll(updates);
          bookmark['updatedAt'] = DateTime.now().toIso8601String();
        }
        return jsonEncode(bookmark);
      }).toList();

      await prefs.setStringList(_keyVideoBookmarks, updatedBookmarks);

      if (kDebugMode) {
        debugPrint('비디오 북마크 업데이트 완료: $bookmarkId');
      }
    } catch (e) {
      debugPrint('비디오 북마크 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 비디오 북마크 삭제
  static Future<void> deleteVideoBookmark(String bookmarkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList(_keyVideoBookmarks) ?? [];

      final filteredBookmarks = bookmarks.where((json) {
        final bookmark = jsonDecode(json) as Map<String, dynamic>;
        return bookmark['id'] != bookmarkId;
      }).toList();

      await prefs.setStringList(_keyVideoBookmarks, filteredBookmarks);

      if (kDebugMode) {
        debugPrint('비디오 북마크 삭제 완료: $bookmarkId');
      }
    } catch (e) {
      debugPrint('비디오 북마크 삭제 실패: $e');
      rethrow;
    }
  }

  /// 모든 비디오 북마크 가져오기
  static Future<List<Map<String, dynamic>>> getAllVideoBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(_keyVideoBookmarks) ?? [];

      final bookmarks = bookmarksJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      return bookmarks;
    } catch (e) {
      debugPrint('모든 비디오 북마크 로드 실패: $e');
      return [];
    }
  }

  /// 비디오 북마크 검색
  static Future<List<Map<String, dynamic>>> searchVideoBookmarks(
    String query,
  ) async {
    try {
      final allBookmarks = await getAllVideoBookmarks();
      final lowerQuery = query.toLowerCase();

      return allBookmarks.where((bookmark) {
        final title = (bookmark['title'] as String? ?? '').toLowerCase();
        final description = (bookmark['description'] as String? ?? '')
            .toLowerCase();

        return title.contains(lowerQuery) || description.contains(lowerQuery);
      }).toList();
    } catch (e) {
      debugPrint('비디오 북마크 검색 실패: $e');
      return [];
    }
  }

  /// 비디오 북마크 통계
  static Future<Map<String, int>> getBookmarkStats(String videoId) async {
    try {
      final bookmarks = await getVideoBookmarks(videoId);

      return {
        'total': bookmarks.length,
        'recent': bookmarks.where((b) {
          final createdAt = DateTime.tryParse(b['createdAt'] ?? '');
          if (createdAt == null) return false;
          return DateTime.now().difference(createdAt).inDays <= 7;
        }).length,
      };
    } catch (e) {
      debugPrint('비디오 북마크 통계 실패: $e');
      return {'total': 0, 'recent': 0};
    }
  }

  /// 비디오별 북마크 개수
  static Future<Map<String, int>> getBookmarkCountsByVideo() async {
    try {
      final allBookmarks = await getAllVideoBookmarks();
      final counts = <String, int>{};

      for (final bookmark in allBookmarks) {
        final videoId = bookmark['videoId'] as String? ?? '';
        counts[videoId] = (counts[videoId] ?? 0) + 1;
      }

      return counts;
    } catch (e) {
      debugPrint('비디오별 북마크 개수 실패: $e');
      return {};
    }
  }

  /// 북마크 정렬 (시간순)
  static Future<List<Map<String, dynamic>>> getSortedBookmarks(
    String videoId, {
    bool ascending = true,
  }) async {
    try {
      final bookmarks = await getVideoBookmarks(videoId);

      bookmarks.sort((a, b) {
        final aTime = a['positionSec'] as int? ?? 0;
        final bTime = b['positionSec'] as int? ?? 0;
        return ascending ? aTime.compareTo(bTime) : bTime.compareTo(aTime);
      });

      return bookmarks;
    } catch (e) {
      debugPrint('북마크 정렬 실패: $e');
      return [];
    }
  }

  /// 북마크 중복 제거
  static Future<void> removeDuplicateBookmarks() async {
    try {
      final allBookmarks = await getAllVideoBookmarks();
      final uniqueBookmarks = <String, Map<String, dynamic>>{};

      for (final bookmark in allBookmarks) {
        final key = '${bookmark['videoId']}_${bookmark['positionSec']}';
        if (!uniqueBookmarks.containsKey(key)) {
          uniqueBookmarks[key] = bookmark;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final uniqueBookmarksJson = uniqueBookmarks.values
          .map((bookmark) => jsonEncode(bookmark))
          .toList();

      await prefs.setStringList(_keyVideoBookmarks, uniqueBookmarksJson);

      if (kDebugMode) {
        debugPrint(
          '북마크 중복 제거 완료: ${allBookmarks.length - uniqueBookmarks.length}개 제거',
        );
      }
    } catch (e) {
      debugPrint('북마크 중복 제거 실패: $e');
      rethrow;
    }
  }
}
