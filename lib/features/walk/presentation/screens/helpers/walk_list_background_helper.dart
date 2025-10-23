import 'package:aipet_frontend/features/walk/data/services/local_walk_storage_service.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/walk_providers.dart';

/// 백그라운드 산책 확인 헬퍼
class WalkListBackgroundHelper {
  /// 백그라운드에서 진행 중인 산책 확인 및 종료
  static Future<void> checkBackgroundWalk({
    required BuildContext context,
    required WidgetRef ref,
    required WalkController controller,
  }) async {
    try {
      // 로컬 스토리지에서 진행 중인 산책 확인
      final currentWalk = await LocalWalkStorageService.loadCurrentWalk();

      if (currentWalk == null) return;

      LoggerService.debug('⚠️ 백그라운드 산책 발견: ${currentWalk.id}');
      LoggerService.debug('시작 시간: ${currentWalk.startTime}');
      LoggerService.debug('상태: ${currentWalk.status}');

      // 진행 중 또는 일시정지 상태인 산책만 처리
      if (currentWalk.status != WalkStatus.inProgress &&
          currentWalk.status != WalkStatus.paused) {
        return;
      }

      if (!context.mounted) return;

      // 사용자에게 알림
      final shouldEnd = await _showBackgroundWalkDialog(
        context: context,
        currentWalk: currentWalk,
      );

      if (!context.mounted) return;

      if (shouldEnd == true) {
        await _handleEndBackgroundWalk(
          context: context,
          ref: ref,
          controller: controller,
          currentWalk: currentWalk,
        );
      } else if (shouldEnd == false) {
        // 계속하기 선택 시 provider에 복원
        ref.read(currentWalkProvider.notifier).startWalk(currentWalk);
      }
    } catch (e) {
      LoggerService.debug('❌ 백그라운드 산책 확인 실패: $e');
    }
  }

  /// 백그라운드 산책 다이얼로그 표시
  static Future<bool?> _showBackgroundWalkDialog({
    required BuildContext context,
    required WalkRecordEntity currentWalk,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('未完了の散歩'),
        content: Text(
          '${currentWalk.petName}の散歩が進行中です。\n'
          '開始時間: ${currentWalk.timeString}\n\n'
          'この散歩を終了しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('続ける'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointPink,
            ),
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  /// 백그라운드 산책 종료 처리
  static Future<void> _handleEndBackgroundWalk({
    required BuildContext context,
    required WidgetRef ref,
    required WalkController controller,
    required WalkRecordEntity currentWalk,
  }) async {
    // 자동 종료 처리
    final duration = DateTime.now().difference(currentWalk.startTime);

    // 종료 처리
    await controller.endCurrentWalk(
      distance: currentWalk.distance ?? 0.0,
      notes: currentWalk.notes,
    );

    // 로컬 스토리지에서 currentWalk 명시적으로 제거
    await LocalWalkStorageService.saveCurrentWalk(null);

    // Provider 상태도 명시적으로 클리어
    ref.read(currentWalkProvider.notifier).endWalk();

    if (!context.mounted) return;

    SnackBarService.showSuccess(context, '散歩を終了しました (${duration.inMinutes}分)');
  }
}
