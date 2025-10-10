import 'package:aipet_frontend/features/pet_activities/data/services/pet_activities_local_storage_service.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';

/// 북마크 리포지토리 헬퍼
class BookmarkRepositoryHelper {
  /// 비디오 북마크 가져오기
  static Future<List<VideoBookmarkEntity>> getVideoBookmarks(
    String videoId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final bookmarksData =
        await PetActivitiesLocalStorageService.getVideoBookmarks(videoId);

    return bookmarksData
        .map((bookmarkData) => _mapBookmarkDataToEntity(bookmarkData))
        .toList();
  }

  /// 비디오 북마크 추가
  static Future<void> addVideoBookmark(VideoBookmarkEntity bookmark) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final bookmarkData = {
      'id': bookmark.id,
      'videoId': bookmark.videoId,
      'title': bookmark.title,
      'description': bookmark.description,
      'positionSec': bookmark.positionSec,
      'createdAt': bookmark.createdAt.toIso8601String(),
      'updatedAt': bookmark.updatedAt.toIso8601String(),
    };

    await PetActivitiesLocalStorageService.addVideoBookmark(bookmarkData);
  }

  /// 비디오 북마크 업데이트
  static Future<void> updateVideoBookmark(
    String bookmarkId,
    VideoBookmarkEntity updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final updateData = {
      'title': updates.title,
      'description': updates.description,
      'positionSec': updates.positionSec,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await PetActivitiesLocalStorageService.updateVideoBookmark(
      bookmarkId,
      updateData,
    );
  }

  /// 비디오 북마크 삭제
  static Future<void> removeVideoBookmark(String bookmarkId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await PetActivitiesLocalStorageService.deleteVideoBookmark(bookmarkId);
  }

  /// 모든 비디오 북마크 가져오기
  static Future<List<VideoBookmarkEntity>> getAllVideoBookmarks() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final bookmarksData =
        await PetActivitiesLocalStorageService.getAllVideoBookmarks();

    return bookmarksData
        .map((bookmarkData) => _mapBookmarkDataToEntity(bookmarkData))
        .toList();
  }

  /// 비디오 북마크 검색
  static Future<List<VideoBookmarkEntity>> searchVideoBookmarks(
    String query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final bookmarksData =
        await PetActivitiesLocalStorageService.searchVideoBookmarks(query);
    return bookmarksData
        .map((bookmarkData) => _mapBookmarkDataToEntity(bookmarkData))
        .toList();
  }

  /// 비디오 북마크 통계
  static Future<Map<String, int>> getBookmarkStats(String videoId) async {
    return PetActivitiesLocalStorageService.getBookmarkStats(videoId);
  }

  /// 비디오별 북마크 개수
  static Future<Map<String, int>> getBookmarkCountsByVideo() async {
    return PetActivitiesLocalStorageService.getBookmarkCountsByVideo();
  }

  /// 북마크 정렬
  static Future<List<VideoBookmarkEntity>> getSortedBookmarks(
    String videoId, {
    bool ascending = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final bookmarksData =
        await PetActivitiesLocalStorageService.getSortedBookmarks(
          videoId,
          ascending: ascending,
        );

    return bookmarksData
        .map((bookmarkData) => _mapBookmarkDataToEntity(bookmarkData))
        .toList();
  }

  /// 북마크 데이터를 엔티티로 매핑
  static VideoBookmarkEntity _mapBookmarkDataToEntity(
    Map<String, dynamic> bookmarkData,
  ) {
    return VideoBookmarkEntity(
      id: bookmarkData['id'] as String,
      videoId: bookmarkData['videoId'] as String,
      title: bookmarkData['title'] as String,
      description: bookmarkData['description'] as String?,
      positionSec: bookmarkData['positionSec'] as int,
      createdAt: DateTime.parse(bookmarkData['createdAt'] as String),
      updatedAt: bookmarkData['updatedAt'] != null
          ? DateTime.parse(bookmarkData['updatedAt'] as String)
          : DateTime.parse(bookmarkData['createdAt'] as String),
    );
  }
}
