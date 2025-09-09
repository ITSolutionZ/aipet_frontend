import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../walk.dart';

class EditWalkBottomSheet extends StatefulWidget {
  final WalkRecordEntity walkRecord;
  final WalkController controller;

  const EditWalkBottomSheet({
    super.key,
    required this.walkRecord,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context,
    WalkRecordEntity walkRecord,
    WalkController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) =>
          EditWalkBottomSheet(walkRecord: walkRecord, controller: controller),
    );
  }

  @override
  State<EditWalkBottomSheet> createState() => _EditWalkBottomSheetState();
}

class _EditWalkBottomSheetState extends State<EditWalkBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  String? _selectedCoManagerId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.walkRecord.title);
    _notesController = TextEditingController(
      text: widget.walkRecord.notes ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.large),
          topRight: Radius.circular(AppRadius.large),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '散歩記録を編集',
                style: AppFonts.point(
                  fontSize: AppFonts.xxl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.walkRecord.petName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pointGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pets,
                        size: 16,
                        color: AppColors.pointGreen,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${widget.walkRecord.petName}との散歩',
                        style: AppFonts.base(
                          fontSize: AppFonts.sm,
                          color: AppColors.pointGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: '散歩のタイトル',
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'タイトルを入力してください。';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'メモ',
                        prefixIcon: const Icon(Icons.pets),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: '今日の散歩はどうでしたか？',
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildCoManagerSection(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      '散歩の詳細',
                      style: AppFonts.point(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildTimeRow(),
                          const SizedBox(height: AppSpacing.md),
                          _buildDistanceRow(),
                          if (widget.walkRecord.route.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            _buildInfoRow(
                              'ルートポイント',
                              '${widget.walkRecord.route.length}箇所',
                              Icons.location_on,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (widget.walkRecord.createdAt != null)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.pointBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: AppColors.pointBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.pointBlue,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '記録日時: ${_formatDate(widget.walkRecord.createdAt!)}',
                              style: AppFonts.base(
                                fontSize: AppFonts.sm,
                                color: AppColors.pointBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(fontSize: AppFonts.baseSize),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateWalk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child: const Text(
                        '更新',
                        style: TextStyle(
                          fontSize: AppFonts.baseSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    final endTimeString = widget.walkRecord.endTime != null
        ? '${widget.walkRecord.endTime!.hour.toString().padLeft(2, '0')}:${widget.walkRecord.endTime!.minute.toString().padLeft(2, '0')}'
        : '進行中';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: const Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.pointBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '開始時間',
                      style: AppFonts.base(
                        fontSize: AppFonts.sm,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.walkRecord.timeString,
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.pointBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '完了時間',
                            style: AppFonts.base(
                              fontSize: AppFonts.sm,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            endTimeString,
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.lg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: const Icon(
            Icons.route_rounded,
            size: 16,
            color: AppColors.pointBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '総距離',
                      style: AppFonts.base(
                        fontSize: AppFonts.sm,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.walkRecord.formattedDistance,
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.timer,
                        size: 14,
                        color: AppColors.pointBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '経過時間',
                            style: AppFonts.base(
                              fontSize: AppFonts.sm,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.walkRecord.formattedDuration,
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.lg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, size: 16, color: AppColors.pointBlue),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppFonts.base(
                  fontSize: AppFonts.sm,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: AppFonts.fredoka(
                  fontSize: AppFonts.lg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoManagerSection() {
    // 공동관리자 목록 (실제로는 API에서 가져와야 함)
    final coManagers = [
      {'id': 'co1', 'name': '田中さん', 'avatar': '👩'},
      {'id': 'co2', 'name': '佐藤さん', 'avatar': '👨'},
      {'id': 'co3', 'name': '山田さん', 'avatar': '👨‍💼'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '共同管理者（任意）',
          style: AppFonts.point(
            fontSize: AppFonts.lg,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildCoManagerOption(null, '記録者のみ', Icons.person, '自分だけの記録'),
              const SizedBox(height: AppSpacing.sm),
              ...coManagers.map(
                (manager) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildCoManagerOption(
                    manager['id'] as String,
                    manager['name'] as String,
                    Icons.people,
                    '${manager['avatar']} 共同管理',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoManagerOption(
    String? managerId,
    String name,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedCoManagerId == managerId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCoManagerId = managerId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointGreen.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pointGreen : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.baseSize,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.pointGreen
                          : Colors.grey[800],
                    ),
                  ),
                  Text(
                    description,
                    style: AppFonts.base(
                      fontSize: AppFonts.sm,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pointGreen,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _updateWalk() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 수정된 산책 기록 생성
        final updatedWalkRecord = WalkRecordEntity(
          id: widget.walkRecord.id,
          title: _titleController.text,
          startTime: widget.walkRecord.startTime,
          endTime: widget.walkRecord.endTime,
          distance: widget.walkRecord.distance,
          duration: widget.walkRecord.duration,
          route: widget.walkRecord.route,
          petId: widget.walkRecord.petId,
          petName: widget.walkRecord.petName,
          petImage: widget.walkRecord.petImage,
          ownerId: widget.walkRecord.ownerId,
          ownerName: widget.walkRecord.ownerName,
          ownerAvatar: widget.walkRecord.ownerAvatar,
          status: widget.walkRecord.status,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          createdAt: widget.walkRecord.createdAt,
          updatedAt: DateTime.now(),
        );

        // 컨트롤러를 통해 수정
        await widget.controller.updateWalkRecord(updatedWalkRecord);

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('散歩記録が更新されました'),
              backgroundColor: AppColors.pointGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('更新に失敗しました: $e'),
              backgroundColor: AppColors.pointPink,
            ),
          );
        }
      }
    }
  }
}
