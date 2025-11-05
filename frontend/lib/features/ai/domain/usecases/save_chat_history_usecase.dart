import '../../../../shared/shared.dart';

import '../entities/ai_category_entity.dart';
import '../entities/ai_chat_history_entity.dart';
import '../entities/ai_chat_summary.dart';
import '../entities/ai_message_entity.dart';
import '../repositories/ai_chat_repository.dart';


class SaveChatHistoryUseCase {
  final AiChatRepository _repository;

  const SaveChatHistoryUseCase(this._repository);

  Future<Result<void>> call({
    required List<AiMessageEntity> messages,
    PetProfileEntity? selectedPet,
    AiCategoryEntity? selectedCategory,
    bool isManualSave = false,
  }) async {
    try {
      if (messages.isEmpty) {
        return Result.success('保存するメッセージがありません', null);
      }

      final summary = await _generateChatSummary(
        messages: messages,
        petName: selectedPet?.name,
        categoryName: selectedCategory?.name,
      );

      final chatHistory = AiChatHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: summary.title,
        summary: summary.content,
        messages: List.from(messages),
        pet: selectedPet,
        category: selectedCategory,
        createdAt: DateTime.now(),
        isManualSaved: isManualSave,
        messageCount: messages.length,
      );

      await _repository.saveChatHistory(chatHistory);
      return Result.success('チャット履歴を保存しました', null);
    } catch (error) {
      return Result.failure('チャット履歴の保存に失敗しました: ${error.toString()}');
    }
  }

  Future<AiChatSummary> _generateChatSummary({
    required List<AiMessageEntity> messages,
    String? petName,
    String? categoryName,
  }) async {
    final userMessages = messages
        .where((m) => m.isUser)
        .map((m) => m.content)
        .toList();

    if (userMessages.isEmpty) {
      return AiChatSummary(
        title: '${petName ?? 'ペット'}の相談',
        content: '${categoryName ?? '一般的な'}相談',
      );
    }

    try {
      return await _repository.generateChatSummary(
        userMessages: userMessages,
        petName: petName ?? 'ペット',
        category: categoryName ?? '一般',
      );
    } catch (error) {
      final firstMessage = userMessages.first;
      final title = firstMessage.length > 20
          ? '${firstMessage.substring(0, 20)}...'
          : firstMessage;

      return AiChatSummary(
        title: title,
        content: '${petName ?? 'ペット'}の${categoryName ?? '相談'}について',
      );
    }
  }
}
