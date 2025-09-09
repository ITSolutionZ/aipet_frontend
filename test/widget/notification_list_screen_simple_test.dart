import 'package:aipet_frontend/features/notification/presentation/screens/notification_list_screen.dart';
import 'package:aipet_frontend/features/notification/presentation/widgets/notification_list_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationListScreen Simple Tests', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(home: NotificationListScreen()),
      );
    }

    group('기본 렌더링', () {
      testWidgets('should render NotificationListScreen widget', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(NotificationListScreen), findsOneWidget);
      });

      testWidgets('should show app bar with correct title', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('通知'), findsOneWidget);
        expect(find.byType(SoftGradientBackAppBar), findsOneWidget);
      });

      testWidgets('should show loading state initially', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Assert - 초기 로딩 상태 확인
        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

        // Wait for loading to complete
        await tester.pumpAndSettle();
      });
    });

    group('필터 칩 기능', () {
      testWidgets('should show filter section with title', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('通知の種類'), findsOneWidget);
      });

      testWidgets('should show "전체" filter chip', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('全て'), findsOneWidget);
      });

      testWidgets('should show notification type filter chips', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 주요 알림 타입별 필터 칩 확인
        expect(find.text('一般'), findsOneWidget);
        expect(find.text('食事'), findsOneWidget);
        expect(find.text('散歩'), findsOneWidget);
        expect(find.text('健康'), findsOneWidget);
        expect(find.text('予約'), findsOneWidget);
        expect(find.text('システム'), findsOneWidget);
      });

      testWidgets('should not show checkmarks on filter chips', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - showCheckmark가 false인지 확인
        final filterChips = find.byType(FilterChip);
        expect(filterChips, findsWidgets);

        for (final chip in tester.widgetList<FilterChip>(filterChips)) {
          expect(chip.showCheckmark, isFalse);
        }
      });

      testWidgets('should allow filter selection', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - "食事" 필터 선택
        await tester.tap(find.text('食事'));
        await tester.pumpAndSettle();

        // Assert - FilterChip이 존재하고 상호작용 가능함을 확인
        expect(find.text('食事'), findsOneWidget);
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('should show horizontal scrollable filter list', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 수평 스크롤 ListView 확인
        final horizontalListView = find.byWidgetPredicate(
          (widget) =>
              widget is ListView && widget.scrollDirection == Axis.horizontal,
        );
        expect(horizontalListView, findsOneWidget);
      });
    });

    group('알림 목록 기능', () {
      testWidgets('should show NotificationListWidget', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(NotificationListWidget), findsOneWidget);
      });

      testWidgets('should pass correct parameters to NotificationListWidget', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        final notificationListWidget = tester.widget<NotificationListWidget>(
          find.byType(NotificationListWidget),
        );

        expect(notificationListWidget.showEmptyState, isTrue);
        expect(notificationListWidget.maxItems, equals(50));
        expect(notificationListWidget.filterType, isNull); // 초기 상태는 null (전체)
      });
    });

    group('UI 레이아웃', () {
      testWidgets('should have proper background color', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(AppColors.pointOffWhite));
      });

      testWidgets('should have proper column layout', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Column 레이아웃 확인
        expect(find.byType(Column), findsOneWidget);
      });

      testWidgets('should have proper spacing widgets', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 간격 위젯들 확인
        final spacingWidgets = find.byType(SizedBox);
        expect(spacingWidgets, findsWidgets);
      });
    });

    group('상태 관리', () {
      testWidgets('should handle lifecycle methods properly', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 위젯이 정상적으로 생성됨
        expect(find.byType(NotificationListScreen), findsOneWidget);

        // Dispose test
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        expect(find.byType(NotificationListScreen), findsNothing);
      });

      testWidgets('should handle filter state changes without errors', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - 여러 필터 변경
        await tester.tap(find.text('食事'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('散歩'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('全て'));
        await tester.pumpAndSettle();

        // Assert - 에러 없이 상태 변경됨
        expect(tester.takeException(), isNull);
        expect(find.byType(NotificationListScreen), findsOneWidget);
      });
    });

    group('접근성', () {
      testWidgets('should have proper semantics for filter chips', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - FilterChip들이 접근 가능한지 확인
        final filterChips = find.byType(FilterChip);
        expect(filterChips, findsWidgets);

        for (final chipFinder in filterChips.evaluate()) {
          final chip = chipFinder.widget as FilterChip;
          expect(chip.onSelected, isNotNull);
        }
      });

      testWidgets('should have Material design components', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Material design 컴포넌트 확인
        expect(find.byType(Material), findsWidgets);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('에러 처리', () {
      testWidgets('should render without errors', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 에러 없이 렌더링됨
        expect(find.byType(NotificationListScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
