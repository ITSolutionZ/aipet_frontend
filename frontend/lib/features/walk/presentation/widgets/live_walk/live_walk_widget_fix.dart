import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 간단한 테스트 버전 - 1초 rebuild 없음

class SimpleWalkTest extends ConsumerWidget {
  const SimpleWalkTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('산책 (테스트)')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('1초 rebuild 없음'),
            SizedBox(height: 20),
            Text('지금 테스트 중입니다'),
          ],
        ),
      ),
    );
  }
}
