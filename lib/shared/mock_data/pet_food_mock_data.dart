import 'package:flutter/material.dart';

/// 펫 사료 관련 목업 데이터
class PetFoodMockData {
  /// 사료 목록
  static const List<String> foods = [
    'ロイヤルカナン 成犬用',
    'ヒルズ サイエンスダイエット',
    'オリジン オリジナル',
    'アカナ グラスランド',
    'ウェルネス コア',
    'ナチュラルバランス',
    'ブルーバッファロー',
    'プロプラン',
    'アイムス',
    'サイエンスダイエット',
    'ユーカヌバ',
    'ドクターズダイエット',
    'その他（手作り食）',
    'その他（生食）',
  ];

  /// 영양제 목록
  static const List<String> supplements = [
    'オメガ3サプリメント',
    'グルコサミン・コンドロイチン',
    'プロバイオティクス',
    'ビタミンEサプリ',
    'カルシウムサプリ',
    'マルチビタミン',
    'コラーゲンサプリ',
    'タウリンサプリ',
    'L-カルニチン',
    'ケルプ（海藻）サプリ',
    'ハーブサプリ',
    'CBDオイル',
    '摂取していない',
  ];

  /// 간식 목록
  static const List<String> treats = [
    'チキンジャーキー',
    'ビーフジャーキー',
    'ササミジャーキー',
    'ドライフルーツ',
    'チーズ',
    '野菜スティック',
    'おやつ用クッキー',
    'ガム',
    '骨型おやつ',
    'フリーズドライおやつ',
    '手作りおやつ',
    '生野菜',
    'フルーツ',
    '摂取していない',
  ];

  /// 모든 카테고리 데이터
  static Map<String, List<String>> getAllCategories() {
    return {'food': foods, 'supplement': supplements, 'treat': treats};
  }

  /// 카테고리 이름 매핑
  static Map<String, String> getCategoryNames() {
    return {'food': '食べる餌', 'supplement': '食べる栄養剤', 'treat': '食べるおやつ'};
  }

  /// 카테고리 아이콘 매핑
  static Map<String, IconData> getCategoryIcons() {
    return {
      'food': Icons.pets,
      'supplement': Icons.medication,
      'treat': Icons.cake,
    };
  }
}
