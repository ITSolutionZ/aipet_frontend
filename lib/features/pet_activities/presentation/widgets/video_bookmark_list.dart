import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../data/providers/pet_activities_providers.dart';
import '../../domain/entities/video_bookmark_entity.dart';

/// 비디오 북마크 목록 위젯
class VideoBookmarkList extends ConsumerStatefulWidget {
  final String videoId;
  final String youtubeVideoId;
  final Function(VideoBookmarkEntity) onBookmarkTap;

  const VideoBookmarkList({
    super.key,
    required this.videoId,
    required this.youtubeVideoId,
    required this.onBookmarkTap,
  });

  @override
  ConsumerState<VideoBookmarkList> createState() => _VideoBookmarkListState();
}

class _VideoBookmarkListState extends ConsumerState<VideoBookmarkList> {
  final _labelController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _showAddBookmarkDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddBookmarkDialog(
        videoId: widget.videoId,
        youtubeVideoId: widget.youtubeVideoId,
        onAdd: _addBookmark,
      ),
    );
  }

  Future<void> _addBookmark(
    String label,
    int positionSec,
    String? description,
  ) async {
    try {
      final bookmark = VideoBookmarkEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        videoId: widget.videoId,
        youtubeVideoId: widget.youtubeVideoId,
        positionSec: positionSec,
        label: label.isNotEmpty ? label : null,
        description: description,
        createdAt: DateTime.now(),
      );

      final repository = ref.read(petActivitiesRepositoryProvider);
      await repository.addVideoBookmark(bookmark);

      // 북마크 목록 새로고침
      ref.refresh(videoBookmarksProvider(widget.videoId));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ブックマークが追加されました.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ブックマークの追加に失敗しました: $error')));
      }
    } finally {
      // Bookmark operation completed
    }
  }

  Future<void> _deleteBookmark(VideoBookmarkEntity bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('북마크 삭제'),
        content: Text('북마크 "${bookmark.displayLabel}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(petActivitiesRepositoryProvider);
        await repository.removeVideoBookmark(bookmark.id);

        ref.refresh(videoBookmarksProvider(widget.videoId));

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ブックマークが削除されました.')));
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ブックマークの削除に失敗しました: $error')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksState = ref.watch(videoBookmarksProvider(widget.videoId));

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
                  'Bookmarks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showAddBookmarkDialog,
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
                data: (bookmarks) => _buildBookmarkList(bookmarks),
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
                            ref.refresh(videoBookmarksProvider(widget.videoId)),
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

  Widget _buildBookmarkList(List<VideoBookmarkEntity> bookmarks) {
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
          onTap: () => widget.onBookmarkTap(bookmark),
          onDelete: () => _deleteBookmark(bookmark),
        );
      },
    );
  }
}

// 북마크 프로바이더 (임시로 생성)
final videoBookmarksProvider =
    FutureProvider.family<List<VideoBookmarkEntity>, String>((
      ref,
      videoId,
    ) async {
      final repository = ref.read(petActivitiesRepositoryProvider);
      return repository.getVideoBookmarks(videoId);
    });

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
              const SizedBox(height: 2),
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

/// 북마크 추가 다이얼로그
class _AddBookmarkDialog extends StatefulWidget {
  final String videoId;
  final String youtubeVideoId;
  final Function(String label, int positionSec, String? description) onAdd;

  const _AddBookmarkDialog({
    required this.videoId,
    required this.youtubeVideoId,
    required this.onAdd,
  });

  @override
  State<_AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<_AddBookmarkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minutesController = TextEditingController(text: '0');
  final _secondsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _labelController.dispose();
    _descriptionController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = minutes * 60 + seconds;

    widget.onAdd(
      _labelController.text.trim(),
      totalSeconds,
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ブックマークを追加'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 시간 입력
            Row(
              children: [
                const Text('時間: '),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: _minutesController,
                    decoration: const InputDecoration(
                      labelText: '分',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final num = int.tryParse(value ?? '');
                      if (num == null || num < 0) {
                        return '無効';
                      }
                      return null;
                    },
                  ),
                ),
                const Text(' : '),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: _secondsController,
                    decoration: const InputDecoration(
                      labelText: '秒',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final num = int.tryParse(value ?? '');
                      if (num == null || num < 0 || num >= 60) {
                        return '無効';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 라벨 입력
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'ラベル (任意)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // 설명 입력
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明 (任意)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('追加')),
      ],
    );
  }
}
