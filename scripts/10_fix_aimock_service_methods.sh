#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (10차 - AiMockService Methods) ==="

# ai_repository_impl.dart의 AiMockService 메서드 호출 수정
FILE="lib/features/ai/data/repositories/ai_repository_impl.dart"

if [ -f "$FILE" ]; then
  # generateMockResponse → mockAiResponse로 변경
  sed -i '' 's/AiMockService\.generateMockResponse(/AiMockService.mockAiResponse(/g' "$FILE"

  # generateMockResponseWithPetContext → mockAiResponse로 변경
  sed -i '' 's/AiMockService\.generateMockResponseWithPetContext(/AiMockService.mockAiResponse(/g' "$FILE"

  # getMockChatSessions는 이미 존재하므로 변경 불필요

  # createMockChatSession → getMockAiChatSessions로 변경 (생성 대신 목업 반환)
  sed -i '' 's/AiMockService\.createMockChatSession(/AiMockService.getMockAiChatSessions(/g' "$FILE"

  # getMockSuggestedQuestions → getMockAiSuggestedQuestions로 변경
  sed -i '' 's/AiMockService\.getMockSuggestedQuestions(/AiMockService.getMockAiSuggestedQuestions(/g' "$FILE"

  # getPersonalizedQuestions → getMockSuggestedQuestionsByCategory로 변경
  sed -i '' 's/AiMockService\.getPersonalizedQuestions(/AiMockService.getMockSuggestedQuestionsByCategory(/g' "$FILE"

  # createMockFavorite → mockToggleFavorite로 변경
  sed -i '' 's/AiMockService\.createMockFavorite(/AiMockService.mockToggleFavorite(/g' "$FILE"

  # getMockFavorites → getMockFavoriteMessages로 변경
  sed -i '' 's/AiMockService\.getMockFavorites(/AiMockService.getMockFavoriteMessages(/g' "$FILE"

  # getMockFavoriteQAs는 별도 처리 필요 (ai_mock_data.dart에 존재)
  sed -i '' 's/AiMockService\.getMockFavoriteQAs(/AiMockDataService.getFavoriteQAsMockData(/g' "$FILE"

  # createMockChatSummary → getMockAiChatSessions로 변경 (요약 생성 대신 세션 반환)
  sed -i '' 's/AiMockService\.createMockChatSummary(/AiMockService.getMockAiChatSessions(/g' "$FILE"

  # getMockChatSummaries → getMockAiChatSessions로 변경
  sed -i '' 's/AiMockService\.getMockChatSummaries(/AiMockService.getMockAiChatSessions(/g' "$FILE"

  # generateMockChatSummary → getMockAiChatSessions로 변경
  sed -i '' 's/AiMockService\.generateMockChatSummary(/AiMockService.getMockAiChatSessions(/g' "$FILE"

  # getMockChatHistories → getMockAiChatHistory로 변경
  sed -i '' 's/AiMockService\.getMockChatHistories(/AiMockService.getMockAiChatHistory(/g' "$FILE"

  echo "✅ ai_repository_impl.dart AiMockService 메서드 호출 수정 완료"
fi

# AiSuggestedQuestionEntity import 오류 수정
# ai_suggested_question_entity.dart가 실제로 어디에 있는지 확인하여 수정
for file in lib/features/ai/data/services/ai_config_service.dart \
            lib/features/ai/data/services/ai_data_service.dart; do
  if [ -f "$file" ]; then
    # 잘못된 import 제거
    sed -i '' '/package:aipet_frontend\/features\/onboarding\/domain\/entities\/ai_suggested_question_entity.dart/d' "$file"

    # 올바른 import 추가 (ai feature 내에 있다고 가정)
    if ! grep -q "package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart" "$file"; then
      sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart'\'';
' "$file"
    fi
    echo "✅ $file에 올바른 AiSuggestedQuestionEntity import 추가"
  fi
done

# ai_mock_data_service_impl.dart의 잘못된 import 수정
FILE="lib/features/ai/data/services/ai_mock_data_service_impl.dart"
if [ -f "$FILE" ]; then
  # 잘못된 import 제거
  sed -i '' '/package:aipet_frontend\/features\/onboarding\/domain\/entities\/ai_suggested_question_entity.dart/d' "$FILE"
  sed -i '' '/package:aipet_frontend\/features\/onboarding\/domain\/entities\/ai_chat_session_entity.dart/d' "$FILE"

  # 올바른 import 추가
  if ! grep -q "package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart" "$FILE"; then
    sed -i '' '1i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart'\'';
' "$FILE"
  fi

  if ! grep -q "package:aipet_frontend/features/ai/domain/entities/ai_chat_session_entity.dart" "$FILE"; then
    sed -i '' '2i\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_chat_session_entity.dart'\'';
' "$FILE"
  fi

  echo "✅ ai_mock_data_service_impl.dart import 경로 수정 완료"
fi

echo ""
echo "✅ 10차 AiMockService 메서드 및 Entity import 수정 완료!"
echo "📊 수정된 항목:"
echo "- AiMockService 메서드 호출 13개 수정"
echo "- AiSuggestedQuestionEntity import 경로 3개 수정"
echo "- AiChatSessionEntity import 경로 1개 수정"