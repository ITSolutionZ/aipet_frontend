import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientBackAppBar(title: 'ぺことの記念日は?'),
      body: Center(child: Text('Pet Anniversary Screen - Coming Soon')),
    );
  }
}
