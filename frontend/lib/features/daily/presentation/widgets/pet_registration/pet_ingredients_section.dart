import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
/// 펫 금지 원료 섹션
class PetIngredientsSection extends StatefulWidget {
  final List<String> forbiddenIngredients;
  final Function(String, BuildContext) onAddIngredient;
  final Function(String) onRemoveIngredient;

  const PetIngredientsSection({
    super.key,
    required this.forbiddenIngredients,
    required this.onAddIngredient,
    required this.onRemoveIngredient,
  });

  @override
  State<PetIngredientsSection> createState() => _PetIngredientsSectionState();
}

class _PetIngredientsSectionState extends State<PetIngredientsSection> {
  final TextEditingController _ingredientController = TextEditingController();
  List<String> _suggestions = [];

  // 목업 데이터 - 일반적인 위험 원료들
  static const List<String> _dangerousIngredients = [
    'チョコレート', // 초콜릿
    'タマネギ', // 양파
    'ニンニク', // 마늘
    'ぶどう', // 포도
    'レーズン', // 건포도
    'アボカド', // 아보카도
    'マカダミアナッツ', // 마카다미아 너트
    'キシリトール', // 자일리톨
    'カフェイン', // 카페인
    'アルコール', // 알코올
    'さくらんぼ', // 체리
    '桃', // 복숭아
    'プラム', // 자두
    '杏', // 살구
    'ナツメグ', // 육두구
    'シナモン', // 계피
    '生の豚肉', // 생돼지고기
    '生の鶏肉', // 생닭고기
    '生の魚', // 생선
    '生卵', // 생계란
    '牛乳', // 우유
    'チーズ', // 치즈
    'バター', // 버터
    '砂糖', // 설탕
    '塩', // 소금
    '醤油', // 간장
    '味噌', // 된장
    'コーヒー', // 커피
    'お茶', // 차
    'エネルギードリンク', // 에너지 드링크
  ];

  @override
  void initState() {
    super.initState();
    _ingredientController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _ingredientController.text.toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final filteredSuggestions = _dangerousIngredients
        .where(
          (ingredient) =>
              ingredient.toLowerCase().contains(text) &&
              !widget.forbiddenIngredients.contains(ingredient),
        )
        .take(5)
        .toList();

    setState(() {
      _suggestions = filteredSuggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.pointOrange,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '食べてはいけない原料',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${widget.forbiddenIngredients.length}/8',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
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
              color: AppColors.pointOrange.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'ペットが食べてはいけない原料を登録してください。最大8個まで登録できます。',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 입력 필드
        Row(
          children: [
            Expanded(
              child: CommonFormField(
                controller: _ingredientController,
                label: '原料名',
                hint: '原料名を入力してください',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add_circle),
              color: AppColors.pointOrange,
              iconSize: 32,
            ),
          ],
        ),

        // 제안 목록 (실시간 검색 결과)
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.backgroundGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: AppColors.borderGray.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '提案される危険な原料',
                  style: AppFonts.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _suggestions.map((suggestion) {
                    return GestureDetector(
                      onTap: () => _selectSuggestion(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pointOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                          border: Border.all(
                            color: AppColors.pointOrange.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              suggestion,
                              style: AppFonts.bodySmall.copyWith(
                                color: AppColors.pointOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: AppColors.pointOrange.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // 등록된 원료 칩들
        if (widget.forbiddenIngredients.isNotEmpty) ...[
          Text(
            '登録済み原料 (${widget.forbiddenIngredients.length}個)',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: widget.forbiddenIngredients.map((ingredient) {
              return Chip(
                label: Text(
                  ingredient,
                  style: AppFonts.bodySmall.copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.pointOrange,
                deleteIcon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
                onDeleted: () => widget.onRemoveIngredient(ingredient),
              );
            }).toList(),
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
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'まだ原料が登録されていません',
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

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      widget.onAddIngredient(ingredient, context);
      _ingredientController.clear();
    }
  }

  void _selectSuggestion(String suggestion) {
    widget.onAddIngredient(suggestion, context);
    _ingredientController.clear();
    setState(() {
      _suggestions = [];
    });
  }

  @override
  void dispose() {
    _ingredientController.removeListener(_onTextChanged);
    _ingredientController.dispose();
    super.dispose();
  }
}
