import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 펫 관리 화면
class PetManagementScreen extends ConsumerWidget {
  const PetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pointBrown,
        elevation: 0,
        title: const Text('ペット管理'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.pointDark),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: AppColors.pointBrown),
            SizedBox(height: AppSpacing.lg),
            Text(
              'ペット管理機能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '準備中です',
              style: TextStyle(fontSize: 16, color: AppColors.pointGray),
            ),
          ],
        ),
      ),
    );
  }
}
