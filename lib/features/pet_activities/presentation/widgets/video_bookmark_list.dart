import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 북마크 프로바이더 (임시로 생성)
final videoBookmarksProvider =
    FutureProvider.family<List<VideoBookmarkEntity>, String>((
      ref,
      videoId,
    ) async {
      final repository = ref.read(petActivitiesRepositoryProvider);
      return repository.getVideoBookmarks(videoId);
    });

/// 🎯 Video Bookmark 관리 Provider
final videoBookmarkControllerProvider = Provider<VideoBookmarkController>(
  (ref) => VideoBookmarkController(ref),
);

class VideoBookmarkController {
  final Ref ref;

  VideoBookmarkController(this.ref);

  /// 북마크 추가
  Future<void> addBookmark({
    required String videoId,
    required String youtubeVideoId,
    required String label,
    required int positionSec,
    String? description,
  }) async {
    final bookmark = VideoBookmarkEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      youtubeVideoId: youtubeVideoId,
      positionSec: positionSec,
      label: label.isNotEmpty ? label : null,
      description: description,
      createdAt: DateTime.now(),
    );

    final repository = ref.read(petActivitiesRepositoryProvider);
    await repository.addVideoBookmark(bookmark);

    // 북마크 목록 새로고침
    ref.invalidate(videoBookmarksProvider(videoId));
  }

  /// 북마크 삭제
  Future<void> deleteBookmark(String bookmarkId, String videoId) async {
    final repository = ref.read(petActivitiesRepositoryProvider);
    await repository.removeVideoBookmark(bookmarkId);

    ref.invalidate(videoBookmarksProvider(videoId));
  }
}

/// 비디오 북마크 목록 위젯
class VideoBookmarkList extends ConsumerWidget {
  final String videoId;
  final String youtubeVideoId;
  final Function(VideoBookmarkEntity) onBookmarkTap;

  const VideoBookmarkList({
    super.key,
    required this.videoId,
    required this.youtubeVideoId,
    required this.onBookmarkTap,
  });

  void _showAddBookmarkDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddBookmarkDialog(
        videoId: videoId,
        youtubeVideoId: youtubeVideoId,
        onAdd: (label, positionSec, description) =>
            _addBookmark(context, ref, label, positionSec, description),
      ),
    );
  }

  Future<void> _addBookmark(
    BuildContext context,
    WidgetRef ref,
    String label,
    int positionSec,
    String? description,
  ) async {
    try {
      await ref.read(videoBookmarkControllerProvider).addBookmark(
        videoId: videoId,
        youtubeVideoId: youtubeVideoId,
        label: label,
        positionSec: positionSec,
        description: description,
      );

      if (context.mounted) {
        UiService.showSuccess(context, 'ブックマークが追加されました.');
      }
    } catch (error) {
      if (context.mounted) {
        UiService.showError(context, 'ブックマークの追加に失敗しました: $error');
      }
    }
  }

  Future<void> _deleteBookmark(
    BuildContext context,
    WidgetRef ref,
    VideoBookmarkEntity bookmark,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ブックマークを削除'),
        content: Text('ブックマーク"${bookmark.displayLabel}"を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(videoBookmarkControllerProvider).deleteBookmark(
          bookmark.id,
          videoId,
        );

        if (context.mounted) {
          UiService.showSuccess(context, 'ブックマークが削除されました.');
        }
      } catch (error) {
        if (context.mounted) {
          UiService.showError(context, 'ブックマークの削除に失敗しました: $error');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksState = ref.watch(videoBookmarksProvider(videoId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Text(
                  'ブックマーク',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddBookmarkDialog(context, ref),
                  icon: const Icon(Icons.add),
                  tooltip: 'ブックマークを追加',
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 북마크 목록
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.large),
                  topRight: Radius.circular(AppRadius.large),
                ),
              ),
              child: bookmarksState.when(
                data: (bookmarks) => _buildBookmarkList(bookmarks, context, ref),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('ブックマークの読み込みに失敗しました: $error'),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(videoBookmarksProvider(videoId)),
                        child: const Text('再試行'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList(List<VideoBookmarkEntity> bookmarks, BuildContext context, WidgetRef ref) {
    if (bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
            SizedBox(height: AppSpacing.md),
            Text(
              'ブックマークがありません',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'ビデオの特定のモーメントにすばやく移動するには、ブックマークを追加してください',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: bookmarks.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _BookmarkCard(
          bookmark: bookmark,
          onTap: () => onBookmarkTap(bookmark),
          onDelete: () => _deleteBookmark(context, ref, bookmark),
        );
      },
    );
  }
}

/// 북마크 카드 위젯
class _BookmarkCard extends StatelessWidget {
  final VideoBookmarkEntity bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: const Icon(
            Icons.bookmark,
            color: AppColors.pointBlue,
            size: 20,
          ),
        ),
        title: Text(
          bookmark.displayLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookmark.formattedTime,
              style: TextStyle(
                color: AppColors.pointDark.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            if (bookmark.description?.isNotEmpty == true) ...[
              const const const SizedBox(height: 2),
              Text(
                bookmark.description!,
                style: TextStyle(
                  color: AppColors.pointDark.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// 🎯 북마크 추가 Form State Provider
final bookmarkFormControllerProvider = StateNotifierProvider<BookmarkFormController, BookmarkFormState>(
  (ref) => BookmarkFormController(),
);

class BookmarkFormController extends StateNotifier<BookmarkFormState> {
  BookmarkFormController() : super(
    const BookmarkFormState(
      label: '',
      description: '',
      minutes: 0,
      seconds: 0,
      isValid: true,
    ),
  );

  void updateLabel(String label) {
    final newState = state.copyWith(label: label);
    state = newState.copyWith(isValid: _isFormValid(newState));
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateMinutes(int minutes) {
    final newState = state.copyWith(minutes: minutes);
    state = newState.copyWith(isValid: _isFormValid(newState));
  }

  void updateSeconds(int seconds) {
    final newState = state.copyWith(seconds: seconds);
    state = newState.copyWith(isValid: _isFormValid(newState));
  }

  bool _isFormValid(BookmarkFormState checkState) {
    return checkState.minutes >= 0 && checkState.seconds >= 0 && checkState.seconds < 60;
  }

  int get totalSeconds => state.minutes * 60 + state.seconds;
}

/// 북마크 Form 상태
class BookmarkFormState {
  final String label;
  final String description;
  final int minutes;
  final int seconds;
  final bool isValid;

  const BookmarkFormState({
    required this.label,
    required this.description,
    required this.minutes,
    required this.seconds,
    required this.isValid,
  });

  BookmarkFormState copyWith({
    String? label,
    String? description,
    int? minutes,
    int? seconds,
    bool? isValid,
  }) {
    return BookmarkFormState(
      label: label ?? this.label,
      description: description ?? this.description,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      isValid: isValid ?? this.isValid,
    );
  }
}

/// 북마크 추가 다이얼로그
class _AddBookmarkDialog extends ConsumerWidget {
  final String videoId;
  final String youtubeVideoId;
  final Function(String label, int positionSec, String? description) onAdd;

  const _AddBookmarkDialog({
    required this.videoId,
    required this.youtubeVideoId,
    required this.onAdd,
  });

  void _submit(BuildContext context, WidgetRef ref) {
    final formController = ref.read(bookmarkFormControllerProvider.notifier);
    final formState = ref.read(bookmarkFormControllerProvider);

    if (!formState.isValid) return;

    onAdd(
      formState.label.trim(),
      formController.totalSeconds,
      formState.description.trim().isEmpty
          ? null
          : formState.description.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(bookmarkFormControllerProvider);
    final formController = ref.read(bookmarkFormControllerProvider.notifier);

    return AlertDialog(
      title: const Text('ブックマークを追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 시간 입력
          Row(
            children: [
              const Text('時間: '),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: formState.minutes.toString(),
                  decoration: const InputDecoration(
                    labelText: '分',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final minutes = int.tryParse(value) ?? 0;
                    formController.updateMinutes(minutes);
                  },
                ),
              ),
              const Text(' : '),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: formState.seconds.toString(),
                  decoration: const InputDecoration(
                    labelText: '秒',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final seconds = int.tryParse(value) ?? 0;
                    formController.updateSeconds(seconds);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 라벨 입력
          TextFormField(
            initialValue: formState.label,
            decoration: const InputDecoration(
              labelText: 'ラベル (任意)',
              border: OutlineInputBorder(),
            ),
            onChanged: formController.updateLabel,
          ),

          const SizedBox(height: AppSpacing.md),

          // 설명 입력
          TextFormField(
            initialValue: formState.description,
            decoration: const InputDecoration(
              labelText: '説明 (任意)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: formController.updateDescription,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: formState.isValid ? () => _submit(context, ref) : null,
          child: const Text('追加'),
        ),
      ],
    );
  }
}
