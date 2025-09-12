import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../widgets/generic_breed_selection_screen.dart';

class DogBreedSelectionScreen extends ConsumerWidget {
  const DogBreedSelectionScreen({super.key});

  /// 강아지 품종 데이터 (일본에서 인기 있는 순서대로)
  static const List<Map<String, dynamic>> _dogBreedData = [
    // 일본에서 가장 인기 있는 소형견들
    {
      'key': 'poodle',
      'name': 'プードル',
      'image': 'assets/images/dogs/poodle.png',
      'description': '지능적이고 털이 잘 안 빠짐'
    },
    {
      'key': 'chiwawa',
      'name': 'チワワ',
      'image': 'assets/images/dogs/chiwawa.png',
      'description': '세계에서 가장 작은 견종'
    },
    {
      'key': 'pomeranian',
      'name': 'ポメラニアン',
      'image': 'assets/images/dogs/pomeranian.png',
      'description': '털북숭이 작은 스피츠'
    },
    {
      'key': 'shiba',
      'name': 'しば犬',
      'image': 'assets/images/dogs/shiba.png',
      'description': '일본의 대표적인 견종'
    },
    {
      'key': 'dachshund',
      'name': 'ダックスフント',
      'image': 'assets/images/dogs/dachshund.png',
      'description': '긴 몸과 짧은 다리가 특징'
    },
    {
      'key': 'maltese',
      'name': 'マルチーズ',
      'image': 'assets/images/dogs/maltese.png',
      'description': '하얀 털이 아름다운 소형견'
    },
    {
      'key': 'yorkshire_terrier',
      'name': 'ヨークシャーテリア',
      'image': 'assets/images/dogs/yorkshire_terrie.png',
      'description': '실크같은 털의 작은 테리어'
    },
    {
      'key': 'shih_tzu',
      'name': 'シーズー',
      'image': 'assets/images/dogs/shih_tzu.png',
      'description': '친근하고 온순한 성격'
    },
    {
      'key': 'french_bulldog',
      'name': 'フレンチブルドッグ',
      'image': 'assets/images/dogs/french_bulldog.png',
      'description': '독특한 박쥐 귀를 가진 견종'
    },
    {
      'key': 'pug',
      'name': 'パグ',
      'image': 'assets/images/dogs/pug.png',
      'description': '주름진 얼굴이 매력적'
    },
    {
      'key': 'golden_retriever',
      'name': 'ゴールデンレトリバー',
      'image': 'assets/images/dogs/golden_retriever.png',
      'description': '온순하고 지능적인 대형견'
    },
    {
      'key': 'labrador_retriever',
      'name': 'ラブラドールレトリバー',
      'image': 'assets/images/dogs/labrador_retriever.png',
      'description': '활발하고 친근한 성격'
    },
    {
      'key': 'miniature_schnauzer',
      'name': 'ミニチュアシュナウザー',
      'image': 'assets/images/dogs/miniature_schnauzer.png',
      'description': '수염이 특징적인 견종'
    },
    {
      'key': 'mixed',
      'name': 'ミックス（雑種）',
      'image': 'assets/images/dogs/mixed.png',
      'description': '개성 넘치는 믹스견'
    },
    {
      'key': 'other',
      'name': 'その他の犬種',
      'image': 'assets/images/dogs/mixed.png',
      'description': '다른 품종을 입력하세요'
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const GenericBreedSelectionScreen<String>(
      petType: 'dog',
      title: 'どんな子ですか？',
      breedData: _dogBreedData,
      routeAfterSelection: RouteConstants.petNameInputRoute,
      previousRoute: RouteConstants.petTypeSelectionRoute,
    );
  }
}
