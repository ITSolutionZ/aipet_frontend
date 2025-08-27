import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // 앱 실행
  runApp(ProviderScope(child: AppBootstrap.createApp()));
}
