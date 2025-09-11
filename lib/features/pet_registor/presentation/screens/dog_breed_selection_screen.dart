import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../widgets/generic_breed_selection_screen.dart';

class DogBreedSelectionScreen extends ConsumerWidget {
  const DogBreedSelectionScreen({super.key});

  /// 강아지 품종 데이터
  static const List<Map<String, dynamic>> _dogBreedData = [
    {'key': 'poodle', 'name': 'プードル', 'image': 'assets/images/dogs/poodle.jpg'},
    {
      'key': 'chiwawa',
      'name': 'チワワ',
      'image': 'assets/images/dogs/chiwawa.png',
    },
    {'key': 'mixed', 'name': '小型ミックス', 'image': 'assets/images/dogs/mixed.png'},
    {'key': 'shiba', 'name': 'しば犬', 'image': 'assets/images/dogs/shiba.png'},
    {
      'key': 'dachshund',
      'name': 'ドックス',
      'image': 'assets/images/dogs/dachshund.png',
    },
    {
      'key': 'pomeranian',
      'name': 'ポメ',
      'image': 'assets/images/dogs/pomeranian.png',
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
