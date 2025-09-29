import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/features/ai/presentation/controllers/ai_chat_controller.dart';
import 'package:aipet_frontend/features/pet_registor/pet_registor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiChatController Tests', () {
    late ProviderContainer container;
    late AiChatController controller;

    setUp(() {
      container = ProviderContainer();
      controller = AiChatController(container);
    });

    tearDown(() {
      container.dispose();
    });

    group('AiChatNotifier Tests', () {
      test('should initialize with empty state', () {
        final state = container.read(aiChatNotifierProvider);

        expect(state.messages, isEmpty);
        expect(state.suggestedQuestions, isEmpty);
        expect(state.isTyping, isFalse);
        expect(state.error, isNull);
        expect(state.selectedPet, isNull);
        expect(state.hasPetSelected, isFalse);
        expect(state.selectedCategory, isNull);
        expect(state.hasCategorySelected, isFalse);
        expect(state.favoriteMessageIds, isEmpty);
        expect(state.favoriteQAs, isEmpty);
      });

      test('should initialize chat correctly', () async {
        final notifier = container.read(aiChatNotifierProvider.notifier);
        await notifier.initializeChat();

        final state = container.read(aiChatNotifierProvider);
        expect(state.messages, isEmpty);
        expect(state.hasPetSelected, isFalse);
        expect(state.hasCategorySelected, isFalse);
      });

      test('should select pet correctly', () {
        final notifier = container.read(aiChatNotifierProvider.notifier);
        final mockPet = PetProfileEntity(
          id: 'pet1',
          name: 'Buddy',
          species: 'Dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          isNeutered: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        notifier.selectPet(mockPet);
        final state = container.read(aiChatNotifierProvider);

        expect(state.selectedPet, equals(mockPet));
        expect(state.hasPetSelected, isTrue);
        expect(state.messages, hasLength(2)); // User message + AI response
        expect(state.messages[0].isUser, isTrue);
        expect(state.messages[1].isUser, isFalse);
      });

      test('should select category correctly', () async {
        final notifier = container.read(aiChatNotifierProvider.notifier);
        final mockPet = PetProfileEntity(
          id: 'pet1',
          name: 'Buddy',
          species: 'Dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          isNeutered: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        const mockCategory = AiCategoryEntity(
          id: 'health',
          name: '健康',
          description: '健康相談',
          iconData: 'health_icon',
          isActive: true,
        );

        // First select pet
        notifier.selectPet(mockPet);

        // Then select category
        await notifier.selectCategory(mockCategory);

        final state = container.read(aiChatNotifierProvider);

        expect(state.selectedCategory, equals(mockCategory));
        expect(state.hasCategorySelected, isTrue);
        expect(
          state.messages,
          hasLength(4),
        ); // Pet selection + Category selection messages
      });

      test('should clear all favorites correctly', () {
        final notifier = container.read(aiChatNotifierProvider.notifier);

        // Clear all favorites
        notifier.clearAllFavorites();

        final state = container.read(aiChatNotifierProvider);
        expect(state.favoriteMessageIds, isEmpty);
        expect(state.favoriteQAs, isEmpty);
      });

      test('should remove individual favorite correctly', () {
        final notifier = container.read(aiChatNotifierProvider.notifier);
        const favoriteId = 'msg1';

        // Remove specific favorite
        notifier.removeFavorite(favoriteId);

        final state = container.read(aiChatNotifierProvider);
        expect(state.favoriteMessageIds, isNot(contains(favoriteId)));
      });
    });

    group('AiChatController Tests', () {
      test('should get current chat state', () {
        final chatState = controller.watchChatState();
        expect(chatState, isA<AiChatState>());
      });

      test('should initialize chat successfully', () async {
        final result = await controller.initializeChat();
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('チャットが初期化されました'));
      });

      test('should select pet correctly', () {
        final mockPet = PetProfileEntity(
          id: 'pet1',
          name: 'Buddy',
          species: 'Dog',
          breed: 'Golden Retriever',
          birthDate: DateTime(2020, 1, 1),
          isNeutered: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        controller.selectPet(mockPet);

        expect(controller.selectedPet, equals(mockPet));
        expect(controller.hasPetSelected, isTrue);
      });

      test('should fail to send empty message', () async {
        final result = await controller.sendMessage('');
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('メッセージが空です'));
      });

      test('should fail to send whitespace only message', () async {
        final result = await controller.sendMessage('   ');
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('メッセージが空です'));
      });

      test('should check favorite status correctly', () {
        expect(controller.isFavorite('nonexistent'), isFalse);
      });

      test('should get empty lists initially', () {
        expect(controller.messages, isEmpty);
        expect(controller.suggestedQuestions, isEmpty);
        expect(controller.favoriteMessageIds, isEmpty);
      });

      test('should get correct initial state', () {
        expect(controller.isTyping, isFalse);
        expect(controller.error, isNull);
        expect(controller.selectedPet, isNull);
        expect(controller.hasPetSelected, isFalse);
        expect(controller.selectedCategory, isNull);
        expect(controller.hasCategorySelected, isFalse);
      });

      test('should select category correctly', () {
        const mockCategory = AiCategoryEntity(
          id: 'health',
          name: '健康',
          description: '健康相談',
          iconData: 'health_icon',
          isActive: true,
        );

        controller.selectCategory(mockCategory);

        expect(controller.selectedCategory, equals(mockCategory));
        expect(controller.hasCategorySelected, isTrue);
      });

      test('should clear chat history successfully', () async {
        final result = await controller.clearChatHistory();
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('チャット履歴がクリアされました'));
      });

      test('should save current chat manually', () async {
        final result = await controller.saveCurrentChatManually();
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('チャット履歴が保存されました'));
      });

      test('should save current chat on tab switch', () async {
        final result = await controller.saveCurrentChatOnTabSwitch();
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('チャット履歴が自動保存されました'));
      });
    });
  });
}
