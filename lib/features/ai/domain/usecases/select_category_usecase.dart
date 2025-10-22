import 'package:aipet_frontend/shared/shared.dart';

import '../entities/ai_category_entity.dart';
import '../entities/ai_message_entity.dart';
import '../entities/ai_suggested_question_entity.dart';
import '../repositories/ai_repository.dart';

class SelectCategoryResult {
  final List<AiMessageEntity> messages;
  final List<AiSuggestedQuestionEntity> suggestedQuestions;

  const SelectCategoryResult({
    required this.messages,
    required this.suggestedQuestions,
  });
}

class SelectCategoryUseCase {
  final AiRepository _repository;

  const SelectCategoryUseCase(this._repository);

  Future<Result<SelectCategoryResult>> call({
    required AiCategoryEntity category,
    PetProfileEntity? selectedPet,
  }) async {
    try {
      final petName = selectedPet?.name ?? 'ペット';

      final userMessage = AiMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '${category.name}について相談したいです',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      final aiMessage = AiMessageEntity(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content:
            '$petNameの${category.name}について、どのような症状や心配事がありますか？\n\n$petNameの状況を詳しく教えてください。症状、期間、食欲の変化なども含めて説明していただけると、より正確なアドバイスができます。',
        type: MessageType.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
      );

      final personalizedQuestions = await _repository
          .getPersonalizedSuggestedQuestions(
            category: category.id,
            pet: selectedPet,
          );

      final result = SelectCategoryResult(
        messages: [userMessage, aiMessage],
        suggestedQuestions: personalizedQuestions,
      );

      return Result.success('カテゴリを選択しました', result);
    } catch (error) {
      return Result.failure('カテゴリ選択に失敗しました: ${error.toString()}');
    }
  }
}
