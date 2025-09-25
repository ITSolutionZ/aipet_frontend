import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

class SelectPetUseCase {
  const SelectPetUseCase();

  Result<List<AiMessageEntity>> call(PetProfileEntity? pet) {
    try {
      if (pet == null) {
        return ResultFactory.failure('ペットを選択してください');
      }

      final userMessage = AiMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '${pet.name}について相談したいです',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      final aiMessage = AiMessageEntity(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content:
            '${pet.name}についてですね！🐕\n\nどのような内容でお困りですか？カテゴリを選択してください：\n\n• 健康 - 病気、怪我、健康管理\n• 食事 - フード、栄養、給餌\n• 行動 - しつけ、問題行動\n• グルーミング - お手入れ、毛づくろい\n• その他',
        type: MessageType.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
      );

      return ResultFactory.success([userMessage, aiMessage], 'ペットを選択しました');
    } catch (error) {
      return ResultFactory.failure<List<AiMessageEntity>>('ペット選択に失敗しました: ${error.toString()}');
    }
  }
}