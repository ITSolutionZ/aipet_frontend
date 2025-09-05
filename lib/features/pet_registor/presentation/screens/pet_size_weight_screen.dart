import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientBackAppBar(title: 'ぺこのサイズと体重は?'),
      body: Center(child: Text('Pet Size Weight Screen - Coming Soon')),
    );
  }
}
