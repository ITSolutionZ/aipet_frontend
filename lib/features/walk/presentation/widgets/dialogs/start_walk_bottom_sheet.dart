import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../controllers/walk_controller.dart';

class StartWalkBottomSheet extends StatefulWidget {
  final WalkController controller;

  const StartWalkBottomSheet({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    WalkController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => StartWalkBottomSheet(controller: controller),
    );
  }

  @override
  State<StartWalkBottomSheet> createState() => _StartWalkBottomSheetState();
}

class _StartWalkBottomSheetState extends State<StartWalkBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedPetId = 'pet1';

  @override
  void dispose() {
    _titleController.dispose();
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
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 헤더 섹션
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.pointBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                    ),
                    child: const Icon(
                      Icons.directions_walk,
                      size: 32,
                      color: AppColors.pointBlue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '新しい散歩を始める',
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.xxl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '愛犬との楽しい散歩時間を記録しましょう',
                    style: AppFonts.base(
                      fontSize: AppFonts.sm,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),

              // 입력 섹션
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 산책 제목
                    Text(
                      '散歩のタイトル',
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '例：朝の散歩、公園散歩',
                        prefixIcon: const Icon(Icons.edit_note),
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

                    const SizedBox(height: AppSpacing.xl),

                    // 펫 선택
                    Text(
                      'ペットを選択',
                      style: AppFonts.fredoka(
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
                          _buildPetOption('pet1', 'Maxi', Icons.pets, '元気な柴犬'),
                          const SizedBox(height: AppSpacing.sm),
                          _buildPetOption('pet2', 'Luna', Icons.pets, '優しいゴールデン'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // 散歩 정보
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.pointGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(color: AppColors.pointGreen.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.pointGreen,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '散歩について',
                                style: AppFonts.fredoka(
                                  fontSize: AppFonts.baseSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pointGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.pointGreen,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'GPS位置情報を使用してルートを記録',
                                style: AppFonts.base(
                                  fontSize: AppFonts.sm,
                                  color: AppColors.pointGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 16,
                                color: AppColors.pointGreen,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '歩いた時間と距離を自動測定',
                                style: AppFonts.base(
                                  fontSize: AppFonts.sm,
                                  color: AppColors.pointGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: AppColors.pointGreen,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '散歩中の思い出を写真で記録可能',
                                style: AppFonts.base(
                                  fontSize: AppFonts.sm,
                                  color: AppColors.pointGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 버튼 섹션
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child: Text(
                        'キャンセル',
                        style: AppFonts.base(
                          fontSize: AppFonts.baseSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _startWalk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '散歩を始める',
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.baseSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildPetOption(String petId, String name, IconData icon, String description) {
    final isSelected = _selectedPetId == petId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPetId = petId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pointBlue.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pointBlue : Colors.grey[200],
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
                      color: isSelected ? AppColors.pointBlue : Colors.grey[800],
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
                color: AppColors.pointBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _startWalk() async {
    if (_formKey.currentState!.validate()) {
      final result = await widget.controller.startNewWalk(
        title: _titleController.text,
        petId: _selectedPetId,
        petName: _selectedPetId == 'pet1' ? 'Maxi' : 'Luna',
        petImage: 'assets/images/dogs/shiba.png',
      );

      if (result.isSuccess && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text(result.message),
              ],
            ),
            backgroundColor: AppColors.pointGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text(result.message),
              ],
            ),
            backgroundColor: AppColors.pointPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
        );
      }
    }
  }
}