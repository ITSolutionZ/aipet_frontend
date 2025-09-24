#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (6차 - Undefined Entities) ==="

# AI 엔티티 파일 찾기
echo "AI 엔티티 파일 위치 확인 중..."
find lib/features/ai/domain/entities -name "*.dart" -type f | sort

# AiChatHistoryEntity import 추가가 필요한 파일들
files_need_chat_history="
lib/features/ai/data/repositories/ai_repository_impl.dart
lib/features/ai/data/repositories/ai_repository_mockito_impl.dart
"

for file in $files_need_chat_history; do
  if [ -f "$file" ]; then
    if ! grep -q "import.*ai_chat_history_entity.dart" "$file"; then
      sed -i '' '/^import.*ai_message_entity.dart/a\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_chat_history_entity.dart'\'';
' "$file"
      echo "✅ $file에 AiChatHistoryEntity import 추가"
    fi
  fi
done

# AiFavoriteQaEntity import 추가
for file in $files_need_chat_history; do
  if [ -f "$file" ]; then
    if ! grep -q "import.*ai_favorite_qa_entity.dart" "$file"; then
      sed -i '' '/^import.*ai_message_entity.dart/a\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart'\'';
' "$file"
      echo "✅ $file에 AiFavoriteQaEntity import 추가"
    fi
  fi
done

# AiChatSummary import 추가
for file in $files_need_chat_history; do
  if [ -f "$file" ]; then
    if ! grep -q "import.*ai_chat_summary.dart" "$file"; then
      sed -i '' '/^import.*ai_message_entity.dart/a\
import '\''package:aipet_frontend/features/ai/domain/entities/ai_chat_summary.dart'\'';
' "$file"
      echo "✅ $file에 AiChatSummary import 추가"
    fi
  fi
done

# SharingProfilesScreen import 수정
if grep -q "SharingProfilesScreen" lib/app/router/routes/shell_routes.dart; then
  if ! grep -q "import.*sharing_profiles_screen.dart" lib/app/router/routes/shell_routes.dart; then
    sed -i '' '/^import/a\
import '\''package:aipet_frontend/features/pet_profile/presentation/screens/sharing_profiles_screen.dart'\'';
' lib/app/router/routes/shell_routes.dart
    echo "✅ shell_routes.dart에 SharingProfilesScreen import 추가"
  fi
fi

# QRScannerScreen import 추가
if grep -q "QRScannerScreen" lib/app/router/routes/shell_routes.dart; then
  if ! grep -q "import.*qr_scanner_screen.dart" lib/app/router/routes/shell_routes.dart; then
    sed -i '' '/^import/a\
import '\''package:aipet_frontend/features/pet_profile/presentation/screens/qr_scanner_screen.dart'\'';
' lib/app/router/routes/shell_routes.dart
    echo "✅ shell_routes.dart에 QRScannerScreen import 추가"
  fi
fi

# LinkRegistrationScreen import 추가
if grep -q "LinkRegistrationScreen" lib/app/router/routes/shell_routes.dart; then
  if ! grep -q "import.*link_registration_screen.dart" lib/app/router/routes/shell_routes.dart; then
    sed -i '' '/^import/a\
import '\''package:aipet_frontend/features/pet_profile/presentation/screens/link_registration_screen.dart'\'';
' lib/app/router/routes/shell_routes.dart
    echo "✅ shell_routes.dart에 LinkRegistrationScreen import 추가"
  fi
fi

echo ""
echo "✅ 6차 Import 수정 완료!"
echo "📊 추가된 import:"
echo "- AiChatHistoryEntity"
echo "- AiFavoriteQaEntity"
echo "- AiChatSummary"
echo "- SharingProfilesScreen"
echo "- QRScannerScreen"
echo "- LinkRegistrationScreen"

