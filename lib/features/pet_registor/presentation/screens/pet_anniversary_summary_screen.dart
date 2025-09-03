import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientBackAppBar(title: 'ぺこの記念日は?'),
      body: Center(child: Text('Pet Anniversary Summary Screen - Coming Soon')),
    );
  }
}
