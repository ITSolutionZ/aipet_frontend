import 'package:aipet_frontend/shared/utils/loading_state.dart';
import 'package:aipet_frontend/shared/widgets/feedback/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('should show loading indicator when loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final loadingState = LoadingState.loading('로딩 중...');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: loadingState,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로딩 중...'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should show content when not loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final successState = LoadingState.success();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: successState,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should show error widget when error occurs', (
      WidgetTester tester,
    ) async {
      // Arrange
      final errorState = LoadingState.error('오류가 발생했습니다');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: errorState,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Content'), findsNothing);
      expect(find.text('오류가 발생했습니다'), findsNWidgets(2)); // 제목과 설명 두 개
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show custom loading widget when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final loadingState = LoadingState.loading('로딩 중...');
      const customLoadingWidget = Center(child: Text('커스텀 로딩'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: loadingState,
            loadingChild: customLoadingWidget,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('커스텀 로딩'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should show custom error widget when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final errorState = LoadingState.error('오류가 발생했습니다');
      const customErrorWidget = Center(child: Text('커스텀 에러'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: errorState,
            errorChild: customErrorWidget,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.text('커스텀 에러'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should show loading overlay when showLoadingOverlay is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      final loadingState = LoadingState.loading('로딩 중...');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: loadingState,
            showLoadingOverlay: true,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('로딩 중...'), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final errorState = LoadingState.error('오류가 발생했습니다');
      bool retryCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: errorState,
            onRetry: () => retryCalled = true,
            child: const Text('Content'),
          ),
        ),
      );

      await tester.tap(find.text('다시 시도'));
      await tester.pump();

      // Assert
      expect(retryCalled, isTrue);
    });

    testWidgets('should not show retry button when onRetry is not provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final errorState = LoadingState.error('오류가 발생했습니다');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidget(
            loadingState: errorState,
            child: const Text('Content'),
          ),
        ),
      );

      // Assert
      expect(find.text('다시 시도'), findsNothing);
    });
  });

  group('LoadingStateBuilder Tests', () {
    testWidgets('should show loading widget when loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final loadingState = LoadingState.loading('로딩 중...');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingStateBuilder(
            loadingState: loadingState,
            builder: (context, state) {
              return Text('State: ${state.isLoading}');
            },
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로딩 중...'), findsOneWidget);
    });

    testWidgets('should show custom loading and error widgets', (
      WidgetTester tester,
    ) async {
      // Arrange
      final errorState = LoadingState.error('오류가 발생했습니다');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingStateBuilder(
            loadingState: errorState,
            loadingWidget: const Text('커스텀 로딩'),
            errorWidget: const Text('커스텀 에러'),
            builder: (context, state) {
              return const Text('Content');
            },
          ),
        ),
      );

      // Assert
      expect(find.text('커스텀 에러'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });
  });

  group('SimpleLoadingIndicator Tests', () {
    testWidgets('should show loading indicator with default size', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: SimpleLoadingIndicator()),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator with custom size', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: SimpleLoadingIndicator(size: 48.0)),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show message when provided', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: SimpleLoadingIndicator(message: '로딩 중...')),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로딩 중...'), findsOneWidget);
    });
  });

  group('ButtonLoadingIndicator Tests', () {
    testWidgets('should show loading indicator with default size', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: ButtonLoadingIndicator()),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator with custom size', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: ButtonLoadingIndicator(size: 24.0)),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show message when provided', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(home: ButtonLoadingIndicator(message: '로딩 중...')),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('로딩 중...'), findsOneWidget);
    });
  });
}
