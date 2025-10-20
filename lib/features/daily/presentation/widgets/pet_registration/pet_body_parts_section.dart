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
  // 미리 정의된 신체 부위 옵션
  static const List<String> _predefinedBodyParts = [
    '目', // 눈
    '耳', // 귀
    '鼻', // 코
    '口・歯', // 입/치아
    '皮膚', // 피부
    '足・関節', // 발/관절
    'お腹', // 배
    '心臓', // 심장
    '呼吸器', // 호흡기
  ];

  List<String> _selectedBodyParts = [];
  final List<TextEditingController> _customControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedBodyParts();
  }

  void _loadSelectedBodyParts() {
    if (widget.bodyPartsToManage.isNotEmpty) {
      final parts = widget.bodyPartsToManage.split(',').map((e) => e.trim()).toList();
      _selectedBodyParts = parts.where((p) => _predefinedBodyParts.contains(p)).toList();
      
      // 커스텀 항목 로드
      final customParts = parts.where((p) => !_predefinedBodyParts.contains(p)).toList();
      if (customParts.isNotEmpty) {
        _customControllers[0].text = customParts[0];
      }
      if (customParts.length > 1) {
        _customControllers[1].text = customParts[1];
      }
    }
  }

  @override
  void didUpdateWidget(PetBodyPartsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bodyPartsToManage != widget.bodyPartsToManage) {
      _loadSelectedBodyParts();
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
            'ペットの健康管理で特に気になる身体部位を選択してください。\nその他の項目は最大2個まで追加できます。',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 미리 정의된 신체 부위 칩
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _predefinedBodyParts.map((bodyPart) {
            final isSelected = _selectedBodyParts.contains(bodyPart);
            return FilterChip(
              label: Text(bodyPart),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedBodyParts.add(bodyPart);
                  } else {
                    _selectedBodyParts.remove(bodyPart);
                  }
                  _saveSelection();
                });
              },
              selectedColor: AppColors.pointGreen.withValues(alpha: 0.2),
              checkmarkColor: AppColors.pointGreen,
              labelStyle: AppFonts.bodyMedium.copyWith(
                color: isSelected ? AppColors.pointGreen : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.pointGreen
                    : AppColors.borderGray.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 기타 항목 (최대 2개)
        Text(
          'その他（最大2個）',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // 기타 항목 1
        CommonFormField(
          controller: _customControllers[0],
          label: 'その他 1',
          hint: '例：左足の関節',
          onChanged: (_) => _saveSelection(),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // 기타 항목 2
        CommonFormField(
          controller: _customControllers[1],
          label: 'その他 2',
          hint: '例：皮膚の痒み',
          onChanged: (_) => _saveSelection(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 선택된 항목 표시
        if (_selectedBodyParts.isNotEmpty || 
            _customControllers[0].text.isNotEmpty || 
            _customControllers[1].text.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointGreen.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.pointGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '選択された部位',
                  style: AppFonts.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.pointGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _getSelectedBodyPartsText(),
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // 클리어 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clearAllSelections,
              icon: const Icon(Icons.clear, size: 20),
              label: const Text('すべてクリア'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.borderGray.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '気になる部位を選択してください',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _saveSelection() {
    final allParts = <String>[
      ..._selectedBodyParts,
      if (_customControllers[0].text.trim().isNotEmpty) 
        _customControllers[0].text.trim(),
      if (_customControllers[1].text.trim().isNotEmpty) 
        _customControllers[1].text.trim(),
    ];
    widget.onUpdateBodyParts(allParts.join(', '));
  }

  String _getSelectedBodyPartsText() {
    final allParts = <String>[
      ..._selectedBodyParts,
      if (_customControllers[0].text.trim().isNotEmpty) 
        _customControllers[0].text.trim(),
      if (_customControllers[1].text.trim().isNotEmpty) 
        _customControllers[1].text.trim(),
    ];
    return allParts.join('、');
  }

  void _clearAllSelections() {
    setState(() {
      _selectedBodyParts.clear();
      _customControllers[0].clear();
      _customControllers[1].clear();
    });
    widget.onClearBodyParts();
  }

  @override
  void dispose() {
    for (final controller in _customControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
