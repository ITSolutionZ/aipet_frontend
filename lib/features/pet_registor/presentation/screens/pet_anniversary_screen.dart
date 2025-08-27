import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';

class PetAnniversaryScreen extends ConsumerStatefulWidget {
  const PetAnniversaryScreen({super.key});

  @override
  ConsumerState<PetAnniversaryScreen> createState() =>
      _PetAnniversaryScreenState();
}

class _PetAnniversaryScreenState extends ConsumerState<PetAnniversaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('ぺことの記念日は?'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(child: Text('Pet Anniversary Screen - Coming Soon')),
    );
  }
}
