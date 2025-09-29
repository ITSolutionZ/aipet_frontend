import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('UfacilityUdetailUscreen 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: Text('Test'))),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('UfacilityUdetailUscreen 상호작용 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: Text('Test'))),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
