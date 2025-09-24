#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (7차 - Repository Interfaces) ==="

# AiRepository interface import 추가
if ! grep -q "import.*ai_repository.dart" lib/features/ai/data/repositories/ai_repository_impl.dart; then
  sed -i '' '/^import.*ai_chat_history_entity.dart/a\
import '\''package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart'\'';
' lib/features/ai/data/repositories/ai_repository_impl.dart
  echo "✅ ai_repository_impl.dart에 AiRepository interface import 추가"
fi

if ! grep -q "import.*ai_repository.dart" lib/features/ai/data/repositories/ai_repository_mockito_impl.dart; then
  sed -i '' '/^import.*ai_chat_history_entity.dart/a\
import '\''package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart'\'';
' lib/features/ai/data/repositories/ai_repository_mockito_impl.dart
  echo "✅ ai_repository_mockito_impl.dart에 AiRepository interface import 추가"
fi

# AuthRepository interface import 추가
if ! grep -q "import.*auth_repository.dart" lib/features/auth/data/auth_repository_impl.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart'\'';
' lib/features/auth/data/auth_repository_impl.dart
  echo "✅ auth_repository_impl.dart에 AuthRepository interface import 추가"
fi

if ! grep -q "import.*repositories/auth_repository.dart" lib/features/auth/data/repositories/auth_repository_impl.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart'\'';
' lib/features/auth/data/repositories/auth_repository_impl.dart
  echo "✅ auth/data/repositories/auth_repository_impl.dart에 AuthRepository interface import 추가"
fi

# AI providers에 AiRepository import 추가
if ! grep -q "import.*domain/repositories/ai_repository.dart" lib/features/ai/data/providers/ai_providers.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart'\'';
' lib/features/ai/data/providers/ai_providers.dart
  echo "✅ ai_providers.dart에 AiRepository interface import 추가"
fi

# Auth providers에 AuthRepository import 추가  
if ! grep -q "import.*domain/repositories/auth_repository.dart" lib/features/auth/data/auth_providers.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart'\'';
' lib/features/auth/data/auth_providers.dart
  echo "✅ auth_providers.dart에 AuthRepository interface import 추가"
fi

# AiSuggestedQuestionEntity import 추가
files_need_suggested="
lib/features/ai/data/services/ai_data_service.dart
lib/features/ai/data/services/ai_mock_data_service_impl.dart
"

for file in $files_need_suggested; do
  if [ -f "$file" ]; then
    if ! grep -q "import.*ai_suggested_question_entity.dart" "$file"; then
      sed -i '' '/^import/a\
import '\''package:aipet_frontend/features/onboarding/domain/entities/ai_suggested_question_entity.dart'\'';
' "$file"
      echo "✅ $file에 AiSuggestedQuestionEntity import 추가"
    fi
  fi
done

echo ""
echo "✅ 7차 Repository interface import 수정 완료!"
echo "📊 추가된 import:"
echo "- AiRepository interface"
echo "- AuthRepository interface"
echo "- AiSuggestedQuestionEntity"

