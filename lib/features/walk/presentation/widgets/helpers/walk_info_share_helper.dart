import 'package:aipet_frontend/features/walk/data/providers/walk_share_providers.dart';
import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 산책 정보 공유 헬퍼
class WalkInfoShareHelper {
  /// 클립보드에 복사
  static Future<void> copyToClipboard({
    required BuildContext context,
    required WidgetRef ref,
    required String text,
  }) async {
    final useCase = ref.read(copyToClipboardUseCaseProvider);
    final result = await useCase(text);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? AppColors.pointGreen
              : AppColors.pointPink,
        ),
      );
    }
  }

  /// 이미지로 저장
  static Future<void> saveAsImage({
    required BuildContext context,
    required WidgetRef ref,
    required WalkRecordEntity walkRecord,
  }) async {
    final useCase = ref.read(saveAsImageUseCaseProvider);
    final result = await useCase(walkRecord);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? AppColors.pointGreen
              : AppColors.pointPink,
        ),
      );
    }
  }

  /// 시스템 공유
  static Future<void> systemShare({
    required BuildContext context,
    required WidgetRef ref,
    required String text,
  }) async {
    final useCase = ref.read(systemShareUseCaseProvider);
    final result = await useCase(text, subject: '散歩記録を共有');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.isSuccess
              ? AppColors.pointGreen
              : AppColors.pointPink,
        ),
      );
    }
  }
}
