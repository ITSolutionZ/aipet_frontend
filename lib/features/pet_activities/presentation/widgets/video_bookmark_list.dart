import 'package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart';
import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/features/pet_activities/presentation/widgets/helpers/helpers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 북마크 프로바이더
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
  (ref) => VideoBookmarkController(ref as WidgetRef),
);

class VideoBookmarkController {
  final WidgetRef ref;

  VideoBookmarkController(this.ref);

  /// 북마크 추가
  Future<void> addBookmark({
    required String videoId,
    required String title,
    required int positionSec,
    String? description,
  }) async {
    await VideoBookmarkCrudHelper.addBookmark(
      ref: ref,
      videoId: videoId,
      title: title,
      positionSec: positionSec,
      description: description,
    );
  }

  /// 북마크 삭제
  Future<void> deleteBookmark(String bookmarkId, String videoId) async {
    await VideoBookmarkCrudHelper.deleteBookmark(
      ref: ref,
      bookmarkId: bookmarkId,
      videoId: videoId,
    );
  }
}

/// 비디오 북마크 리스트 위젯
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
          VideoBookmarkUiHelper.buildHandle(),

          // 헤더
          VideoBookmarkUiHelper.buildHeader(
            onAddBookmark: () => _showAddBookmarkDialog(context, ref),
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
                data: (bookmarks) =>
                    _buildBookmarkList(bookmarks, context, ref),
                loading: () => VideoBookmarkUiHelper.buildLoadingState(),
                error: (error, stack) => VideoBookmarkUiHelper.buildErrorState(
                  error.toString(),
                  () => ref.refresh(videoBookmarksProvider(videoId)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList(
    List<VideoBookmarkEntity> bookmarks,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (bookmarks.isEmpty) {
      return VideoBookmarkUiHelper.buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return VideoBookmarkUiHelper.buildBookmarkItem(
          bookmark: bookmark,
          onTap: () => onBookmarkTap(bookmark),
          onDelete: () => _deleteBookmark(context, ref, bookmark),
        );
      },
    );
  }

  Future<void> _showAddBookmarkDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddBookmarkDialog(),
    );

    if (result != null && context.mounted) {
      try {
        await VideoBookmarkCrudHelper.addBookmark(
          ref: ref,
          videoId: videoId,
          title: result['title'] as String,
          positionSec: result['positionSec'] as int,
          description: result['description'] as String?,
        );

        VideoBookmarkCrudHelper.showSuccess(context, 'ブックマークが追加されました.');
      } catch (error) {
        VideoBookmarkCrudHelper.handleError(context, 'ブックマークの追加', error);
      }
    }
  }

  Future<void> _deleteBookmark(
    BuildContext context,
    WidgetRef ref,
    VideoBookmarkEntity bookmark,
  ) async {
    final confirmed =
        await VideoBookmarkCrudHelper.showDeleteConfirmationDialog(
          context,
          bookmark,
        );

    if (confirmed && context.mounted) {
      try {
        await VideoBookmarkCrudHelper.deleteBookmark(
          ref: ref,
          bookmarkId: bookmark.id,
          videoId: videoId,
        );

        VideoBookmarkCrudHelper.showSuccess(context, 'ブックマークが削除されました.');
      } catch (error) {
        VideoBookmarkCrudHelper.handleError(context, 'ブックマークの削除', error);
      }
    }
  }
}

/// 북마크 추가 다이얼로그
class _AddBookmarkDialog extends StatefulWidget {
  @override
  _AddBookmarkDialogState createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<_AddBookmarkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _positionController.dispose();
    super.dispose();
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: '位置 (秒)',
                border: OutlineInputBorder(),
                hintText: '例: 120',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '位置を入力してください';
                }
                final position = int.tryParse(value);
                if (position == null || position < 0) {
                  return '有効な位置を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明 (オプション)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text.trim(),
        'positionSec': int.parse(_positionController.text.trim()),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      });
    }
  }
}
