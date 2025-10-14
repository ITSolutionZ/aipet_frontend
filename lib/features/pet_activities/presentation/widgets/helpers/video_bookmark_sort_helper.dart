import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';

/// 북마크 정렬 옵션
enum SortOption {
  positionAsc, // 시간 순 (오름차순)
  positionDesc, // 시간 순 (내림차순)
  titleAsc, // 제목 순 (오름차순)
  titleDesc, // 제목 순 (내림차순)
  createdAtAsc, // 생성일 순 (오름차순)
  createdAtDesc, // 생성일 순 (내림차순)
}

/// 비디오 북마크 정렬 헬퍼
class VideoBookmarkSortHelper {
  /// 북마크 목록 정렬
  static List<VideoBookmarkEntity> sortBookmarks(
    List<VideoBookmarkEntity> bookmarks,
    SortOption sortOption,
  ) {
    final sortedBookmarks = List<VideoBookmarkEntity>.from(bookmarks);

    switch (sortOption) {
      case SortOption.positionAsc:
        sortedBookmarks.sort((a, b) => a.positionSec.compareTo(b.positionSec));
        break;
      case SortOption.positionDesc:
        sortedBookmarks.sort((a, b) => b.positionSec.compareTo(a.positionSec));
        break;
      case SortOption.titleAsc:
        sortedBookmarks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleDesc:
        sortedBookmarks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.createdAtAsc:
        sortedBookmarks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.createdAtDesc:
        sortedBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sortedBookmarks;
  }

  /// 기본 정렬 (시간 순 오름차순)
  static List<VideoBookmarkEntity> sortByDefault(
    List<VideoBookmarkEntity> bookmarks,
  ) {
    return sortBookmarks(bookmarks, SortOption.positionAsc);
  }

  /// 정렬 옵션의 표시 텍스트
  static String getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.positionAsc:
        return '時間順 (昇順)';
      case SortOption.positionDesc:
        return '時間順 (降順)';
      case SortOption.titleAsc:
        return 'タイトル順 (昇順)';
      case SortOption.titleDesc:
        return 'タイトル順 (降順)';
      case SortOption.createdAtAsc:
        return '作成日順 (昇順)';
      case SortOption.createdAtDesc:
        return '作成日順 (降順)';
    }
  }
}
