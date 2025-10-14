import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';

/// 비디오 북마크 필터링 헬퍼
class VideoBookmarkFilterHelper {
  /// 검색어로 북마크 필터링
  static List<VideoBookmarkEntity> filterBySearch(
    List<VideoBookmarkEntity> bookmarks,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return bookmarks;

    final lowerQuery = searchQuery.toLowerCase();
    return bookmarks.where((bookmark) {
      return bookmark.title.toLowerCase().contains(lowerQuery) ||
          (bookmark.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// 시간 범위로 북마크 필터링
  static List<VideoBookmarkEntity> filterByTimeRange(
    List<VideoBookmarkEntity> bookmarks,
    int? minSeconds,
    int? maxSeconds,
  ) {
    if (minSeconds == null && maxSeconds == null) return bookmarks;

    return bookmarks.where((bookmark) {
      if (minSeconds != null && bookmark.positionSec < minSeconds) return false;
      if (maxSeconds != null && bookmark.positionSec > maxSeconds) return false;
      return true;
    }).toList();
  }

  /// 최근 생성된 북마크만 필터링
  static List<VideoBookmarkEntity> filterRecent(
    List<VideoBookmarkEntity> bookmarks,
    Duration maxAge,
  ) {
    final cutoffTime = DateTime.now().subtract(maxAge);
    return bookmarks.where((bookmark) {
      return bookmark.createdAt.isAfter(cutoffTime);
    }).toList();
  }

  /// 설명이 있는 북마크만 필터링
  static List<VideoBookmarkEntity> filterWithDescription(
    List<VideoBookmarkEntity> bookmarks,
  ) {
    return bookmarks.where((bookmark) {
      return bookmark.description != null && bookmark.description!.isNotEmpty;
    }).toList();
  }
}
