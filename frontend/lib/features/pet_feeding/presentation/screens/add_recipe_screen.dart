import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../../../app/services/current_user_service.dart';
import '../../../../../features/pet_feeding/data/data.dart';
import '../../../../../features/pet_feeding/domain/domain.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  String _selectedDifficulty = 'Easy';
  final List<String> _ingredients = [];
  final List<String> _instructions = [];

  final _ingredientController = TextEditingController();
  final _instructionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _ingredientController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  /// 현재 사용자 ID 가져오기
  Future<String?> _getCurrentUserId() async {
    final userService = ref.read(currentUserServiceProvider);
    final result = await userService.getCurrentUserId();
    return result.isSuccess ? result.dataOrNull : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: '新しいレシピを追加'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // 기본 정보 섹션
            _buildSectionTitle('基本情報'),
            const SizedBox(height: AppSpacing.md),

            // 레시피 이름
            CommonFormPatterns.buildTextField(
              controller: _nameController,
              label: 'レシピ名 *',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'レシピ名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // 레시피 설명
            CommonFormPatterns.buildTextField(
              controller: _descriptionController,
              label: 'レシピの説明 *',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'レシピの説明を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // 조리 시간과 난이도
            Row(
              children: [
                Expanded(
                  child: CommonFormPatterns.buildTextField(
                    controller: _cookingTimeController,
                    label: '調理時間 (例: 30分) *',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '調理時間を入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CommonFormPatterns.buildDropdownField<String>(
                    label: '難易度 *',
                    items: const ['Easy', 'Medium', 'Hard'],
                    itemBuilder: (difficulty) => difficulty,
                    value: _selectedDifficulty,
                    onChanged: (value) {
                      setState(() {
                        _selectedDifficulty = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 인분 수
            CommonFormPatterns.buildNumberField(
              controller: _servingsController,
              label: '人数分',
              min: 1,
              max: 20,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 재료 섹션
            _buildSectionTitle('材料'),
            const SizedBox(height: AppSpacing.md),

            // 재료 추가
            Row(
              children: [
                Expanded(
                  child: CommonFormPatterns.buildTextField(
                    controller: _ingredientController,
                    label: '材料を追加',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // 재료 목록
            if (_ingredients.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '材料リスト',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._ingredients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ingredient = entry.value;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Text('${index + 1}.'),
                        title: Text(ingredient),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeIngredient(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 조리 방법 섹션
            _buildSectionTitle('調理手順'),
            const SizedBox(height: AppSpacing.md),

            // 조리 방법 추가
            Row(
              children: [
                Expanded(
                  child: CommonFormPatterns.buildTextField(
                    controller: _instructionController,
                    label: '調理手順を追加',
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _addInstruction,
                  child: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // 조리 방법 목록
            if (_instructions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '調理手順',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._instructions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final instruction = entry.value;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.pointBlue,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(instruction),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeInstruction(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                ),
                child: Text(
                  'レシピを保存',
                  style: AppFonts.fredoka(
                    fontSize: AppFonts.lg,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppFonts.titleMedium.copyWith(
        color: AppColors.pointDark,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addInstruction() {
    final instruction = _instructionController.text.trim();
    if (instruction.isNotEmpty) {
      setState(() {
        _instructions.add(instruction);
        _instructionController.clear();
      });
    }
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final recipe = RecipeEntity(
        id: '', // ID는 리포지토리에서 생성
        name: _nameController.text.trim(),
        image: 'assets/images/placeholder.png', // 기본 이미지
        description: _descriptionController.text.trim(),
        cookingTime: _cookingTimeController.text.trim(),
        difficulty: _selectedDifficulty,
        ingredients: List.from(_ingredients),
        instructions: List.from(_instructions),
        servings: int.tryParse(_servingsController.text) ?? 1,
        rating: 0.0,
        isFavorite: false,
        userId: await _getCurrentUserId() ?? 'anonymous', // 동적 사용자 ID
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(recipesProvider.notifier).createRecipe(recipe);

      if (mounted) {
        UiService.showSuccess(context, 'レシピが正常に保存されました！');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UiService.showError(context, 'レシピの保存に失敗しました: $e');
      }
    }
  }
}
