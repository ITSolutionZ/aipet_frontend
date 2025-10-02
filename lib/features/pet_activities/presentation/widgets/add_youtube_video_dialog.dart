import 'package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Add YouTube Video Dialog State Provider
final addYouTubeVideoDialogProvider =
    StateNotifierProvider<AddYouTubeVideoDialogController, AddYouTubeVideoDialogState>(
      (ref) => AddYouTubeVideoDialogController(),
    );

class AddYouTubeVideoDialogController extends StateNotifier<AddYouTubeVideoDialogState> {
  AddYouTubeVideoDialogController() : super(const AddYouTubeVideoDialogState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !state.tags.contains(tag)) {
      state = state.copyWith(tags: [...state.tags, tag]);
    }
  }

  void removeTag(String tag) {
    final newTags = state.tags.where((t) => t != tag).toList();
    state = state.copyWith(tags: newTags);
  }

  void resetForm() {
    state = const AddYouTubeVideoDialogState();
  }
}

class AddYouTubeVideoDialogState {
  final bool isLoading;
  final List<String> tags;

  const AddYouTubeVideoDialogState({this.isLoading = false, this.tags = const []});

  AddYouTubeVideoDialogState copyWith({bool? isLoading, List<String>? tags}) {
    return AddYouTubeVideoDialogState(
      isLoading: isLoading ?? this.isLoading,
      tags: tags ?? this.tags,
    );
  }
}

/// YouTube 비디오 추가 다이얼로그
class AddYouTubeVideoDialog extends ConsumerWidget {
  final String petId;

  const AddYouTubeVideoDialog({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AddYouTubeVideoDialogContent(petId: petId);
  }
}

class _AddYouTubeVideoDialogContent extends ConsumerStatefulWidget {
  final String petId;

  const _AddYouTubeVideoDialogContent({required this.petId});

  @override
  ConsumerState<_AddYouTubeVideoDialogContent> createState() =>
      _AddYouTubeVideoDialogContentState();
}

class _AddYouTubeVideoDialogContentState extends ConsumerState<_AddYouTubeVideoDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    // Reset the form state
    ref.read(addYouTubeVideoDialogProvider.notifier).resetForm();
    super.dispose();
  }

  Future<void> _validateYouTubeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final videoId = YouTubeVideoEntity.extractVideoId(url);
    if (videoId == null) {
      _showError('無効なYouTube URLです。');
      return;
    }

    ref.read(addYouTubeVideoDialogProvider.notifier).setLoading(true);

    try {
      // YouTube API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));

      // 제목이 비어있다면 자동으로 채우기
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = 'YouTube Video $videoId';
      }

      if (mounted) {
        UiService.showSuccess(context, '有効なYouTube URLです！');
      }
    } catch (error) {
      _showError('YouTubeビデオ情報を取得できませんでした。');
    } finally {
      ref.read(addYouTubeVideoDialogProvider.notifier).setLoading(false);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      ref.read(addYouTubeVideoDialogProvider.notifier).addTag(tag);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    ref.read(addYouTubeVideoDialogProvider.notifier).removeTag(tag);
  }

  void _showError(String message) {
    UiService.showError(context, message);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final videoId = YouTubeVideoEntity.extractVideoId(url);

    if (videoId == null) {
      _showError('無効なYouTube URLです。');
      return;
    }

    final state = ref.read(addYouTubeVideoDialogProvider);

    Navigator.pop(context, {
      'url': url,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'tags': state.tags,
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addYouTubeVideoDialogProvider);

    return AlertDialog(
      title: const Text('YouTubeビデオを追加'),
      contentPadding: const EdgeInsets.all(AppSpacing.lg),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // YouTube URL 입력
                _buildUrlField(),
                const SizedBox(height: AppSpacing.md),

                // 제목 입력
                _buildTitleField(),
                const SizedBox(height: AppSpacing.md),

                // 설명 입력
                _buildDescriptionField(),
                const SizedBox(height: AppSpacing.md),

                // 태그 입력
                _buildTagField(),
                const SizedBox(height: AppSpacing.sm),

                // 태그 목록
                if (state.tags.isNotEmpty) _buildTagList(state.tags),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
        ElevatedButton(
          onPressed: state.isLoading ? null : _submit,
          child: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('追加'),
        ),
      ],
    );
  }

  Widget _buildUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YouTube URL *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: 'https://www.youtube.com/watch?v=...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'YouTube URLを入力してください。';
            }
            final videoId = YouTubeVideoEntity.extractVideoId(value.trim());
            if (videoId == null) {
              return '無効なYouTube URLです。';
            }
            return null;
          },
          onChanged: (value) {
            // URL이 변경될 때마다 자동 검증 (디바운스 적용 권장)
            if (value.trim().isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (_urlController.text.trim() == value.trim()) {
                  _validateYouTubeUrl();
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('タイトル *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'ビデオタイトルを入力してください',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'タイトルを入力してください。';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('설명', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: '비디오에 대한 설명을 입력하세요 (선택사항)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTagField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('태그', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: '태그를 입력하세요 (예: sit, stay, roll)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onFieldSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: _addTag,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('추가'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagList(List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('추가된 태그:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: tags
              .map(
                (tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
