import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '새 레시피 추가',
          style: AppFonts.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // 기본 정보 섹션
            _buildSectionTitle('기본 정보'),
            const SizedBox(height: AppSpacing.md),

            // 레시피 이름
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '레시피 이름 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '레시피 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // 레시피 설명
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '레시피 설명 *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '레시피 설명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // 조리 시간과 난이도
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cookingTimeController,
                    decoration: const InputDecoration(
                      labelText: '조리 시간 (예: 30 min) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '조리 시간을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: '난이도 *',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Easy', 'Medium', 'Hard'].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      );
                    }).toList(),
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
            TextFormField(
              controller: _servingsController,
              decoration: const InputDecoration(
                labelText: '인분 수',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 재료 섹션
            _buildSectionTitle('재료'),
            const SizedBox(height: AppSpacing.md),

            // 재료 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: const InputDecoration(
                      labelText: '재료 추가',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _addIngredient,
                  child: const Text('추가'),
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
                      '재료 목록',
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
            _buildSectionTitle('조리 방법'),
            const SizedBox(height: AppSpacing.md),

            // 조리 방법 추가
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _instructionController,
                    decoration: const InputDecoration(
                      labelText: '조리 단계 추가',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _addInstruction,
                  child: const Text('추가'),
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
                      '조리 단계',
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
                  '레시피 저장',
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

  void _saveRecipe() async {
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
        userId: 'current_user_id', // TODO: 실제 사용자 ID로 변경
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(recipesNotifierProvider.notifier).createRecipe(recipe);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('레시피가 성공적으로 저장되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('레시피 저장에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
