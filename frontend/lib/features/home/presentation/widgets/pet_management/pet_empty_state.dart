import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
/// ペット管理画面の空状態ウィジェット
class PetEmptyState extends StatelessWidget {
  const PetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_outlined,
              size: 40,
              color: AppColors.pointGray,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '登録されたペットがいません',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '新しいペットを登録してください',
            style: TextStyle(fontSize: 14, color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}
