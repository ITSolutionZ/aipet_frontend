import 'package:flutter/material.dart';

/// 펫 등록 관련 상수 데이터
class PetRegistrationConstants {
  PetRegistrationConstants._();

  /// 강아지 품종 데이터
  static const List<Map<String, dynamic>> dogBreeds = [
    {'name': '全犬種', 'image': 'assets/images/dogs/mixed.png'},
    {'name': 'チワワ', 'image': 'assets/images/dogs/chiwawa.png'},
    {'name': 'プードル', 'image': 'assets/images/dogs/poodle.png'},
    {'name': 'ダックスフンド', 'image': 'assets/images/dogs/dachshund.png'},
    {'name': '柴犬', 'image': 'assets/images/dogs/shiba.png'},
    {'name': 'シーズー', 'image': 'assets/images/dogs/shih_tzu.png'},
    {'name': 'ヨークシャーテリア', 'image': 'assets/images/dogs/yorkshire_terrie.png'},
    {'name': 'マルチーズ', 'image': 'assets/images/dogs/maltese.png'},
    {
      'name': 'ミニチュアシュナウザー',
      'image': 'assets/images/dogs/miniature_schnauzer.png',
    },
    {'name': 'ゴールデンレトリバー', 'image': 'assets/images/dogs/golden_retriever.png'},
    {'name': 'キャバリア', 'image': 'assets/images/dogs/mixed.png'},
    {
      'name': 'ラブラドールレトリバー',
      'image': 'assets/images/dogs/labrador_retriever.png',
    },
    {'name': 'フレンチブルドック', 'image': 'assets/images/dogs/french_bulldog.png'},
    {'name': 'パグ', 'image': 'assets/images/dogs/pug.png'},
    {'name': 'ジャーマンシェパード', 'image': 'assets/images/dogs/mixed.png'},
    {'name': 'ポメラニアン', 'image': 'assets/images/dogs/pomeranian.png'},
    {'name': 'イタリアン・グレーハウンド', 'image': 'assets/images/dogs/mixed.png'},
    {'name': 'その他', 'image': 'assets/images/dogs/mixed.png'},
  ];

  /// 고양이 품종 데이터
  static const List<Map<String, dynamic>> catBreeds = [
    {
      'name': 'アメリカンショートヘア',
      'image': 'assets/images/cats/american_shothair.png',
    },
    {'name': 'ペルシャ', 'image': 'assets/images/cats/perisan.png'},
    {'name': 'メインクーン', 'image': 'assets/images/cats/Maine Coon.png'},
    {'name': 'ラグドール', 'image': 'assets/images/cats/Ragdoll.png'},
    {'name': 'スコティッシュフォールド', 'image': 'assets/images/cats/scottish_fold.png'},
    {
      'name': 'ブリティッシュショートヘア',
      'image': 'assets/images/cats/britsh_shothair.png',
    },
    {'name': 'その他', 'image': 'assets/images/cats/mixed.png'},
  ];

  /// 성별 옵션
  static const List<String> genders = ['オス', 'メス'];

  /// 펫 타입 데이터 (아이콘과 함께)
  static const Map<String, Map<String, dynamic>> petTypes = {
    'dog': {
      'name': '犬',
      'icon': Icons.pets,
      'breeds': dogBreeds,
      'image': 'assets/images/dogs/dogs.png',
    },
    'cat': {
      'name': '猫',
      'icon': Icons.cruelty_free,
      'breeds': catBreeds,
      'image': 'assets/images/cats/cats.png',
    },
    'bird': {
      'name': '鳥',
      'icon': Icons.flight,
      'breeds': [
        {'name': 'カナリア', 'image': 'assets/images/etc/bird.png'},
        {'name': 'セキセイインコ', 'image': 'assets/images/etc/bird.png'},
        {'name': 'オウム', 'image': 'assets/images/etc/bird.png'},
        {'name': 'ハト', 'image': 'assets/images/etc/bird.png'},
        {'name': 'スズメ', 'image': 'assets/images/etc/bird.png'},
        {'name': 'その他', 'image': 'assets/images/etc/bird.png'},
      ],
      'image': 'assets/images/etc/bird.png',
    },
    'rabbit': {
      'name': 'うさぎ',
      'icon': Icons.adjust,
      'breeds': [
        {'name': 'ネザーランドドワーフ', 'image': 'assets/images/etc/rabbit.png'},
        {'name': 'ミニロップ', 'image': 'assets/images/etc/rabbit.png'},
        {'name': 'ライオンヘッド', 'image': 'assets/images/etc/rabbit.png'},
        {'name': 'アンゴラ', 'image': 'assets/images/etc/rabbit.png'},
        {'name': 'その他', 'image': 'assets/images/etc/rabbit.png'},
      ],
      'image': 'assets/images/etc/rabbit.png',
    },
    'hamster': {
      'name': 'ハムスター',
      'icon': Icons.circle,
      'breeds': [
        {'name': 'ゴールデンハムスター', 'image': 'assets/images/etc/hamster.png'},
        {'name': 'ウィンターホワイト', 'image': 'assets/images/etc/hamster.png'},
        {'name': 'ロボロフスキー', 'image': 'assets/images/etc/hamster.png'},
        {'name': 'その他', 'image': 'assets/images/etc/hamster.png'},
      ],
      'image': 'assets/images/etc/hamster.png',
    },
    'fish': {
      'name': '魚',
      'icon': Icons.water_drop,
      'breeds': [
        {'name': '金魚', 'image': 'assets/images/etc/bird.png'},
        {'name': 'グッピー', 'image': 'assets/images/etc/bird.png'},
        {'name': 'ネオンテトラ', 'image': 'assets/images/etc/bird.png'},
        {'name': 'ベタ', 'image': 'assets/images/etc/bird.png'},
        {'name': 'その他', 'image': 'assets/images/etc/bird.png'},
      ],
      'image': 'assets/images/etc/bird.png',
    },
    'turtle': {
      'name': '亀',
      'icon': Icons.circle_outlined,
      'breeds': [
        {'name': 'ミドリガメ', 'image': 'assets/images/etc/turtle.png'},
        {'name': 'アオウミガメ', 'image': 'assets/images/etc/turtle.png'},
        {'name': 'リクガメ', 'image': 'assets/images/etc/turtle.png'},
        {'name': 'ウミガメ', 'image': 'assets/images/etc/turtle.png'},
        {'name': 'その他', 'image': 'assets/images/etc/turtle.png'},
      ],
      'image': 'assets/images/etc/turtle.png',
    },
    'other': {
      'name': 'その他',
      'icon': Icons.pets_outlined,
      'breeds': [
        {'name': 'その他', 'image': 'assets/images/pets/default.png'},
      ],
      'image': 'assets/images/pets/default.png',
    },
  };
}
