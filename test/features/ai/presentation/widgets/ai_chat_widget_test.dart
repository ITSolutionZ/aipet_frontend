import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/presentation/widgets/ai_chat_widget.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiChatWidget', () {
    testWidgets('should display chat messages correctly', (tester) async {
      // Arrange
      final messages = [
        AiMessageEntity(
          id: '1',
          content: 'こんにちは！ペットについて何かお手伝いできることはありますか？',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        ),
        AiMessageEntity(
          id: '2',
          content: '散歩について相談したいです',
          type: MessageType.user,
          timestamp: DateTime.now(),
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiChatWidget(
                messages: messages,
                onSendMessage: (message) {},
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('こんにちは！ペットについて何かお手伝いできることはありますか？'), findsOneWidget);
      expect(find.text('散歩について相談したいです'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      const messages = <AiMessageEntity>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiChatWidget(
                messages: messages,
                onSendMessage: (message) {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onSendMessage when send button is pressed', (
      tester,
    ) async {
      // Arrange
      const messages = <AiMessageEntity>[];
      String? sentMessage;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiChatWidget(
                messages: messages,
                onSendMessage: (message) {
                  sentMessage = message;
                },
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'テストメッセージ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // Assert
      expect(sentMessage, 'テストメッセージ');
    });

    testWidgets('should display pet context when provided', (tester) async {
      // Arrange
      final pet = PetProfileEntity(
        id: 'pet_1',
        name: 'ポチ',
        type: PetType.dog,
        breed: '柴犬',
        age: 3,
        birthDate: DateTime(2021, 1, 1),
        createdAt: DateTime.now(),
      );

      const messages = <AiMessageEntity>[];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AiChatWidget(
                messages: messages,
                onSendMessage: (message) {},
                isLoading: false,
                selectedPet: pet,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('ポチ'), findsOneWidget);
      expect(find.text('柴犬'), findsOneWidget);
    });
  });
}
