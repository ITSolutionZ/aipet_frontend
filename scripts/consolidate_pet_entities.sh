#!/bin/bash

# 🔄 PetProfileEntity 통합 스크립트
# 중복된 Entity를 제거하고 Shared Entity를 사용하도록 업데이트

echo "🐾 Starting PetProfileEntity consolidation..."

# pet_registor의 PetProfileEntity를 shared entity로 교체
find lib/ -type f -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';|import 'package:aipet_frontend/shared/domain/entities/entities.dart';|g" {} \;

# pet_profile의 PetProfileEntity를 shared entity로 교체
find lib/ -type f -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/features/pet_profile/domain/entities/pet_profile_entity.dart';|import 'package:aipet_frontend/shared/domain/entities/entities.dart';|g" {} \;

# test 파일들도 업데이트
find test/ -type f -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';|import 'package:aipet_frontend/shared/domain/entities/entities.dart';|g" {} \;

find test/ -type f -name "*.dart" -exec sed -i '' \
  "s|import 'package:aipet_frontend/features/pet_profile/domain/entities/pet_profile_entity.dart';|import 'package:aipet_frontend/shared/domain/entities/entities.dart';|g" {} \;

echo "✅ Import statements updated!"

# entities.dart 배럴 파일 업데이트 (pet_registor)
if [ -f "lib/features/pet_registor/domain/entities/entities.dart" ]; then
  sed -i '' "s|export 'pet_profile_entity.dart';|// export 'pet_profile_entity.dart'; // 🔄 Moved to shared/domain/entities|g" \
    lib/features/pet_registor/domain/entities/entities.dart
fi

# entities.dart 배럴 파일 업데이트 (pet_profile)
if [ -f "lib/features/pet_profile/domain/entities/entities.dart" ]; then
  sed -i '' "s|export 'pet_profile_entity.dart';|// export 'pet_profile_entity.dart'; // 🔄 Moved to shared/domain/entities|g" \
    lib/features/pet_profile/domain/entities/entities.dart
fi

echo "✅ Barrel files updated!"

echo "🎯 PetProfileEntity consolidation completed!"
echo "📝 Next steps:"
echo "   1. Run 'flutter pub run build_runner build --delete-conflicting-outputs'"
echo "   2. Test compilation"
echo "   3. Remove old entity files after verification"