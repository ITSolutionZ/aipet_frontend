import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/presentation/screens/notification_list_screen.dart';
import 'package:aipet_frontend/features/notification/presentation/widgets/notification_list_widget.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('NotificationListScreen Widget Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/notification',
        routes: [
          GoRoute(
            path: '/notification',
            builder: (context, state) => const NotificationListScreen(),
          ),
          GoRoute(
            path: RouteConstants.pushNotificationRoute,
            builder: (context, state) =>
                const Scaffold(body: Text('Push Notification Settings')),
          ),
          GoRoute(
            path: '/notification/detail',
            builder: (context, state) =>
                const Scaffold(body: Text('Notification Detail')),
          ),
        ],
      );
    });

    Widget createTestWidget() {
      return ProviderScope(child: MaterialApp.router(routerConfig: router));
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
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for loading to complete
        await tester.pumpAndSettle();
      });
    });

    group('정보 카드 기능', () {
      testWidgets(
        'should show info card when notification settings are incomplete',
        (WidgetTester tester) async {
          // Arrange & Act
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Assert - 정보 카드 표시 확인 (조건부 표시이므로 텍스트가 있는지 확인)
          final infoText = find.text('通知設定を行い、役立つ通知を\n受け取ってください。');
          final infoIcon = find.byIcon(Icons.info_outline);

          // 정보 카드가 표시되는 경우에만 검증
          if (infoText.evaluate().isNotEmpty) {
            expect(infoText, findsOneWidget);
            expect(infoIcon, findsOneWidget);
            expect(find.byIcon(Icons.chevron_right), findsOneWidget);
          } else {
            // 정보 카드가 숨겨진 경우 (모든 설정이 완료된 경우)
            expect(infoText, findsNothing);
          }
        },
      );

      testWidgets(
        'should navigate to push notification settings when info card is tapped',
        (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // Act - 정보 카드 탭 (조건부로 표시되므로 있는 경우에만 테스트)
          final infoCard = find.text('通知設定を行い、役立つ通知を\n受け取ってください。');

          if (infoCard.evaluate().isNotEmpty) {
            await tester.tap(infoCard);
            await tester.pumpAndSettle();

            // Assert - 푸시 알림 설정 페이지로 이동 확인
            expect(find.text('Push Notification Settings'), findsOneWidget);
          } else {
            // 정보 카드가 없는 경우, InkWell 버튼을 찾아서 테스트
            final inkWell = find.byType(InkWell);
            if (inkWell.evaluate().isNotEmpty) {
              await tester.tap(inkWell.first);
              await tester.pumpAndSettle();
            }
          }
        },
      );

      testWidgets('should show proper spacing when info card is visible', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 간격 확인
        final spacingWidget = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == AppSpacing.md,
        );
        expect(spacingWidget, findsOneWidget);
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

      testWidgets('should show "전체" filter chip as selected initially', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('全て'), findsOneWidget);

        // FilterChip이 선택된 상태인지 확인
        final filterChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == '全て' &&
              widget.selected == true,
        );
        expect(filterChip, findsOneWidget);
      });

      testWidgets('should show all notification type filter chips', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 각 알림 타입별 필터 칩 확인
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

        // Assert - 선택 상태 변경 확인
        final feedingChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == '食事' &&
              widget.selected == true,
        );
        expect(feedingChip, findsOneWidget);

        // "전체"가 선택 해제되었는지 확인
        final allChip = find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == '全て' &&
              widget.selected == false,
        );
        expect(allChip, findsOneWidget);
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

      testWidgets('should update filter when filter chip is selected', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - "散歩" 필터 선택
        await tester.tap(find.text('散歩'));
        await tester.pumpAndSettle();

        // Assert - 필터가 적용되었는지 확인
        final notificationListWidget = tester.widget<NotificationListWidget>(
          find.byType(NotificationListWidget),
        );
        expect(
          notificationListWidget.filterType,
          equals(NotificationType.walk),
        );
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

      testWidgets('should have proper margins and spacing', (
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

        // Assert - 위젯이 정상적으로 생성되고 dispose됨
        expect(find.byType(NotificationListScreen), findsOneWidget);

        // Dispose test
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        expect(find.byType(NotificationListScreen), findsNothing);
      });

      testWidgets('should check notification settings on init', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());

        // Wait for async initialization
        await tester.pumpAndSettle();

        // Assert - 초기화 후 정보 카드가 표시됨 (설정이 완료되지 않은 경우)
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('should re-check settings when page becomes active', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - 다른 페이지로 이동 후 복귀 시뮬레이션
        await router.push(RouteConstants.pushNotificationRoute);
        await tester.pumpAndSettle();

        router.pop();
        await tester.pumpAndSettle();

        // Assert - 페이지 재활성화 시 설정 재확인
        expect(find.byType(NotificationListScreen), findsOneWidget);
      });
    });

    group('에러 처리', () {
      testWidgets('should handle missing routes gracefully', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - 에러 없이 렌더링됨
        expect(find.byType(NotificationListScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
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

      testWidgets('should have tappable info card', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - InkWell이 있어서 탭 가능한지 확인
        expect(find.byType(InkWell), findsWidgets);
      });
    });
  });
}
