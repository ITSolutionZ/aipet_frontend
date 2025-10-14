import 'package:flutter/material.dart';

/// 펫 사료 로컬 데이터 소스
class PetFoodLocalDatasource {
  /// 사료 목록
  static const List<String> foods = [
    'ドッグフード（ドライ）',
    'ドッグフード（ウェット）',
    'キャットフード（ドライ）',
    'キャットフード（ウェット）',
    'うさぎフード',
    'ハムスターフード',
    '鳥フード',
    '魚フード',
    '手作りフード',
    '生食',
    'その他',
  ];

  /// 영양제 목록
  static const List<String> supplements = [
    'ビタミン剤',
    'カルシウム剤',
    'プロバイオティクス',
    'オメガ3脂肪酸',
    'グルコサミン',
    'コンドロイチン',
    'ビタミンD',
    'ビタミンE',
    '亜鉛サプリメント',
    '鉄分サプリメント',
    'その他',
  ];

  /// 간식 목록
  static const List<String> treats = [
    'ドッグクッキー',
    'キャットクッキー',
    'うさぎクッキー',
    'ハムスタークッキー',
    '鳥用クッキー',
    '魚用クッキー',
    'チーズ',
    '肉類',
    '野菜',
    '果物',
    'その他',
  ];

  /// 카테고리별 아이콘 반환
  static Map<String, IconData> getCategoryIcons() {
    return {
      'food': Icons.restaurant,
      'supplement': Icons.medication,
      'treat': Icons.cake,
    };
  }

  /// 카테고리별 색상 반환
  static Map<String, Color> getCategoryColors() {
    return {
      'food': Colors.orange,
      'supplement': Colors.blue,
      'treat': Colors.pink,
    };
  }
}
