#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 ==="

# 1. pet_registor/pet_registor.dart → features/pet_registor/domain/entities/pet_profile_entity.dart
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/pet_registor/pet_registor.dart|package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart|g' {} \;

# 2. shared/router/app_router.dart → app/router/routes/...
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/router/app_router.dart|package:aipet_frontend/app/router/app_router.dart|g' {} \;

# 3. shared/config/app_config.dart → app/config/app_config.dart
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/config/app_config.dart|package:aipet_frontend/app/config/app_config.dart|g' {} \;

# 4. shared/services/openai_service.dart → features/ai/data/services/openai_service.dart
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/services/openai_service.dart|package:aipet_frontend/features/ai/data/services/openai_service.dart|g' {} \;

# 5. features/onboarding/domain/entities/ai_* → features/ai/domain/entities/ai_*
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/ai_category_entity.dart|package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/ai_favorite_qa_entity.dart|package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart|g' {} \;

# 6. shared/entities/entities.dart → features/ai/domain/entities/entities.dart
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/entities.dart|package:aipet_frontend/features/ai/domain/entities/entities.dart|g' {} \;

# 7. features/scheduling/presentation/controllers/ai_chat_controller.dart → features/ai/presentation/controllers/ai_chat_controller.dart
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/scheduling/presentation/controllers/ai_chat_controller.dart|package:aipet_frontend/features/ai/presentation/controllers/ai_chat_controller.dart|g' {} \;

# 8. shared/widgets/ai_widgets.dart → features/ai/presentation/widgets/...
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/ai_widgets.dart|package:aipet_frontend/features/ai/presentation/widgets/ai_widgets.dart|g' {} \;

# 9. features/onboarding/data/services/ai_category_service.dart → features/ai/data/services/ai_category_service.dart
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/services/ai_category_service.dart|package:aipet_frontend/features/ai/data/services/ai_category_service.dart|g' {} \;

echo "✅ Import 경로 수정 완료!"
echo "변경된 주요 패턴:"
echo "- pet_registor/pet_registor.dart → features/pet_registor/domain/entities/pet_profile_entity.dart"
echo "- shared/router → app/router"
echo "- shared/config → app/config"
echo "- shared/services/openai_service → features/ai/data/services/openai_service"
echo "- onboarding AI entities → features/ai/domain/entities"
echo "- scheduling ai_chat_controller → features/ai/presentation/controllers"

