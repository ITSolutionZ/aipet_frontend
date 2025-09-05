import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// 앱의 진입점
///
/// Flutter 앱의 시작점으로, 최소한의 초기화만 수행하고
/// 나머지는 AppBootstrap에서 처리합니다.
void main() async {
  // Flutter 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 부트스트랩 초기화
  await AppBootstrap.initialize();

  // 디버그 모드 렌더링
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  // debugPaintLayerBordersEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // 앱 실행
  runApp(ProviderScope(child: AppBootstrap.createApp()));
}
