import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 크기 선택 위젯
class PetSizeSelector extends StatelessWidget {
  final String? selectedSize;
  final ValueChanged<String> onSizeChanged;

  const PetSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeChanged,
  });

  static const Map<String, Map<String, dynamic>> _sizeData = {
    'extra_small': {
      'name': '極小型',
      'description': '1-5kg (チワワ、ヨークシャーテリアなど)',
      'icon': Icons.pets,
      'color': AppColors.pointPink,
    },
    'small': {
      'name': '小型',
      'description': '5-10kg (ダックスフント、ポメラニアンなど)',
      'icon': Icons.pets,
      'color': AppColors.pointBrown,
    },
    'medium': {
      'name': '中型',
      'description': '10-25kg (柴犬、ビーグルなど)',
      'icon': Icons.pets,
      'color': AppColors.pointDark,
    },
    'large': {
      'name': '大型',
      'description': '25-40kg (ゴールデンレトリーバーなど)',
      'icon': Icons.pets,
      'color': AppColors.pointGray,
    },
    'extra_large': {
      'name': '超大型',
      'description': '40kg以上 (グレートデーンなど)',
      'icon': Icons.pets,
      'color': AppColors.pointDark,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'サイズを選択してください',
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._sizeData.entries.map((entry) => _buildSizeOption(entry)),
      ],
    );
  }

  Widget _buildSizeOption(MapEntry<String, Map<String, dynamic>> entry) {
    final sizeKey = entry.key;
    final sizeInfo = entry.value;
    final isSelected = selectedSize == sizeKey;

    return Semantics(
      label: '${sizeInfo['name']} サイズを選択',
      hint: sizeInfo['description'] as String,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () => onSizeChanged(sizeKey),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? (sizeInfo['color'] as Color).withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? (sizeInfo['color'] as Color)
                  : AppColors.pointGray.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (sizeInfo['color'] as Color)
                      : AppColors.pointGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(
                  sizeInfo['icon'] as IconData,
                  color: isSelected
                      ? Colors.white
                      : AppColors.pointGray,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sizeInfo['name'] as String,
                      style: AppFonts.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? (sizeInfo['color'] as Color)
                            : AppColors.pointDark,
                      ),
                    ),
                    const const SizedBox(height: 2),
                    Text(
                      sizeInfo['description'] as String,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointGray,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: sizeInfo['color'] as Color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
