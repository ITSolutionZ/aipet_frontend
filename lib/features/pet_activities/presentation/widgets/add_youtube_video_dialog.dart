import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/youtube_video_entity.dart';

/// YouTube 비디오 추가 다이얼로그
class AddYouTubeVideoDialog extends StatefulWidget {
  final String petId;

  const AddYouTubeVideoDialog({super.key, required this.petId});

  @override
  State<AddYouTubeVideoDialog> createState() => _AddYouTubeVideoDialogState();
}

class _AddYouTubeVideoDialogState extends State<AddYouTubeVideoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _tags = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _validateYouTubeUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final videoId = YouTubeVideoEntity.extractVideoId(url);
    if (videoId == null) {
      _showError('유효하지 않은 YouTube URL입니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // YouTube API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));

      // 제목이 비어있다면 자동으로 채우기
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = MockDataService.getDefaultVideoTitle(videoId);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('유효한 YouTube URL입니다!')));
      }
    } catch (error) {
      _showError('YouTube 비디오 정보를 가져올 수 없습니다.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final videoId = YouTubeVideoEntity.extractVideoId(url);

    if (videoId == null) {
      _showError('유효하지 않은 YouTube URL입니다.');
      return;
    }

    Navigator.pop(context, {
      'url': url,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'tags': _tags,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('YouTube 비디오 추가'),
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
                if (_tags.isNotEmpty) _buildTagList(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('추가'),
        ),
      ],
    );
  }

  Widget _buildUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YouTube URL *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              return 'YouTube URL을 입력해주세요.';
            }
            final videoId = YouTubeVideoEntity.extractVideoId(value.trim());
            if (videoId == null) {
              return '유효하지 않은 YouTube URL입니다.';
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
        const Text('제목 *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '비디오 제목을 입력하세요',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요.';
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

  Widget _buildTagList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추가된 태그:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: _tags
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
