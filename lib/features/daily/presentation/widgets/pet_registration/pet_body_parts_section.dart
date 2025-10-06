import 'package:aipet_frontend/shared/shared.dart' hide State;
import 'package:flutter/material.dart';

/// 펫 신체 부위 관리 섹션
class PetBodyPartsSection extends StatefulWidget {
  final String bodyPartsToManage;
  final Function(String) onUpdateBodyParts;
  final VoidCallback onClearBodyParts;

  const PetBodyPartsSection({
    super.key,
    required this.bodyPartsToManage,
    required this.onUpdateBodyParts,
    required this.onClearBodyParts,
  });

  @override
  State<PetBodyPartsSection> createState() => _PetBodyPartsSectionState();
}

class _PetBodyPartsSectionState extends State<PetBodyPartsSection> {
  late TextEditingController _bodyPartsController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _bodyPartsController = TextEditingController(
      text: widget.bodyPartsToManage,
    );
  }

  @override
  void didUpdateWidget(PetBodyPartsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bodyPartsToManage != widget.bodyPartsToManage) {
      _bodyPartsController.text = widget.bodyPartsToManage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              const Icon(
                Icons.health_and_safety_outlined,
                color: AppColors.pointGreen,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '気になる身体部位',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.bodyPartsToManage.isNotEmpty)
                IconButton(
                  onPressed: _toggleEditing,
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit,
                    color: AppColors.pointGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 설명 텍스트
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.pointGreen.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              'ペットの健康管理で特に気になる身体部位や症状を記録してください。\n今後の問診でも活用されます。',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 텍스트에어리어 또는 표시 영역
          if (_isEditing || widget.bodyPartsToManage.isEmpty) ...[
            // 편집 모드
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.borderGray.withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: TextField(
                controller: _bodyPartsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '例：左足の関節、皮膚の痒み、食欲不振など...',
                  hintStyle: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                ),
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveBodyParts,
                    icon: const Icon(Icons.save, size: 20),
                    label: const Text('保存'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pointGreen,
                      side: const BorderSide(color: AppColors.pointGreen),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearBodyParts,
                    icon: const Icon(Icons.clear, size: 20),
                    label: const Text('クリア'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // 표시 모드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: AppColors.borderGray.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                widget.bodyPartsToManage,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 편집 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleEditing,
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('編集'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                ),
              ),
            ),
          ],
        ],
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _bodyPartsController.text = widget.bodyPartsToManage;
      }
    });
  }

  void _saveBodyParts() {
    final text = _bodyPartsController.text.trim();
    widget.onUpdateBodyParts(text);
    setState(() {
      _isEditing = false;
    });
  }

  void _clearBodyParts() {
    _bodyPartsController.clear();
    widget.onClearBodyParts();
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _bodyPartsController.dispose();
    super.dispose();
  }
}
