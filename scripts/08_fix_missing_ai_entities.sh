#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (8차 - Missing AI Entities) ==="

# AiFavoriteEntity import 추가
files_need_favorite="
lib/features/ai/data/repositories/ai_repository_impl.dart
lib/features/ai/data/repositories/ai_repository_mockito_impl.dart
"

for file in $files_need_favorite; do
  if [ -f "$file" ]; then
    if ! grep -q "import.*ai_favorite_entity.dart" "$file"; then
      sed -i '' '/^import.*ai_favorite_qa_entity.dart/a\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_favorite_entity.dart'\'';
' "$file"
      echo "✅ $file에 AiFavoriteEntity import 추가"
    fi
  fi
done

# AiChatSummaryEntity import 추가
for file in $files_need_favorite; do
  if [ -f "$file" ]; then
    if ! grep -q "import.*ai_chat_summary_entity.dart" "$file"; then
      sed -i '' '/^import.*ai_chat_summary.dart/a\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_chat_summary_entity.dart'\'';
' "$file"
      echo "✅ $file에 AiChatSummaryEntity import 추가"
    fi
  fi
done

# AiCategoryEntity import 추가 (ai_config_service.dart)
if [ -f "lib/features/ai/data/services/ai_config_service.dart" ]; then
  if ! grep -q "import.*ai_category_entity.dart" lib/features/ai/data/services/ai_config_service.dart; then
    sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart'\'';
' lib/features/ai/data/services/ai_config_service.dart
    echo "✅ ai_config_service.dart에 AiCategoryEntity import 추가"
  fi
fi

# AiChatSessionEntity import 추가
if [ -f "lib/features/ai/data/services/ai_mock_data_service_impl.dart" ]; then
  if ! grep -q "import.*ai_chat_session_entity.dart" lib/features/ai/data/services/ai_mock_data_service_impl.dart; then
    sed -i '' '/^import.*ai_suggested_question_entity.dart/a\
import '\''package:aipet_frontend/features/onboarding/domain/entities/ai_chat_session_entity.dart'\'';
' lib/features/ai/data/services/ai_mock_data_service_impl.dart
    echo "✅ ai_mock_data_service_impl.dart에 AiChatSessionEntity import 추가"
  fi
fi

echo ""
echo "✅ 8차 Missing AI Entities import 수정 완료!"
echo "📊 추가된 import:"
echo "- AiFavoriteEntity"
echo "- AiChatSummaryEntity"
echo "- AiCategoryEntity (ai_config_service)"
echo "- AiChatSessionEntity (mock_data_service)"

