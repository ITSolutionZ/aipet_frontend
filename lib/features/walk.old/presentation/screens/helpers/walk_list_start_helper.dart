import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/walk_providers.dart';

/// 산책 시작 관련 헬퍼
class WalkListStartHelper {
  /// 산책 시작 다이얼로그 표시 및 처리
  static Future<void> showStartWalkDialog({
    required BuildContext context,
    required WidgetRef ref,
    required WalkController controller,
  }) async {
    final selectedPets = ref.read(selectedPetsProvider);

    if (selectedPets.isEmpty) {
      _showNoPetSelectedSnackBar(context);
      return;
    }

    // 다이얼로그 없이 바로 산책 시작
    final result = await controller.startNewWalk(
      title: '散歩',
      petId: selectedPets.first.id,
      petName: selectedPets.map((p) => p.name).join('、'),
    );

    if (!result.isSuccess && context.mounted) {
      // 실패 시에만 에러 메시지 표시
      _showStartErrorSnackBar(context, result.message);
    }
  }

  /// 펫 미선택 스낵바
  static void _showNoPetSelectedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ペットを選択してください'),
        backgroundColor: AppColors.pointPink,
      ),
    );
  }

  /// 시작 에러 스낵바
  static void _showStartErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.pointPink),
    );
  }
}
