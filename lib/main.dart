import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() async {
  // 앱 부트스트랩 초기화 (환경변수 로드 포함)
  await AppBootstrap.initialize();
  
  // 앱 실행
  runApp(ProviderScope(child: AppBootstrap.createApp()));
}
