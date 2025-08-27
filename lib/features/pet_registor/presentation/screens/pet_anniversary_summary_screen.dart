import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

class PetAnniversarySummaryScreen extends ConsumerStatefulWidget {
  const PetAnniversarySummaryScreen({super.key});

  @override
  ConsumerState<PetAnniversarySummaryScreen> createState() =>
      _PetAnniversarySummaryScreenState();
}

class _PetAnniversarySummaryScreenState
    extends ConsumerState<PetAnniversarySummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('ぺこの記念日は?'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text('Pet Anniversary Summary Screen - Coming Soon'),
      ),
    );
  }
}
