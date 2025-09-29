import 'package:flutter/material.dart';

/// 펫 타입에 따른 아이콘 매핑 유틸리티
/// UI 로직을 Domain에서 분리하여 Presentation Layer에 위치
class PetTypeIconMapper {
  /// 펫 타입에 따른 아이콘 반환
  static IconData getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'hamster':
        return Icons.pets;
      case 'rabbit':
        return Icons.pets;
      case 'turtle':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  /// 펫 타입에 따른 색상 반환 (추가 기능)
  static Color getColor(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
        return Colors.blue;
      case 'cat':
        return Colors.orange;
      case 'bird':
        return Colors.green;
      case 'hamster':
        return Colors.brown;
      case 'rabbit':
        return Colors.pink;
      case 'turtle':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
