import 'package:aipet_frontend/shared/shared.dart';

import '../../../../shared/domain/entities/pet_profile_entity.dart';
import '../entities/ai_message_entity.dart';

class SelectPetUseCase {
  const SelectPetUseCase();

  Result<List<AiMessageEntity>> call(PetProfileEntity? pet) {
    try {
      if (pet == null) {
        return Result.failure('ペットを選択してください');
      }

      final aiMessage = AiMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            '${pet.name}についてですね！🐕\n\nどのような内容でお困りですか？カテゴリを選択してください：\n\n• 健康 - 病気、怪我、健康管理\n• 食事 - フード、栄養、給餌\n• 行動 - しつけ、問題行動\n• グルーミング - お手入れ、毛づくろい\n• その他',
        type: MessageType.assistant,
        timestamp: DateTime.now().add(const Duration(milliseconds: 500)),
      );

      return Result.success('ペットを選択しました', [aiMessage]);
    } catch (error) {
      return Result.failure('ペット選択に失敗しました: ${error.toString()}');
    }
  }
}
