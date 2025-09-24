#!/bin/bash

echo "=== Import 경로 오류 자동 수정 스크립트 (2차) ==="

# onboarding 엔티티들을 올바른 위치로
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/facility.dart|package:aipet_frontend/features/facility/domain/entities/facility_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/trick_entity.dart|package:aipet_frontend/features/pet_activities/domain/entities/trick_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/walk_record_entity.dart|package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/pet_profile_entity.dart|package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart|g' {} \;

# shared/entities → features 엔티티로
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/pet_profile_entity.dart|package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/walk_record_entity.dart|package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/user_profile_entity.dart|package:aipet_frontend/features/settings/domain/entities/user_profile_entity.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/entities/pet_registration_data_entity.dart|package:aipet_frontend/features/pet_registor/domain/entities/pet_registration_data_entity.dart|g' {} \;

# shared/repositories → features 레포지토리로
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/settings_repository.dart|package:aipet_frontend/features/settings/domain/repositories/settings_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/notification_repository.dart|package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/pet_activities_repository.dart|package:aipet_frontend/features/pet_activities/domain/repositories/pet_activities_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/walk_repository.dart|package:aipet_frontend/features/walk/domain/repositories/walk_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/pet_repository.dart|package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/facility_repository.dart|package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/repositories/auth_repository.dart|package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart|g' {} \;

# 기타 경로 수정
find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/core/base_mock_service.dart|package:aipet_frontend/shared/testing/mock_data/base_mock_service.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/design/tokens/tokens.dart|package:aipet_frontend/shared/design/tokens/tokens.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/widgets/pet_registor_widgets.dart|package:aipet_frontend/features/pet_registor/presentation/widgets/pet_registor_widgets.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/domain.dart|package:aipet_frontend/shared/shared.dart|g' {} \;

find lib -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/shared/facility.dart|package:aipet_frontend/features/facility/domain/entities/facility_entity.dart|g' {} \;

echo "✅ 2차 Import 경로 수정 완료!"

