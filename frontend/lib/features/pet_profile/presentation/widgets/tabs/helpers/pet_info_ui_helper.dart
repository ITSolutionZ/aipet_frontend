import 'package:flutter/material.dart';

/// Pet 정보 UI 헬퍼
class PetInfoUiHelper {
  /// 속성 타입에 따른 아이콘 반환
  static IconData getAttributeIcon(String type) {
    switch (type) {
      case 'name':
        return Icons.badge;
      case 'gender':
        return Icons.wc;
      case 'weight':
        return Icons.monitor_weight;
      case 'appearance':
        return Icons.palette;
      default:
        return Icons.info;
    }
  }
}
