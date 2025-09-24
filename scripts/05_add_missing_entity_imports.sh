#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (5차 - Entity import 추가) ==="

# AI 엔티티들이 import 누락된 파일들 찾기
files_missing_ai_imports=$(grep -l "Undefined.*MessageType\|Undefined.*AiMessageEntity\|Undefined.*AiCategoryEntity\|Undefined.*AiChatHistoryEntity" <<< "$(flutter analyze lib 2>&1)" | cut -d'•' -f2 | awk '{print $NF}' | sort -u)

echo "MessageType 사용하는 파일들에 ai_message_entity import 확인 중..."

# ai_repository_impl.dart 확인 및 수정
if ! grep -q "import.*ai_message_entity.dart" lib/features/ai/data/repositories/ai_repository_impl.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart'\'';
' lib/features/ai/data/repositories/ai_repository_impl.dart
  echo "✅ ai_repository_impl.dart에 AiMessageEntity import 추가"
fi

# ai_repository_mockito_impl.dart 확인 및 수정
if ! grep -q "import.*ai_message_entity.dart" lib/features/ai/data/repositories/ai_repository_mockito_impl.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart'\'';
' lib/features/ai/data/repositories/ai_repository_mockito_impl.dart
  echo "✅ ai_repository_mockito_impl.dart에 AiMessageEntity import 추가"
fi

# ai_chat_controller.dart 확인 및 수정
if ! grep -q "import.*ai_message_entity.dart" lib/features/ai/presentation/controllers/ai_chat_controller.dart; then
  sed -i '' '/^import/a\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart'\'';
' lib/features/ai/presentation/controllers/ai_chat_controller.dart
  echo "✅ ai_chat_controller.dart에 AiMessageEntity import 추가"
fi

# ai_data_service.dart에 AiCategoryEntity import 추가
if ! grep -q "import.*ai_category_entity.dart" lib/features/ai/data/services/ai_data_service.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart'\'';
' lib/features/ai/data/services/ai_data_service.dart
  echo "✅ ai_data_service.dart에 AiCategoryEntity import 추가"
fi

echo "✅ 5차 Import 수정 완료!"

