#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (4차 - 최종) ==="

# base_mock_service 실제 위치 확인 필요
find lib -name "base_mock_service.dart" -type f | head -1

# shared/entities → features entities
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/video_progress_entity.dart|package:aipet_frontend/features/pet_activities/domain/entities/video_progress_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/video_bookmark_entity.dart|package:aipet_frontend/features/pet_activities/domain/entities/video_bookmark_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/schedule_entity.dart|package:aipet_frontend/features/scheduling/domain/entities/schedule_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/recipe_entity.dart|package:aipet_frontend/features/pet_feeding/domain/entities/recipe_entity.dart|g' {} \;

# pet_registor 배럴 파일
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/pet_registor/data/providers/pet_providers.dart|package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart|g' {} \;

# scheduling controllers → pet_profile controllers
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/scheduling/presentation/controllers/pet_profile_form_controller.dart|package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_form_controller.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/scheduling/presentation/controllers/pet_profile_controllers.dart|package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_controller.dart|g' {} \;

# onboarding → pet_registor
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/repositories/pet_repository.dart|package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/temporary_pet_data_entity.dart|package:aipet_frontend/features/pet_registor/domain/entities/temporary_pet_data_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/schedule_entity.dart|package:aipet_frontend/features/scheduling/domain/entities/schedule_entity.dart|g' {} \;

# onboarding providers → features providers
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/walk_providers.dart|package:aipet_frontend/features/walk/data/providers/walk_providers.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/facility_providers.dart|package:aipet_frontend/features/facility/data/facility_providers.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/auth_providers.dart|package:aipet_frontend/features/auth/data/providers/auth_providers.dart|g' {} \;

# domain/entities → features/walk
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/domain/entities/walk_record_entity.dart|package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart|g' {} \;

# components → shared/ui/components
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/components/cards/cards.dart|package:aipet_frontend/shared/ui/components/cards/cards.dart|g' {} \;

# shared/widgets → features widgets
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/screens/generic_breed_selection_screen.dart|package:aipet_frontend/features/pet_registor/presentation/widgets/screens/generic_breed_selection_screen.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/pet_profile_widgets.dart|package:aipet_frontend/features/pet_profile/presentation/widgets/pet_profile_widgets.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/filter_chips.dart|package:aipet_frontend/features/facility/presentation/widgets/filter_chips.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/auth_logo.dart|package:aipet_frontend/features/auth/presentation/widgets/auth_logo.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/auth_divider.dart|package:aipet_frontend/features/auth/presentation/widgets/auth_divider.dart|g' {} \;

# shared/tokens → shared/design/tokens
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/tokens/tokens.dart|package:aipet_frontend/shared/design/tokens/tokens.dart|g' {} \;

# shared/services → features services
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/services/pet_profile_domain_service.dart|package:aipet_frontend/features/pet_profile/domain/services/pet_profile_domain_service.dart|g' {} \;

# shared/repositories → features repositories
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/splash_repository.dart|package:aipet_frontend/features/splash/domain/repositories/splash_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/schedule_repository.dart|package:aipet_frontend/features/scheduling/domain/repositories/schedule_repository.dart|g' {} \;

echo "✅ 4차 Import 경로 수정 완료!"
echo "📊 진행 상황:"
echo "- 시작: 4,866개 에러"
echo "- 1차 수정 후: 4,714개 (152개 감소)"
echo "- 2차 수정 후: 4,034개 (680개 감소)"
echo "- 3차 수정 후: 3,550개 (484개 감소)"
echo "- 4차 수정 완료! 에러 확인 중..."

