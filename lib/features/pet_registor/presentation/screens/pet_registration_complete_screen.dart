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
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(title: '登録完了'),
      body: Center(
        child: Text('Pet Registration Complete Screen - Coming Soon'),
      ),
    );
  }
}
