import 'package:aipet_frontend/features/pet_profile/presentation/screens/pet_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetProfileScreen Tests', () {
    testWidgets('PetProfileScreen이 올바르게 생성되어야 함', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PetProfileScreen(petId: 'test-pet-1')),
        ),
      );

      expect(find.byType(PetProfileScreen), findsOneWidget);

      // 모든 비동기 작업과 타이머가 완료될 때까지 기다림
      await tester.pumpAndSettle();
    });

    testWidgets('CircularProgressIndicator가 로딩 중에 표시되어야 함', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PetProfileScreen(petId: 'test-pet-1')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 모든 비동기 작업과 타이머가 완료될 때까지 기다림
      await tester.pumpAndSettle();
    });
  });
}
