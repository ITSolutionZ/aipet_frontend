#!/bin/bash

echo "=== Notification 기능 Import 의존성 오류 자동 수정 ==="

# 1. onboarding/ai 기능에서 notification 엔티티로 변경
echo "📝 Cross-feature import 수정 중..."

# onboarding entities → notification entities
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities|package:aipet_frontend/features/notification/domain/entities|g' {} \;

# ai entities → notification entities
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/ai/domain/entities|package:aipet_frontend/features/notification/domain/entities|g' {} \;

# onboarding repositories → notification repositories
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/repositories|package:aipet_frontend/features/notification/domain/repositories|g' {} \;

# 2. 특정 엔티티 파일 경로 수정
echo "🔧 특정 엔티티 경로 수정 중..."

# notification_schedule 경로 수정
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/entities/notification_schedule.dart|package:aipet_frontend/features/notification/domain/entities/notification_schedule.dart|g' {} \;

# 3. Usecases import 수정
echo "⚙️  UseCase import 경로 수정 중..."

# ai usecases → notification usecases
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/ai/domain/usecases|package:aipet_frontend/features/notification/domain/usecases|g' {} \;

# onboarding usecases → notification usecases
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/domain/usecases|package:aipet_frontend/features/notification/domain/usecases|g' {} \;

# 4. Provider 경로 수정
echo "🔗 Provider 경로 수정 중..."

# onboarding providers → notification providers
find lib/features/notification -name "*.dart" -type f -exec sed -i '' \
  's|package:aipet_frontend/features/onboarding/data/providers|package:aipet_frontend/features/notification/data/providers|g' {} \;

echo ""
echo "✅ Notification 기능 Import 수정 완료!"
echo "📊 수정된 패턴:"
echo "  - features/onboarding/domain/entities → features/notification/domain/entities"
echo "  - features/ai/domain/entities → features/notification/domain/entities"
echo "  - features/onboarding/domain/repositories → features/notification/domain/repositories"
echo "  - features/onboarding/domain/usecases → features/notification/domain/usecases"
echo "  - features/onboarding/data/providers → features/notification/data/providers"
echo ""