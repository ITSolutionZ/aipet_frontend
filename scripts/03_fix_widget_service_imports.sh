#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (3차) ==="

# base_mock_service 경로 (이미 수정했지만 다시 확인)
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/testing/mock_data/base_mock_service.dart|package:aipet_frontend/shared/testing/mock_data/test/base_mock_service.dart|g' {} \;

# pet_registor 배럴 파일 제거
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/pet_registor/domain/entities/pet_profile_entity.dart|package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart|g' {} \;

# onboarding providers → 각 feature providers로
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/providers/providers.dart|package:aipet_frontend/features/pet_registor/data/providers/pet_providers.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/providers/pet_activities_providers.dart|package:aipet_frontend/features/pet_activities/data/providers/pet_activities_providers.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/providers/notification_controller_providers.dart|package:aipet_frontend/features/notification/data/providers/notification_controller_providers.dart|g' {} \;

# onboarding domain → features domain
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/notification_model.dart|package:aipet_frontend/features/notification/domain/entities/notification_model.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/repositories/auth_repository.dart|package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/youtube_video_entity.dart|package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart|g' {} \;

# shared/models → features models
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/models/weather_model.dart|package:aipet_frontend/features/home/data/models/weather_model.dart|g' {} \;

# shared/domain → shared/core/domain
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/domain/result.dart|package:aipet_frontend/shared/core/domain/result.dart|g' {} \;

# scheduling/walk_controller → walk/walk_controller
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/scheduling/presentation/controllers/walk_controller.dart|package:aipet_frontend/features/walk/presentation/controllers/walk_controller.dart|g' {} \;

# domain/entities → features 엔티티
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/domain/entities/notification_model.dart|package:aipet_frontend/features/notification/domain/entities/notification_model.dart|g' {} \;

# walk.dart 배럴 파일
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/walk.dart|package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart|g' {} \;

# shared/widgets → features widgets
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/search_bar_widget.dart|package:aipet_frontend/features/facility/presentation/widgets/search_bar_widget.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/facility_card.dart|package:aipet_frontend/features/facility/presentation/widgets/facility_card.dart|g' {} \;

# shared/repositories → features repositories
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/recipe_repository.dart|package:aipet_frontend/features/pet_feeding/domain/repositories/recipe_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/pet_profile_repository.dart|package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/home_repository.dart|package:aipet_frontend/features/home/domain/repositories/home_repository.dart|g' {} \;

# shared/exceptions → features exceptions
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/exceptions/pet_profile_exceptions.dart|package:aipet_frontend/features/pet_profile/domain/exceptions/pet_profile_exceptions.dart|g' {} \;

# shared/entities → features entities
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/youtube_video_entity.dart|package:aipet_frontend/features/pet_activities/domain/entities/youtube_video_entity.dart|g' {} \;

echo "✅ 3차 Import 경로 수정 완료!"

