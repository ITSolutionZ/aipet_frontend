import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

class PetSizeWeightScreen extends ConsumerStatefulWidget {
  const PetSizeWeightScreen({super.key});

  @override
  ConsumerState<PetSizeWeightScreen> createState() =>
      _PetSizeWeightScreenState();
}

class _PetSizeWeightScreenState extends ConsumerState<PetSizeWeightScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('ぺこのサイズと体重は?'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(child: Text('Pet Size Weight Screen - Coming Soon')),
    );
  }
}
