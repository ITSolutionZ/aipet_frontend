import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 산책 정보 UI 헬퍼
class WalkInfoUiHelper {
  /// 상태 텍스트 가져오기
  static String getStatusText(WalkStatus status) {
    switch (status) {
      case WalkStatus.inProgress:
        return '散歩中';
      case WalkStatus.completed:
        return '完了';
      case WalkStatus.paused:
        return '一時停止';
      case WalkStatus.cancelled:
        return 'キャンセル';
    }
  }

  /// 정보 행 빌드
  static Widget buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
        Flexible(
          child: Text(
            value,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// 드래그 핸들 빌드
  static Widget buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// activities 개수 카운트
  static int countActivities(String jsonStr) {
    try {
      final matches = jsonStr.split('type:').length - 1;
      return matches > 0 ? matches : 0;
    } catch (e) {
      return 0;
    }
  }
}
