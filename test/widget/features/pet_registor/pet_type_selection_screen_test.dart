import 'package:aipet_frontend/features/pet_registor/presentation/screens/pet_type_selection_screen.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('PetTypeSelectionScreen', () {
    testWidgets('should display pet type selection screen correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PetTypeSelectionScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      // 화면이 로드될 때까지 대기
      await tester.pumpAndSettle();

      // AppBar 제목 확인
      expect(find.text('ペットの種類を選択'), findsOneWidget);

      // 메인 제목 확인
      expect(find.text('今、誰と暮らしていますか?'), findsOneWidget);

      // 펫 타입 카드들이 표시되는지 확인
      expect(find.text('犬'), findsOneWidget);
      expect(find.text('猫'), findsOneWidget);
      expect(find.text('鳥'), findsOneWidget);
      expect(find.text('ハムスター'), findsOneWidget);
      expect(find.text('うさぎ'), findsOneWidget);
      expect(find.text('亀'), findsOneWidget);

      // 다음 버튼이 비활성화 상태인지 확인 (아무것도 선택되지 않음)
      final nextButton = find.text('次へ');
      expect(nextButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should enable next button when pet type is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PetTypeSelectionScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 강아지 카드 탭
      await tester.tap(find.text('犬'));
      await tester.pump();

      // 다음 버튼이 활성화되었는지 확인
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should show selection indicator when pet type is selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PetTypeSelectionScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 강아지 카드 탭
      await tester.tap(find.text('犬'));
      await tester.pump();

      // 선택 표시 아이콘이 나타나는지 확인
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should change selection when different pet type is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PetTypeSelectionScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 강아지 카드 탭
      await tester.tap(find.text('犬'));
      await tester.pump();

      // 고양이 카드 탭
      await tester.tap(find.text('猫'));
      await tester.pump();

      // 선택 표시가 고양이 카드에만 있는지 확인
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should have correct background color', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PetTypeSelectionScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scaffold의 배경색 확인
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.pointOffWhite);
    });

    testWidgets('should display pet type cards in grid layout', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const PetTypeSelectionScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // GridView가 존재하는지 확인
      expect(find.byType(GridView), findsOneWidget);

      // 6개의 펫 타입 카드가 모두 표시되는지 확인
      expect(find.text('犬'), findsOneWidget);
      expect(find.text('猫'), findsOneWidget);
      expect(find.text('鳥'), findsOneWidget);
      expect(find.text('ハムスター'), findsOneWidget);
      expect(find.text('うさぎ'), findsOneWidget);
      expect(find.text('亀'), findsOneWidget);
    });
  });
}
