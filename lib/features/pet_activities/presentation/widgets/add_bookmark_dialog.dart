import 'package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 북마크 추가 다이얼로그
class AddBookmarkDialog extends StatefulWidget {
  final String videoId;
  final int currentPositionSec;
  final Function(VideoBookmarkEntity) onBookmarkAdded;

  const AddBookmarkDialog({
    super.key,
    required this.videoId,
    required this.currentPositionSec,
    required this.onBookmarkAdded,
  });

  @override
  State<AddBookmarkDialog> createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _positionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _positionController = TextEditingController(
      text: _formatTime(widget.currentPositionSec),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _parseTime(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      // MM:SS 형식
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    } else if (parts.length == 3) {
      // HH:MM:SS 형식
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      final seconds = int.tryParse(parts[2]) ?? 0;
      return hours * 3600 + minutes * 60 + seconds;
    }
    return 0;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final positionSec = _parseTime(_positionController.text.trim());

    if (title.isEmpty) {
      UiService.showError(context, '북마크 제목을 입력해주세요');
      return;
    }

    final now = DateTime.now();
    final bookmark = VideoBookmarkEntity(
      id: 'bookmark_${now.millisecondsSinceEpoch}',
      videoId: widget.videoId,
      title: title,
      description: description.isNotEmpty ? description : null,
      positionSec: positionSec,
      createdAt: now,
      updatedAt: now,
    );

    widget.onBookmarkAdded(bookmark);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('북마크 추가'),
      contentPadding: const EdgeInsets.all(AppSpacing.lg),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 제목 입력
              _buildTitleField(),
              const SizedBox(height: AppSpacing.md),

              // 설명 입력
              _buildDescriptionField(),
              const SizedBox(height: AppSpacing.md),

              // 위치 입력
              _buildPositionField(),
              const SizedBox(height: AppSpacing.md),

              // 현재 위치 정보
              _buildCurrentPositionInfo(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('추가')),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('북마크 제목 *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '예: 앉기 트릭 시작',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '북마크 제목을 입력해주세요';
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
            hintText: '북마크에 대한 설명 (선택사항)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPositionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '위치 (MM:SS 또는 HH:MM:SS)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _positionController,
          decoration: const InputDecoration(
            hintText: '예: 1:30 또는 0:01:30',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '위치를 입력해주세요';
            }
            final positionSec = _parseTime(value.trim());
            if (positionSec < 0) {
              return '올바른 시간 형식을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCurrentPositionInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.pointBrown),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '현재 위치: ${_formatTime(widget.currentPositionSec)}',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _positionController.text = _formatTime(widget.currentPositionSec);
            },
            child: const Text('현재 위치 사용'),
          ),
        ],
      ),
    );
  }
}
