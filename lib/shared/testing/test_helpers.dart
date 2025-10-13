import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 테스트용 헬퍼 함수들
class TestHelpers {
  /// 테스트용 ProviderScope 래퍼
  static Widget wrapWithProviderScope(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// 테스트용 딜레이
  static Future<void> delay({int milliseconds = 100}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }
}