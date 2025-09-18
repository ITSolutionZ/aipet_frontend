import 'package:flutter/material.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../widgets/screens/generic_breed_selection_screen.dart';

class CatBreedSelectionScreen extends StatelessWidget {
  const CatBreedSelectionScreen({super.key});

  /// 고양이 품종 데이터
  static List<Map<String, dynamic>> get _catBreedsData => [
        // 人気の猫種（日本でよく飼われる品種）
        {
          'breed': 'scottish_fold',
          'name': 'スコティッシュフォールド',
          'imagePath': 'assets/images/cats/scottish_fold.png',
          'description': '垂れ耳が特徴的な愛らしい猫',
        },
        {
          'breed': 'american_shorthair',
          'name': 'アメリカンショートヘア',
          'imagePath': 'assets/images/cats/american_shorthair.png',
          'description': '丈夫で飼いやすい人気品種',
        },
        {
          'breed': 'russian_blue',
          'name': 'ロシアンブルー',
          'imagePath': 'assets/images/cats/russian_blue.png',
          'description': '美しいグレーの被毛が特徴',
        },
        {
          'breed': 'british_shorthair',
          'name': 'ブリティッシュショートヘア',
          'imagePath': 'assets/images/cats/british_shorthair.png',
          'description': '落ち着いた性格の猫',
        },
        {
          'breed': 'ragdoll',
          'name': 'ラグドール',
          'imagePath': 'assets/images/cats/ragdoll.png',
          'description': '大型でおとなしい性格',
        },
        {
          'breed': 'maine_coon',
          'name': 'メインクーン',
          'imagePath': 'assets/images/cats/maine_coon.png',
          'description': '大型で毛が長い美しい猫',
        },
        {
          'breed': 'persian',
          'name': 'ペルシャ',
          'imagePath': 'assets/images/cats/persian.png',
          'description': '長毛でエレガントな猫',
        },
        {
          'breed': 'siamese',
          'name': 'シャム',
          'imagePath': 'assets/images/cats/siamese.png',
          'description': '活発で人懐っこい猫',
        },
        // その他・ミックス
        {
          'breed': 'mixed',
          'name': 'ミックス',
          'imagePath': 'assets/images/cats/mixed.png',
          'description': 'ミックス・その他の品種',
        },
        {
          'breed': 'custom',
          'name': 'その他',
          'imagePath': 'assets/images/cats/custom.png',
          'description': 'カスタム品種を入力',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return GenericBreedSelectionScreen(
      petType: 'cat',
      title: 'どんな子ですか？',
      breedData: _catBreedsData,
      routeAfterSelection: RouteConstants.petNameInputRoute,
      previousRoute: RouteConstants.petTypeSelectionRoute,
    );
  }
}