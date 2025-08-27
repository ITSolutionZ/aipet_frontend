import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';

class PetRegistrationCompleteScreen extends ConsumerStatefulWidget {
  const PetRegistrationCompleteScreen({super.key});

  @override
  ConsumerState<PetRegistrationCompleteScreen> createState() =>
      _PetRegistrationCompleteScreenState();
}

class _PetRegistrationCompleteScreenState
    extends ConsumerState<PetRegistrationCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: const Text('登録完了'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Pet Registration Complete Screen - Coming Soon'),
      ),
    );
  }
}
