import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

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

      return ResultFactory.success(result, 'カテゴリを選択しました');
    } catch (error) {
      return ResultFactory.failure<SelectCategoryResult>('カテゴリ選択に失敗しました: ${error.toString()}');
    }
  }
}