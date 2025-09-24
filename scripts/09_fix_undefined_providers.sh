#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (9차 - Undefined Providers) ==="

# aiRepositoryProvider import 추가
if ! grep -q "import.*ai_providers.dart" lib/features/ai/presentation/controllers/ai_chat_controller.dart; then
  sed -i '' '/^import.*ai_message_entity.dart/a\
import '\''package:aipet_frontend/features/ai/data/providers/ai_providers.dart'\'';
' lib/features/ai/presentation/controllers/ai_chat_controller.dart
  echo "✅ ai_chat_controller.dart에 ai_providers import 추가"
fi

# userProfileNotifierProvider import 추가
if ! grep -q "import.*settings_providers.dart" lib/features/ai/presentation/widgets/ai_message_bubble.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/settings/data/providers/settings_providers.dart'\'';
' lib/features/ai/presentation/widgets/ai_message_bubble.dart
  echo "✅ ai_message_bubble.dart에 settings_providers import 추가"
fi

# petsNotifierProvider import 추가
if ! grep -q "import.*pet_providers.dart" lib/features/ai/presentation/widgets/ai_pet_selection_bubble.dart; then
  sed -i '' '1i\
import '\''package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart'\'';
' lib/features/ai/presentation/widgets/ai_pet_selection_bubble.dart
  echo "✅ ai_pet_selection_bubble.dart에 pet_providers import 추가"
fi

# AuthConfigConstants import 추가
if ! grep -q "import.*auth_constants.dart" lib/features/auth/data/repositories/auth_repository_impl.dart; then
  sed -i '' '/^import.*auth_repository.dart/a\
import '\''package:aipet_frontend/features/auth/domain/auth_constants.dart'\'';
' lib/features/auth/data/repositories/auth_repository_impl.dart
  echo "✅ auth_repository_impl.dart에 auth_constants import 추가"
fi

# AuthConfigService import 추가
if ! grep -q "import.*auth_config_service.dart" lib/features/auth/data/repositories/auth_repository_impl.dart; then
  sed -i '' '/^import.*auth_constants.dart/a\
import '\''package:aipet_frontend/features/auth/data/services/auth_config_service.dart'\'';
' lib/features/auth/data/repositories/auth_repository_impl.dart
  echo "✅ auth_repository_impl.dart에 auth_config_service import 추가"
fi

echo ""
echo "✅ 9차 Undefined Providers import 수정 완료!"
echo "📊 추가된 import:"
echo "- aiRepositoryProvider"
echo "- userProfileNotifierProvider"
echo "- petsNotifierProvider"
echo "- AuthConfigConstants"
echo "- AuthConfigService"

