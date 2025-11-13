import 'package:flutter/material.dart';

import 'tokens/tokens.dart';

/// AI 기능 전용 색상 상수들
class AiColors {
  /// 펫 선택 배경색 (alpha: 0.1)
  static Color get petSelectionBackground =>
      AppColors.pointBrown.withValues(alpha: 0.1);

  /// 즐겨찾기 배경색 (alpha: 0.15)
  static Color get favoriteBackground =>
      AppColors.pointBrown.withValues(alpha: 0.15);

  /// 질문 요청 배경색 (alpha: 0.1)
  static Color get questionRequestBackground =>
      AppColors.pointBrown.withValues(alpha: 0.1);

  /// 선택된 상태 테두리색 (alpha: 0.3)
  static Color get selectedBorderColor =>
      AppColors.pointBrown.withValues(alpha: 0.3);

  /// 선택되지 않은 상태 테두리색 (alpha: 0.2)
  static Color get unselectedBorderColor =>
      AppColors.pointBrown.withValues(alpha: 0.2);

  /// 그림자 색상 (alpha: 0.2)
  static Color get shadowColor => AppColors.pointBrown.withValues(alpha: 0.2);
}
